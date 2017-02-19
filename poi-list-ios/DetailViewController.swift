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

class DetailViewController: UIViewController, MKMapViewDelegate {

    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var pinsArray: [MKPointAnnotation] = []
    var managedObjectContext: NSManagedObjectContext? = nil
    var poiListModel: PoiListModel? = nil

    func configureView() {
        // Update the user interface for the detail item.
        /*if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.timestamp!.description
            }
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
      //  let employee = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: managedObjectContext) as! AAAEmployeeMO
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(mapView != nil) {
            // todo: might remove user location here..
            mapView.removeAnnotations(mapView.annotations)
        }
        fetchPois()
       
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongpressed))
        mapView.addGestureRecognizer(longPressGesture)
        
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
    func fetchPois() {
        let poiFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiModel")
        poiFetch.predicate = NSPredicate(format: "list == %@", self.poiListModel!)
        do {
            let poisFetched = try managedObjectContext!.fetch(poiFetch) as! [PoiModel]
            for poi in poisFetched {
                addLocation(lat:poi.lat, long:poi.long, title:poi.title, info:poi.info)
            }
            print("fetched PoiModel array:", poisFetched.count)
            zoomMap()
        } catch {
            fatalError("Failed to fetch pois: \(error)")
        }
    }

    func addLocation(lat: CLLocationDegrees, long: CLLocationDegrees, title: String?, info: String?) {
        let location = CLLocationCoordinate2DMake(lat, long)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = title
        dropPin.subtitle = info
        pinsArray.append(dropPin)
        if(mapView != nil) {
            mapView.addAnnotation(dropPin)
        } else {
            print("mapView is nil")
        }
    }
    func insertNewPoiObject(lat: CLLocationDegrees, long: CLLocationDegrees, title: String, info: String) {
        let context = self.managedObjectContext!
        let newPoi = PoiModel(context: context)
        newPoi.title = title
        newPoi.info = info
        newPoi.lat = lat
        newPoi.long = long
        newPoi.list = poiListModel
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func savePoi(poi: PoiModel) {
        //todo: need connection between pin and poimodel to update the coordinates after a move and save the context.
    }
    func mapViewTapped(gestureRecognizer: UIGestureRecognizer) {
        /*
         let touchPoint = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
         addLocation(lat: coordinate.latitude, long: coordinate.longitude, title: "title", subtitle: "subtitle")
         */
    }
    func mapViewLongpressed(gestureRecognizer: UIGestureRecognizer) {
        /*
         let touchPoint = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
         addLocation(lat: coordinate.latitude, long: coordinate.longitude, title: "title", subtitle: "subtitle")
         */
        print("longpressed")
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        // addLocation(lat: coordinate.latitude, long: coordinate.longitude, title: "title", subtitle: "subtitle")
        
        showActionLongpress(location:coordinate)
        
        //let modalVC = PinViewController.instantiateFromStoryboard(self.storyboard!)
        //self.presentViewController(modalVC, animated: true, completion: nil)
    }
    
    func showActionLongpress(location: CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: nil, message: "Add pin?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            self.addLocation(lat: location.latitude, long: location.longitude, title: "title", info: "subtitle")
            self.insertNewPoiObject(lat: location.latitude, long: location.longitude, title: "title", info: "subtitle")
        }
        alertController.addAction(OKAction)
        let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { action in
            print(action)
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: PoiListModel? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    //Responding to Map Position Changes
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated");
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        print("regionDidChangeAnimated");
    }
    // Loading the Map Data
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("mapViewWillStartLoadingMap");
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
        pushPinViewController()
    }
    func pushPinViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let abcViewController = storyboard.instantiateViewController(withIdentifier: "PoiViewController") as! PoiViewController
        // todo: set data
        abcViewController.title = "ABC"
        navigationController?.pushViewController(abcViewController, animated: true)
    }
    // Dragging an Annotation View
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
            /*
             case .starting:
             print("starting");
             view.dragState = .dragging
             case .ending, .canceling:
             print("ending");
             view.dragState = .none
             */
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

