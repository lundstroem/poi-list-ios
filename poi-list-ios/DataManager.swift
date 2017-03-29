//
//  DataManager.swift
//  poi-list-ios
//
//  Created by Harry Lundstrom on 23/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import Foundation
import CoreData

/* JSONSerializable:
 http://www.sthoughts.com/2016/06/30/swift-3-serializing-swift-structs-to-json/
 */
protocol JSONRepresentable {
    var JSONRepresentation: Any { get }
}

protocol JSONSerializable: JSONRepresentable {
}

extension JSONSerializable {
    var JSONRepresentation: Any {
        var representation = [String: Any]()
        for case let (label?, value) in Mirror(reflecting: self).children {
            switch value {
            case let value as Dictionary<String, Any>:
                representation[label] = value as AnyObject
            case let value as Array<Any>:
                if let val = value as? [JSONSerializable] {
                    representation[label] = val.map({ $0.JSONRepresentation as AnyObject }) as AnyObject
                } else {
                    representation[label] = value as AnyObject
                }
            case let value:
                representation[label] = value as AnyObject
            }
        }
        return representation as Any
    }
}

extension JSONSerializable {
    func toJSON() -> String? {
        let representation = JSONRepresentation
        guard JSONSerialization.isValidJSONObject(representation) else {
            print("Invalid JSON Representation")
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

struct PoiList: JSONSerializable {
    var title: String
    var info: String
    var timestamp: String
    var pois: [JSONSerializable]
}

struct Poi: JSONSerializable {
    var title: String
    var info: String
    var lat: Double
    var long: Double
}

func getPoiListAsJSON(poiListModel: PoiListModel?, managedObjectContext: NSManagedObjectContext?) -> String? {
    if let list = poiListModel {
        if let moc = managedObjectContext {
            let pois = fetchPois(poiListModel:poiListModel, managedObjectContext:moc)
            var poiModels: [Poi] = []
            for poi in pois {
                var title = "title"
                if let p_title = poi.title {
                    title = p_title
                }
                let info = "info"
                if let p_info = poi.info {
                    title = p_info
                }
                poiModels.insert(Poi(title:title, info:info, lat:poi.lat, long:poi.long), at: 0)
            }
            var title = "title"
            if let p_title = list.title {
                title = p_title
            }
            var info = "info"
            if let p_info = list.info {
                info = p_info
            }
            var timestamp = "timestamp"
            if let p_timestamp = list.timestamp {
                timestamp = p_timestamp
            }
            let list = PoiList(title: title, info:info, timestamp: timestamp, pois:poiModels)
            if let json = list.toJSON() {
                print(json)
                return json
            }
        }
    }
    return nil
}

func parsePoiListJSON(data: Data) -> PoiList? {
    do {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let pois = json["pois"] as? [[String: Any]] {
            var title = "title"
            if let p_title = json["title"] as? String {
                title = p_title
            }
            var info = "info"
            if let p_info = json["info"] as? String {
                info = p_info
            }
            var timestamp = "timestamp"
            if let p_timestamp = json["timestamp"] as? String {
                timestamp = p_timestamp
            }
            var poiModels: [Poi] = []
            for poi in pois {
                var title = "title"
                if let p_title = poi["title"] as? String {
                    title = p_title
                }
                var info = "info"
                if let p_info = poi["info"] as? String {
                    info = p_info
                }
                var lat: Double = 0
                if let p_lat = poi["lat"] as? Double {
                    lat = p_lat
                }
                var long: Double = 0
                if let p_long = poi["long"] as? Double {
                    long = p_long
                }
                poiModels.insert(Poi(title:title, info:info, lat:lat, long:long), at: 0)
            }
            let poiList = PoiList(title:title, info:info, timestamp:timestamp, pois: poiModels)
            return poiList
        }
    } catch {
        print("Error deserializing JSON: \(error)")
    }
    return nil
}

func fetchPois(poiListModel: PoiListModel?, managedObjectContext: NSManagedObjectContext?) -> [PoiModel] {
    let poiFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiModel")
    if let moc = managedObjectContext {
        if let listModel = poiListModel {
            poiFetch.predicate = NSPredicate(format: "list == %@", listModel)
            do {
                let poisFetched = try moc.fetch(poiFetch) as! [PoiModel]
                return poisFetched
            } catch {
                print("Failed to fetch POIs: \(error)")
            }
        }
    }
    let emptyArray: [PoiModel] = []
    return emptyArray
}

func getTimestamp() -> String {
    let timestamp_double:Double = NSDate().timeIntervalSince1970 * 1000
    let timestamp: String = "\(timestamp_double)"
    return timestamp
}

func checkIfPoiListExists(poiList: PoiList, managedObjectContext: NSManagedObjectContext?) -> Bool {
    let poiListFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiListModel")
    if let moc = managedObjectContext {
        poiListFetch.predicate = NSPredicate(format: "timestamp == %@", poiList.timestamp)
        do {
            let poiListsFetched = try moc.fetch(poiListFetch) as! [PoiListModel]
            if(poiListsFetched.count > 0) {
                return true
            }
        } catch {
            print("Failed to check if PoiList exists: \(error)")
        }
    }
    return false
}

@discardableResult func deletePoiList(poiList: PoiList, managedObjectContext: NSManagedObjectContext?) -> Bool {
    let poiListFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiListModel")
    if let moc = managedObjectContext {
        poiListFetch.predicate = NSPredicate(format: "timestamp == %@", poiList.timestamp)
        do {
            let poiListsFetched = try moc.fetch(poiListFetch) as! [PoiListModel]
            if(poiListsFetched.count > 0) {
                deletePoiListModel(poiListModel: poiListsFetched[0], managedObjectContext: managedObjectContext)
            }
        } catch {
            print("Failed to delete PoiList: \(error)")
            return false
        }
    }
    return true
}

@discardableResult func deletePoiListModel(poiListModel: PoiListModel, managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let moc = managedObjectContext {
        moc.delete(poiListModel)
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    return true
}

@discardableResult func deletePoiModel(poiModel: PoiModel, managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let moc = managedObjectContext {
        moc.delete(poiModel)
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    return true
}

@discardableResult func importPoiList(poiList: PoiList, managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let moc = managedObjectContext {
        if let poiListModel = insertNewPoiListModel(title: poiList.title, info: poiList.info, timestamp: poiList.timestamp, managedObjectContext: moc) {
            for poi in poiList.pois as! [Poi] {
                let poiModel = insertNewPoiModel(title: poi.title, info: poi.info, lat: poi.lat, long: poi.long, poiListModel: poiListModel, managedObjectContext: moc)
                if(poiModel == nil) {
                    return false
                }
            }
        } else {
            return false
        }
    }
    return true
}

func savePoiModel(poiModel: PoiModel?, title: String?, info: String?, lat: Double?, long: Double?, managedObjectContext: NSManagedObjectContext?) {
    if let poi = poiModel {
        poi.title = title
        poi.info = info
        if let latitude = lat {
            poi.lat = latitude
        }
        if let longitude = long {
            poi.long = longitude
        }
        if(poi.title == nil || poi.title == "") {
            poi.title = "title"
        }
        if let moc = managedObjectContext {
            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

func savePoiListModel(poiListModel: PoiListModel, title: String?, info: String?, managedObjectContext: NSManagedObjectContext?) {
    if let moc = managedObjectContext {
        poiListModel.title = title
        poiListModel.info = info
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

@discardableResult func insertNewPoiModel(title: String?, info: String?, lat: Double, long: Double, poiListModel: PoiListModel?, managedObjectContext: NSManagedObjectContext?) -> PoiModel? {
    if let moc = managedObjectContext {
        if let poiList = poiListModel {
            let newPoi = PoiModel(context: moc)
            newPoi.title = title
            newPoi.info = info
            newPoi.lat = lat
            newPoi.long = long
            newPoi.list = poiList
            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            return newPoi
        }
    }
    return nil
}

func insertNewPoiListModel(title: String?, info: String?, timestamp: String, managedObjectContext: NSManagedObjectContext?) -> PoiListModel? {
    if let moc = managedObjectContext {
        let newPoiList = PoiListModel(context: moc)
        newPoiList.timestamp = timestamp
        newPoiList.title = title
        newPoiList.info = info
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return newPoiList
    }
    return nil
}

// import

private var importedPoiList: PoiList?

enum ImportState {
    case failed
    case success
    case exists
}

func getStringContentResource(url: URL) -> String? {
    do {
        let contents = try String(contentsOf: url)
        return contents
    } catch {
        return nil
    }
}

func importActionCancel() {
    importedPoiList = nil
}

@discardableResult func importActionSaveCopy(managedObjectContext: NSManagedObjectContext?) -> Bool {
    if(importedPoiList == nil) {
        return false
    }
    importedPoiList?.title += " copy"
    importedPoiList?.timestamp = getTimestamp()
    if let poiList = importedPoiList {
        let result = importPoiList(poiList: poiList, managedObjectContext: managedObjectContext)
        importedPoiList = nil
        return result
    }
    return false
}

@discardableResult func importActionOverwrite(managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let poiList = importedPoiList {
        let deleteResult = deletePoiList(poiList: poiList, managedObjectContext: managedObjectContext)
        let importResult = importPoiList(poiList: poiList, managedObjectContext: managedObjectContext)
        importedPoiList = nil
        if(deleteResult == true && importResult == true) {
            return true
        }
    }
    return false
}

func setImportedList(list: PoiList) {
    importedPoiList = list
}

func getImportedList() -> PoiList? {
    return importedPoiList
}

@discardableResult func importListFromData(contents: String, managedObjectContext: NSManagedObjectContext?) -> ImportState {
    if let data = contents.data(using: String.Encoding.utf8) {
        if let moc = managedObjectContext {
            if let poiList = parsePoiListJSON(data: data) {
                let exists = checkIfPoiListExists(poiList: poiList, managedObjectContext: moc)
                if(exists) {
                    importedPoiList = poiList
                    return ImportState.exists
                } else {
                    let success = importPoiList(poiList: poiList, managedObjectContext: moc)
                    if(success == true) {
                        return ImportState.success
                    } else {
                        return ImportState.failed
                    }
                }
            }
        }
    }
    return ImportState.failed
}



