//
//  PoiListViewController.swift
//  poi-list-ios
//
//  Created by Harry Lundstrom on 19/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PoiListViewController: UIViewController {

    @IBOutlet weak var titleView: UITextField!
    @IBOutlet weak var infoView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    var managedObjectContext: NSManagedObjectContext? = nil
    var poiListModel: PoiListModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let list = poiListModel {
            if let navTitle = navItem {
               navTitle.title = list.title
            }
            self.titleView.text = list.title
            self.infoView.text = list.info
        } else {
            self.title = "New List"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonPressed() {
        exit()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed() {
        if let list = poiListModel {
            saveObject(poiListModel: list)
        } else {
            insertNewObject();
        }
        exit()
        dismiss(animated: true, completion: nil)
    }
    
    func saveObject(poiListModel: PoiListModel) {
        if let moc = self.managedObjectContext {
            poiListModel.title = titleView.text
            poiListModel.info = infoView.text
            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insertNewObject() {
        if let moc = self.managedObjectContext {
            let newPoiList = PoiListModel(context: moc)
            newPoiList.timestamp = NSDate()
            newPoiList.title = titleView.text
            newPoiList.info = infoView.text
            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func exit() {
        titleView.resignFirstResponder()
        infoView.resignFirstResponder()
    }
}
