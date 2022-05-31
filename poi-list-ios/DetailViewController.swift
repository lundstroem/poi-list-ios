/*
 
 This is free and unencumbered software released into the public domain.
 
 Anyone is free to copy, modify, publish, use, compile, sell, or
 distribute this software, either in source code form or as a compiled
 binary, for any purpose, commercial or non-commercial, and by any
 means.
 
 In jurisdictions that recognize copyright laws, the author or authors
 of this software dedicate any and all copyright interest in the
 software to the public domain. We make this dedication for the benefit
 of the public at large and to the detriment of our heirs and
 successors. We intend this dedication to be an overt act of
 relinquishment in perpetuity of all present and future rights to this
 software under copyright law.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 For more information, please refer to <http://unlicense.org>
 
 */

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var xLabel: UILabel!
    private var pinsArray: [PoiModelPin] = []
    private let locationManager = CLLocationManager()
    private var alertShowing: Bool = false
    private var initialZoom: Bool = false
    var managedObjectContext: NSManagedObjectContext?
    var poiListModel: PoiListModel?
    var emailManager: EmailManager?

    // Associate a PoiModel with a Pin
    private class PoiModelPin {
        var poiModel: PoiModel
        var pin: MKPointAnnotation
        init(poiModel: PoiModel, pin: MKPointAnnotation) {
            self.poiModel = poiModel
            self.pin = pin
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        emailManager = EmailManager()
        locationManager.delegate = self
        xLabel.isHidden = true
        initialZoom = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initMap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackUserLocation()
    }

    // MARK: - Private methods

    private func initMap() {
        if let annotationsToRemove = mapView?.annotations.filter({ $0 !== mapView?.userLocation }) {
            mapView?.removeAnnotations(annotationsToRemove)
        }
        if let list = poiListModel {
            navigationItem.title = list.title
        }
        let pois = fetchPois(poiListModel: poiListModel, managedObjectContext: managedObjectContext)
        addPinsToMap(poiModels: pois)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongpressed))
        mapView.addGestureRecognizer(longPressGesture)
        mapView.isAccessibilityElement = true
        mapView.accessibilityLabel = "mapView"
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
    }

    private func trackUserLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }

    private func zoomMap() {
        var zoomRect = MKMapRect.null
        if let coordinate = mapView.userLocation.location {
            let annotationPoint = MKMapPoint(coordinate.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(pointRect)
        }
        for pin in mapView.annotations {
            let annotationPoint = MKMapPoint(pin.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(pointRect)
        }
        let padding: CGFloat = 100
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: padding,
                                                                      left: padding,
                                                                      bottom: padding,
                                                                      right: padding), animated: true)
        mapView.delegate = self
    }

    private func sendMail(title: String, json: String) {
        let appStoreLink = """
                        <a href=\"https://itunes.apple.com/us/app/poi-list/id1240789342?ls=1&mt=8\">
                        Get POI List from the App Store</a>
                        """
        let body = appStoreLink + "<br /><br />Longpress on the attachment to copy it to POI List."
        if let manager = emailManager {
            let success = manager.sendMailTo(subject: "POI List: \(title)",
                body: body,
                attachment: json,
                fromViewController: self)
            if !success {
                presentMailErrorDialog()
            }
        }
    }

    private func addPinsToMap(poiModels: [PoiModel]) {
        for poi in poiModels {
            addLocation(poiModel: poi)
        }
    }

    private func addLocation(poiModel: PoiModel) {
        let location = CLLocationCoordinate2DMake(poiModel.lat, poiModel.long)
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = poiModel.title
        pin.subtitle = poiModel.info
        let poiPin = PoiModelPin(poiModel: poiModel, pin: pin)
        pinsArray.append(poiPin)
        mapView.addAnnotation(pin)
    }

    private func addNewPoiModel(lat: CLLocationDegrees,
                                long: CLLocationDegrees,
                                title: String,
                                info: String) -> PoiModel? {
        return insertNewPoiModel(title: title,
                                 info: info,
                                 lat: lat,
                                 long: long,
                                 poiListModel: poiListModel,
                                 managedObjectContext: managedObjectContext)
    }

    private func savePoiModelForAnnotation(pin: MKAnnotation) {
        if let poiModel = modelForPin(pin: pin) {
            savePoiModel(poiModel: poiModel,
                         title: pin.title!,
                         info: pin.subtitle!,
                         lat: pin.coordinate.latitude,
                         long: pin.coordinate.longitude,
                         managedObjectContext: managedObjectContext)
        }
    }

    private func deletePoiModelForAnnotation(pin: MKAnnotation) {
        if let poiModel = modelForPin(pin: pin) {
            for (index, poiModelPin) in pinsArray.enumerated() where poiModelPin.pin === pin {
                mapView.removeAnnotation(pin)
                pinsArray.remove(at: index)
                break
            }
            deletePoiModel(poiModel: poiModel, managedObjectContext: managedObjectContext)
        }
    }

    private func modelForPin(pin: MKAnnotation) -> PoiModel? {
        for poiModelPin in pinsArray where poiModelPin.pin === pin {
            return poiModelPin.poiModel
        }
        return nil
    }

    // MARK: Actions

    @IBAction func exportList(_ sender: Any) {
        if let list = poiListModel, let json = poiListAsJSON(poiListModel: poiListModel,
                                                             managedObjectContext: managedObjectContext) {
            let listTitle = list.title ?? "(no title)"
            sendMail(title: listTitle, json: json)
        }
    }

    @objc func mapViewLongpressed(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        if !alertShowing {
            alertShowing = true
            showActionLongpress(location: coordinate)
        }
    }

    @IBAction func presentEditModal(_ sender: Any) {
        guard let moc = managedObjectContext,
        let modalViewController = storyboard?.instantiateViewController(
            withIdentifier: "PoiListViewController") as? PoiListViewController
            else {
            return
        }
        modalViewController.modalPresentationStyle = .popover
        modalViewController.managedObjectContext = moc
        modalViewController.poiListModel = poiListModel
        present(modalViewController, animated: true, completion: nil)
    }

    // MARK: View transitions

    private func pushPinViewController(poiModel: PoiModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let poiViewController = storyboard.instantiateViewController(
            withIdentifier: "PoiViewController") as? PoiViewController else {
            return
        }
        poiViewController.poiModel = poiModel
        poiViewController.managedObjectContext = managedObjectContext
        navigationController?.pushViewController(poiViewController, animated: true)
    }

    private func showActionLongpress(location: CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: nil, message: "Add pin?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
            self.alertShowing = false
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            if let poiModel = self.addNewPoiModel(lat: location.latitude,
                                                  long: location.longitude,
                                                  title: "title",
                                                  info: "info") {
                self.addLocation(poiModel: poiModel)
            }
            self.alertShowing = false
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }

    private func presentMailErrorDialog() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Cannot find an email client",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// MARK: - MapView delegate

