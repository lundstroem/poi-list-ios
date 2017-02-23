//
//  AppDelegate.swift
//  poi-list-ios
//
//  Created by Harry Lundstrom on 12/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//


/*
 
 - add user location and decide how it should work. Zoom out once location is present, or do it manually with a button?
 - write tests
 
 */

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var managedObjectContext: NSManagedObjectContext?
    var importedPoiList: PoiList?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = self.persistentContainer.viewContext
        self.managedObjectContext = self.persistentContainer.viewContext
        return true
    }
    
    func showActionLongpress(title: String) {
        let alertController = UIAlertController(title: nil, message: "A list called \(title) with the same timestamp already exists.", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.importedPoiList = nil
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "Save Copy", style: .default) { action in
            self.importedPoiList?.title += " copy"
            self.importedPoiList?.timestamp = getTimestamp()
            if let poiList = self.importedPoiList {
                importPoiList(poiList: poiList, managedObjectContext: self.managedObjectContext)
                self.importedPoiList = nil
            }
        }
        alertController.addAction(OKAction)
        let newSaveAction = UIAlertAction(title: "Overwrite", style: .destructive) { action in
            if let poiList = self.importedPoiList {
                deletePoiList(poiList: poiList, managedObjectContext: self.managedObjectContext)
                importPoiList(poiList: poiList, managedObjectContext: self.managedObjectContext)
                self.importedPoiList = nil
            }
        }
        alertController.addAction(newSaveAction)
        self.window?.rootViewController?.present(alertController, animated: true) {
        }
    }
    
    func importList(contents: String) {
        if let data = contents.data(using: String.Encoding.utf8) {
            if let moc = managedObjectContext {
                if let poiList = parsePoiListJSON(data: data) {
                    let exists = checkIfPoiListExists(poiList: poiList, managedObjectContext: moc)
                    if(exists) {
                        self.importedPoiList = poiList
                        showActionLongpress(title:poiList.title)
                    } else {
                        importPoiList(poiList: poiList, managedObjectContext: moc)
                    }
                }
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        do {
            let contents = try String(contentsOf: url)
            importList(contents:contents)
        } catch {
            // contents could not be loaded
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return true
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "poi_list_ios")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print("Unresolved error \(error), \(error.userInfo)")
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
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

