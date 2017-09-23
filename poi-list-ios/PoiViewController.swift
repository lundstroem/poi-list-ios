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
    var managedObjectContext: NSManagedObjectContext?
    var poiModel: PoiModel?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let copyLinkButton = UIBarButtonItem(title: "link", style: .plain, target: self, action: #selector(copyLink(_:)))
        self.navigationItem.rightBarButtonItem = copyLinkButton
        titleView.becomeFirstResponder()
    }
    
    @objc func copyLink(_ sender: Any) {
        if let model = poiModel {
            let gmapsUrl = "http://maps.google.com/maps?q=\(model.lat),\(model.long)+(Point))&z=14&11=\(model.lat),\(model.long)"
            UIPasteboard.general.string = gmapsUrl
            showCopiedLinkDialog(url: gmapsUrl)
        }
    }
    
    func showCopiedLinkDialog(url: String) {
        let alertController = UIAlertController(title: "Google Maps link copied to clipboard", message: url, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let poi = poiModel {
            self.titleView.text = poi.title
            self.infoView.text = poi.info
            self.navigationItem.title = self.titleView.text
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        savePoiModel(poiModel: poiModel, title: self.titleView.text, info: self.infoView.text, lat: nil, long: nil, managedObjectContext: managedObjectContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func exit() {
        titleView.resignFirstResponder()
        infoView.resignFirstResponder()
    }
}
