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

    // associate a PoiModel with a Pin
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
    var managedObjectContext: NSManagedObjectContext? = nil
    var poiListModel: PoiListModel? = nil
    var emailManager: EmailManager?
    let locationManager = CLLocationManager()
    var alertShowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        emailManager = EmailManager()
        locationManager.delegate = self
        xLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(mapView != nil) {
            // todo: need to make sure we don't remove user location if present.
            pinsArray.removeAll()
            mapView.removeAnnotations(mapView.annotations)
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
        for pin in mapView.annotations {
            let annotationPoint = MKMapPointForCoordinate(pin.coordinate);
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
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
        zoomMap()
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
            poiModel.lat = pin.coordinate.latitude
            poiModel.long = pin.coordinate.longitude
            poiModel.title = pin.title!
            poiModel.info = pin.subtitle!
            if let moc = self.managedObjectContext {
                do {
                    try moc.save()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
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
            if let moc = self.managedObjectContext {
                moc.delete(poiModel)
                do {
                    try moc.save()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
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
            alertShowing = true;
            showActionLongpress(location:coordinate)
        }
    }
    
    func showActionLongpress(location: CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: nil, message: "Add pin?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.alertShowing = false;
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            if let poiModel = self.addNewPoiModel(lat: location.latitude, long: location.longitude, title: "title", info: "info") {
                self.addLocation(poiModel: poiModel)
            }
            self.alertShowing = false;
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Responding to Map Position Changes
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
    }
    // Loading the Map Data
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {}
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {}
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {}
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {}
    
    // Tracking the User Location
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
    }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {}
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {}
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {}
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {}
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { print("not enabled"); return }
        mapView.showsUserLocation = true
    }
    // Managing Annotation Views
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
    // Dragging an Annotation View
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            xLabel.isHidden = false
        case .ending, .canceling:
            if let globalPoint = view.superview?.convert(view.frame.origin, to: nil) {
                if(globalPoint.x < 100 && globalPoint.y < 100) {
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
    // Selecting Annotation Views
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {}
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {}
    // Managing the Display of Overlays
    //func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {}
    //func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {}
}

