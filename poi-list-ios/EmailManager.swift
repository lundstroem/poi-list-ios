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

public class EmailManager : NSObject {
  
    private var mailComposeViewController: MFMailComposeViewController?
    
    public override init() {
        mailComposeViewController = MFMailComposeViewController()
    }
    
    private func cycleMailComposer() {
        mailComposeViewController = nil
        mailComposeViewController = MFMailComposeViewController()
    }
    
    public func sendMailTo(subject:String, body:String, attachment:String?, fromViewController:UIViewController) -> Bool {
        if MFMailComposeViewController.canSendMail() {
            if let composer = mailComposeViewController {
                composer.setSubject(subject)
                composer.setMessageBody(body, isHTML: true)
                if let attach = attachment {
                    let attachmentNSString = attach as NSString
                    let attachmentNSData = attachmentNSString.data(using: String.Encoding.utf8.rawValue)!
                    composer.addAttachmentData(attachmentNSData, mimeType: "application/json", fileName: "list.poilist")
                }
                composer.mailComposeDelegate = self
                fromViewController.present(composer, animated: true, completion: nil)
                return true
            }
        }
        return false
    }
}

// MARK: MailComposeController delegate

extension EmailManager : MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { () -> Void in
            self.cycleMailComposer()
        }
    }
}

