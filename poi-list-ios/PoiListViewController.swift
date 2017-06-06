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
    var managedObjectContext: NSManagedObjectContext?
    var poiListModel: PoiListModel?
    
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
            if let navTitle = navItem {
                navTitle.title = "New List"
            }
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
            savePoiListModel(poiListModel: list, title: titleView.text, info: infoView.text, managedObjectContext: self.managedObjectContext)
        } else {
            insertNewPoiListModel(title:titleView.text, info:infoView.text, timestamp:getTimestamp(), managedObjectContext: self.managedObjectContext)
        }
        exit()
        dismiss(animated: true, completion: nil)
    }
    
    func exit() {
        titleView.resignFirstResponder()
        infoView.resignFirstResponder()
    }
}
