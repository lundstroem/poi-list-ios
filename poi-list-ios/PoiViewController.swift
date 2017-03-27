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
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastLabel: UILabel!
    var managedObjectContext: NSManagedObjectContext?
    var poiModel: PoiModel?
    var toastFinished : Bool = true
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let copyLinkButton = UIBarButtonItem(title: "link", style: .plain, target: self, action: #selector(copyLink(_:)))
        self.navigationItem.rightBarButtonItem = copyLinkButton
        self.toastView.isHidden = true
        titleView.becomeFirstResponder()
    }

    func savePoi() {
        savePoiModel(poiModel: poiModel, title: self.titleView.text, info: self.infoView.text, lat:nil, long:nil, managedObjectContext: managedObjectContext)
    }
    
    func copyLink(_ sender: Any) {
        if let model = poiModel {
            let gmapsUrl = "http://maps.google.com/maps?q=\(model.lat),\(model.long)+(Point))&z=14&11=\(model.lat),\(model.long)"
            UIPasteboard.general.string = gmapsUrl
            showToast(text: "google maps link copied to clipboard")
        }
    }
    
    func showToast(text: String) {
        if(toastFinished) {
            toastFinished = false
            toastView.isHidden = false
            if let view = toastView {
                UIView.animate(withDuration: 0.5, animations: {
                    view.frame = CGRect(x:view.frame.origin.x, y:view.frame.origin.y+85, width:view.frame.width, height:view.frame.height)
                }, completion: { (finished: Bool) in
                    UIView.animate(withDuration: 2.0, animations: {
                        view.frame = CGRect(x:view.frame.origin.x, y:view.frame.origin.y-1, width:view.frame.width, height:view.frame.height)
                    }, completion: { (finished: Bool) in
                        UIView.animate(withDuration: 0.5, animations: {
                            view.frame = CGRect(x:view.frame.origin.x, y:view.frame.origin.y-85, width:view.frame.width, height:view.frame.height)
                        }, completion: { (finished: Bool) in
                            self.toastFinished = true
                            self.toastView.isHidden = true
                        })
                    })
                })
                if let label = toastLabel {
                    label.text = text
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
