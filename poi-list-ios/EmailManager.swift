//
//  EmailManager.swift
//  poi-list-ios
//
//  Created by Harry Lundstrom on 22/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

public class EmailManager : NSObject, MFMailComposeViewControllerDelegate {
  
    var mailComposeViewController: MFMailComposeViewController?
    
    public override init() {
        mailComposeViewController = MFMailComposeViewController()
    }
    
    private func cycleMailComposer() {
        mailComposeViewController = nil
        mailComposeViewController = MFMailComposeViewController()
    }
    
    public func sendMailTo(subject:String, body:String, attachment:String?, fromViewController:UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            if let composer = mailComposeViewController {
                composer.setSubject(subject)
                composer.setMessageBody(body, isHTML: true)
                if let attach = attachment {
                    let myNSString = attach as NSString
                    let myNSData = myNSString.data(using: String.Encoding.utf8.rawValue)!
                    composer.addAttachmentData(myNSData, mimeType: "application/json", fileName: "list.poilist")
                }
                composer.mailComposeDelegate = self
                fromViewController.present(composer, animated: true, completion: nil)
            }
        }
        else {
            print("Could not open email app")
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { () -> Void in
            self.cycleMailComposer()
        }
    }
}

