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
        let copyLinkButton = UIBarButtonItem(title: "link",
                                             style: .plain,
                                             target: self,
                                             action: #selector(copyLink(_:)))
        navigationItem.rightBarButtonItem = copyLinkButton
        titleView.becomeFirstResponder()

        infoView.layer.borderColor = UIColor.gray.cgColor
        infoView.layer.borderWidth = 1.0
        infoView.layer.cornerRadius = 6
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let poi = poiModel else {
            return
        }
        titleView.text = poi.title
        infoView.text = poi.info
        navigationItem.title = titleView.text
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        savePoiModel(poiModel: poiModel,
                     title: titleView.text,
                     info: infoView.text,
                     lat: nil,
                     long: nil,
                     managedObjectContext: managedObjectContext)
    }

    @objc func copyLink(_ sender: Any) {
        guard let model = poiModel else {
            return
        }
        let gmapsUrl = """
        http://maps.google.com/maps?q=\(model.lat),
        \(model.long)+(Point))&z=14&11=\(model.lat),\(model.long)
        """
        UIPasteboard.general.string = gmapsUrl
        presentCopiedLinkAlert(url: gmapsUrl)
    }

    private func presentCopiedLinkAlert(url: String) {
        let alertController = UIAlertController(title: "Google Maps link copied to clipboard",
                                                message: url,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func exit() {
        titleView.resignFirstResponder()
        infoView.resignFirstResponder()
    }
}
