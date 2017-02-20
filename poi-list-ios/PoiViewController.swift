//
//  PinViewController.swift
//  poilist
//
//  Created by Harry Lundstrom on 06/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PoiViewController: UIViewController {

    @IBOutlet weak var titleView: UITextField!
    @IBOutlet weak var infoView: UITextView!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var poiModel: PoiModel? = nil
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let removeButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePoi(_:)))
        self.navigationItem.rightBarButtonItem = removeButton
        titleView.becomeFirstResponder()
    }

    func savePoi() {
        if let poi = poiModel {
            poi.title = self.titleView.text
            poi.info = self.infoView.text
            if(poi.title == nil || poi.title == "") {
                poi.title = "title"
            }
            if let moc = managedObjectContext {
                do {
                    try moc.save()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    func deletePoi(_ sender: Any) {
        if let poi = poiModel {
            if let moc = managedObjectContext {
                moc.delete(poi)
                do {
                    try moc.save()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let poi = poiModel {
            self.titleView.text = poi.title
            self.infoView.text = poi.info
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        savePoi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func exit() {
        titleView.resignFirstResponder()
        infoView.resignFirstResponder()
    }
}
