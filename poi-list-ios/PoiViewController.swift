//
//  PinViewController.swift
//  poilist
//
//  Created by Harry Lundstrom on 06/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import UIKit
import MapKit

class PoiViewController: UIViewController {

    var pinTitle: String = ""
    var pinSubtitle: String = ""
    var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    func setData(title: String, subtitle: String, location: CLLocationCoordinate2D) {
        pinTitle = title
        pinSubtitle = subtitle
        pinLocation = location
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
