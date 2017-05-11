//
//  DetailViewController.swift
//  poi-list-ios
//
//  Created by Harry Lundstrom on 12/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // Associate a PoiModel with a Pin
    class PoiModelPin {
        var poiModel: PoiModel
        var pin: MKPointAnnotation
        init(poiModel: PoiModel, pin: MKPointAnnotation) {
            self.poiModel = poiModel
            self.pin = pin
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var xLabel: UILabel!
    var pinsArray: [PoiModelPin] = []
    var managedObjectContext: NSManagedObjectContext?
    var poiListModel: PoiListModel?
    var emailManager: EmailManager?
    let locationManager = CLLocationManager()
    var alertShowing: Bool = false
    var initialZoom: Bool = false
    
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
        if(mapView != nil) {
            let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
            mapView.removeAnnotations(annotationsToRemove)
        }
        if let list = poiListModel {
            self.navigationItem.title = list.title
        }
        let pois = fetchPois(poiListModel:poiListModel, managedObjectContext: managedObjectContext)
        addPinsToMap(poiModels: pois)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongpressed))
        mapView.addGestureRecognizer(longPressGesture)
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func presentEditModal(_ sender: Any) {
        if let moc = managedObjectContext {
            let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "PoiListViewController") as! PoiListViewController
            modalViewController.modalPresentationStyle = .popover
            modalViewController.managedObjectContext = moc
            modalViewController.poiListModel = poiListModel
            present(modalViewController, animated: true, completion: { () -> Void   in
                print("modal completion")
            })
        }
    }
    
    func zoomMap() {
        var zoomRect = MKMapRectNull
        if let coordinate = mapView.userLocation.location {
            let annotationPoint = MKMapPointForCoordinate(coordinate.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        for pin in mapView.annotations {
            let annotationPoint = MKMapPointForCoordinate(pin.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        let padding: CGFloat = 100
        mapView.setVisibleMapRect(zoomRect, edgePadding:UIEdgeInsetsMake(padding, padding, padding, padding), animated: true)
        mapView.delegate = self
    }
    
    func sendMail(json: String) {
        emailManager!.sendMailTo(subject: "POI List", body: "body", attachment: json, fromViewController: self)
    }
    
    @IBAction func exportList(_ sender: Any) {
        if let json = getPoiListAsJSON(poiListModel:poiListModel, managedObjectContext: managedObjectContext) {
            sendMail(json: json)
        }
    }
    
    func addPinsToMap(poiModels: [PoiModel]) {
        for poi in poiModels {
            addLocation(poiModel: poi)
        }
    }

    func addLocation(poiModel: PoiModel) {
        let location = CLLocationCoordinate2DMake(poiModel.lat, poiModel.long)
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = poiModel.title
        pin.subtitle = poiModel.info
        let poiPin = PoiModelPin(poiModel:poiModel, pin:pin)
        pinsArray.append(poiPin)
        if(mapView != nil) {
            mapView.addAnnotation(pin)
        }
    }
    
    func addNewPoiModel(lat: CLLocationDegrees, long: CLLocationDegrees, title: String, info: String) -> PoiModel? {
        return insertNewPoiModel(title: title, info: info, lat: lat, long: long, poiListModel: poiListModel, managedObjectContext: managedObjectContext)
    }
    
    func savePoiModelForAnnotation(pin: MKAnnotation) {
        if let poiModel = getModelForPin(pin:pin) {
            savePoiModel(poiModel: poiModel, title: pin.title!, info: pin.subtitle!, lat: pin.coordinate.latitude, long: pin.coordinate.longitude, managedObjectContext: self.managedObjectContext)
        }
    }
    
    func deletePoiModelForAnnotation(pin: MKAnnotation) {
        if let poiModel = getModelForPin(pin:pin) {
            var index = 0
            for poiModelPin in pinsArray  {
                if(poiModelPin.pin === pin) {
                    self.mapView.removeAnnotation(pin)
                    pinsArray.remove(at: index)
                    break
                }
                index+=1
            }
            deletePoiModel(poiModel: poiModel, managedObjectContext: managedObjectContext)
        }
    }
    
    func getModelForPin(pin: MKAnnotation) -> PoiModel? {
        for poiModelPin in pinsArray  {
            if(poiModelPin.pin === pin) {
                return poiModelPin.poiModel
            }
        }
        return nil
    }
    
    func mapViewLongpressed(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        if(!alertShowing) {
            alertShowing = true
            showActionLongpress(location:coordinate)
        }
    }
    
    func showActionLongpress(location: CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: nil, message: "Add pin?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.alertShowing = false
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            if let poiModel = self.addNewPoiModel(lat: location.latitude, long: location.longitude, title: "title", info: "info") {
                self.addLocation(poiModel: poiModel)
            }
            self.alertShowing = false
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Responding to Map Position Changes
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {}
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {}
    
    // MARK: - Loading the Map Data
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {}
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {}
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {}
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {}
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {}
    
    // MARK: - Tracking the User Location
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {}
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {}
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if(!initialZoom) {
            initialZoom = true
            if ProcessInfo.processInfo.arguments.contains("UITEST") {
                // zooming the map could fail the UI test when placing a pin. Is there a better way?
            } else {
                zoomMap()
            }
        }
    }
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {}
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {}
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
                print("location not enabled")
            return
        }
        mapView.showsUserLocation = true
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
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {}
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let poiModel = getModelForPin(pin: view.annotation!)
        pushPinViewController(poiModel:poiModel!)
    }
    func pushPinViewController(poiModel: PoiModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let poiViewController = storyboard.instantiateViewController(withIdentifier: "PoiViewController") as! PoiViewController
        poiViewController.poiModel = poiModel
        poiViewController.managedObjectContext = self.managedObjectContext
        navigationController?.pushViewController(poiViewController, animated: true)
    }
    
    // MARK: - Dragging an Annotation View
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            xLabel.isHidden = false
        case .ending, .canceling:
            if let globalPoint = view.superview?.convert(view.frame.origin, to: nil) {
                let xLabelPosX = xLabel.frame.origin.x + xLabel.frame.size.width
                let xLabelPosY = xLabel.frame.origin.y + xLabel.frame.size.height
                if(globalPoint.x < xLabelPosX && globalPoint.y < xLabelPosY) {
                    DispatchQueue.main.async {
                        self.deletePoiModelForAnnotation(pin:view.annotation!)
                    }
                } else {
                    savePoiModelForAnnotation(pin:view.annotation!)
                }
                xLabel.isHidden = true
            }
        default: break
        }
    }
    
    // MARK: - Selecting Annotation Views
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {}
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {}
    
    // MARK: - Managing the Display of Overlays
    //func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {}
    //func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {}
}

