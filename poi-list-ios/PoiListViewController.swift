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
import CoreData

protocol PoiListViewControllerDelegate: AnyObject {
    func poiListViewController(poiListViewController: PoiListViewController, updatedTitle: String?)
}

class PoiListViewController: UIViewController {

    @IBOutlet weak var titleView: UITextField!
    @IBOutlet weak var infoView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    var managedObjectContext: NSManagedObjectContext?
    var poiListModel: PoiListModel?
    weak var delegate: PoiListViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.becomeFirstResponder()
        if let list = poiListModel {
            if let navTitle = navItem {
                navTitle.title = list.title
            }
            titleView.text = list.title
            infoView.text = list.info
        } else if let navTitle = navItem {
            navTitle.title = "New List"
        }

        infoView.layer.borderColor = UIColor.gray.cgColor
        infoView.layer.borderWidth = 1.0
        infoView.layer.cornerRadius = 6
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private methods

    func exit() {
        titleView.resignFirstResponder()
        infoView.resignFirstResponder()
    }

    // MARK: - Actions

    @IBAction func cancelButtonPressed() {
        exit()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed() {
        if let list = poiListModel {
            savePoiListModel(poiListModel: list,
                             title: titleView.text,
                             info: infoView.text,
                             managedObjectContext: managedObjectContext)
        } else {
            insertNewPoiListModel(title: titleView.text,
                                  info: infoView.text,
                                  timestamp: timestampAsString(),
                                  managedObjectContext: managedObjectContext)
        }
        exit()
        delegate?.poiListViewController(poiListViewController: self, updatedTitle: titleView.text)
        dismiss(animated: true, completion: nil)
    }
}
