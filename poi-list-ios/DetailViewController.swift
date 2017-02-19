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
        fetchPois()
    }
    
    func fetchPois() {
        let poiFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiModel")
        poiFetch.predicate = NSPredicate(format: "list == %@", self.poiListModel!)
        do {
            let poisFetched = try managedObjectContext!.fetch(poiFetch) as! [PoiModel]
            print("fetched PoiModel array:", poisFetched.count)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }

    func addLocation(lat: CLLocationDegrees, long: CLLocationDegrees, title: String, subtitle: String) {
        let location = CLLocationCoordinate2DMake(lat, long)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = title
        dropPin.subtitle = subtitle
        
        
        pinsArray.append(dropPin)
        if(mapView != nil) {
            mapView.addAnnotation(dropPin)
        } else {
            print("mapView is nil")
        }
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
            self.addLocation(lat: location.latitude, long: location.longitude, title: "title", subtitle: "subtitle")
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

