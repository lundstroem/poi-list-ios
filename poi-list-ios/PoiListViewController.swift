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
    @IBOutlet weak var navBar: UIToolbar!
    var managedObjectContext: NSManagedObjectContext? = nil
   
    func setData(poiList: PoiListModel) {
        titleView.text = poiList.title
        infoView.text = poiList.info
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed() {
        // check here if we're editing an object or creating a new one.
        insertNewObject();
        dismiss(animated: true, completion: nil)
    }
    
    func insertNewObject() {
        let context = self.managedObjectContext!
        let newPoiList = PoiListModel(context: context)
        newPoiList.timestamp = NSDate()
        newPoiList.title = titleView.text
        newPoiList.info = infoView.text
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func exit() {
        titleView.resignFirstResponder()
        infoView.resignFirstResponder()
    }
}
