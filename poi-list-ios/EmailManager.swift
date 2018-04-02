/*
 
 This is free and unencumbered software released into the public domain.
 
 Anyone is free to copy, modify, publish, use, compile, sell, or
 distribute this software, either in source code form or as a compiled
 binary, for any purpose, commercial or non-commercial, and by any
 means.
 
 In jurisdictions that recognize copyright laws, the author or authors
 of this software dedicate any and all copyright interest in the
 software to the public domain. We make this dedication for the benefit
 of the public at large and to the detriment of our heirs and
 successors. We intend this dedication to be an overt act of
 relinquishment in perpetuity of all present and future rights to this
 software under copyright law.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 For more information, please refer to <http://unlicense.org>
 
 */

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