extension DetailViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !initialZoom {
            initialZoom = true
            if ProcessInfo.processInfo.arguments.contains("UITEST") {
                // avoid map zoom if running UI test.
            } else {
                zoomMap()
            }
        }
    }

    // MARK: - Managing Annotation Views

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.isDraggable = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let poiModel = modelForPin(pin: view.annotation!)
        pushPinViewController(poiModel: poiModel!)
    }

    // MARK: - Dragging an Annotation View
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            xLabel.isHidden = false
        case .ending, .canceling:
            if let globalPoint = view.superview?.convert(view.frame.origin, to: nil) {
                let xLabelPosX = xLabel.frame.origin.x + xLabel.frame.size.width
                let xLabelPosY = xLabel.frame.origin.y + xLabel.frame.size.height
                if globalPoint.x < xLabelPosX && globalPoint.y < xLabelPosY {
                    DispatchQueue.main.async {
                        self.deletePoiModelForAnnotation(pin: view.annotation!)
                    }
                } else {
                    savePoiModelForAnnotation(pin: view.annotation!)
                }
                xLabel.isHidden = true
            }
        default: break
        }
    }
}

// MARK: - Location Manager

extension DetailViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager,
                                 didChangeAuthorizationStatus
                                 status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            print("location not enabled")
            return
        }
        mapView.showsUserLocation = true
    }
}
