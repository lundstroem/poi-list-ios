//
//  AppDelegate.swift
//  poi-list-ios
//
//  Created by Harry Lundstrom on 12/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var managedObjectContext: NSManagedObjectContext?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let masterNavigationController = window?.rootViewController as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = persistentContainer.viewContext
        managedObjectContext = persistentContainer.viewContext
        if ProcessInfo.processInfo.arguments.contains("UITEST") {
            print("UITEST running")
            managedObjectContext = setUpInMemoryManagedObjectContext()
            controller.managedObjectContext = managedObjectContext
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let contents = stringContentResource(url:url) {
            let state = importListFromJSONData(contents:contents, managedObjectContext: managedObjectContext)
            switch state {
                case ImportState.success:
                    print("import success")
                case ImportState.exists:
                    if let poiList = importedList() {
                        showAlertControllerForDuplicate(title: poiList.title)
                    }
                case ImportState.failed:
                    print("import failed")
            }
        }
        return false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "poi_list_ios")
        weak var weakSelf = self
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                guard let strongSelf = weakSelf else {
                    return
                }
                strongSelf.presentErrorAlert(message:"Persistent container error \(error.localizedDescription), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                presentErrorAlert(message:"Unresolved error \(error.localizedDescription), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Private
    
    private func presentErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        window?.rootViewController?.present(alertController, animated: true)
    }
    
    func showAlertControllerForDuplicate(title: String) {
        let alertController = UIAlertController(title: nil, message: "A list called \(title) with the same timestamp already exists.", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            importActionCancel()
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "Save Copy", style: .default) { [unowned self] action in
            importActionSaveCopy(managedObjectContext: self.managedObjectContext)
        }
        alertController.addAction(OKAction)
        let newSaveAction = UIAlertAction(title: "Overwrite", style: .destructive) { [unowned self] action in
            importActionOverwrite(managedObjectContext: self.managedObjectContext)
        }
        alertController.addAction(newSaveAction)
        window?.rootViewController?.present(alertController, animated: true) {
        }
    }
}

// MARK: - Split view

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController: UIViewController) -> Bool {
    return true
    }
}

