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
import CoreData

func fetchPois(poiListModel: PoiListModel?, managedObjectContext: NSManagedObjectContext?) -> [PoiModel] {
    let emptyArray: [PoiModel] = []
    guard let moc = managedObjectContext, let listModel = poiListModel else {
        return emptyArray
    }
    let poiFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiModel")
    poiFetch.predicate = NSPredicate(format: "list == %@", listModel)
    do {
        if let poisFetched = try moc.fetch(poiFetch) as? [PoiModel] {
            return poisFetched
        }
    } catch let error as NSError {
        print("Failed to fetch POIs: \(error.localizedDescription), \(error.userInfo)")
    }
    return emptyArray
}

func timestampAsString() -> String {
    let timestampDouble: Double = NSDate().timeIntervalSince1970 * 1000
    let timestampInt = Int(timestampDouble)
    let timestamp: String = "\(timestampInt)"
    return timestamp
}

func poiListExists(poiList: PoiList, managedObjectContext: NSManagedObjectContext?) -> Bool {
    guard let moc = managedObjectContext else {
        return false
    }
    let poiListFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiListModel")
    poiListFetch.predicate = NSPredicate(format: "timestamp == %@", poiList.timestamp)
    do {
        if let poiListsFetched = try moc.fetch(poiListFetch) as? [PoiListModel] {
            if poiListsFetched.count > 0 {
                return true
            }
        }
    } catch let error as NSError {
        print("Failed to check if PoiList exists: \(error.localizedDescription), \(error.userInfo)")
    }
    return false
}

// MARK: JSON handling

/* JSONSerializable:
 http://www.sthoughts.com/2016/06/30/swift-3-serializing-swift-structs-to-json/
 */

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
            case let value as [String: Any]:
                representation[label] = value as AnyObject
            case let value as [Any]:
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
    fileprivate func toJSON() -> String? {
        let representation = JSONRepresentation
        guard JSONSerialization.isValidJSONObject(representation) else {
            print("Invalid JSON Representation")
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            return String(data: data, encoding: .utf8)
        } catch let error as NSError {
            print("Error serializing JSON: \(error.localizedDescription), \(error.userInfo)")
            return nil
        }
    }
}

struct JSONKey {
    static let pois = "pois"
    static let title = "title"
    static let info = "info"
    static let lat = "lat"
    static let long = "long"
    static let timestamp = "timestamp"
}

func poiListAsJSON(poiListModel: PoiListModel?, managedObjectContext: NSManagedObjectContext?) -> String? {
    guard let poiListModel = poiListModel, let moc = managedObjectContext else {
        return nil
    }
    let pois = fetchPois(poiListModel: poiListModel, managedObjectContext: moc)
    var poiModels: [Poi] = []
    for poi in pois {
        var title = JSONKey.title
        if let pTitle = poi.title {
            title = pTitle
        }
        var info = JSONKey.info
        if let pInfo = poi.info {
            info = pInfo
        }
        poiModels.insert(Poi(title: title, info: info, lat: poi.lat, long: poi.long), at: 0)
    }
    var title = JSONKey.title
    if let pTitle = poiListModel.title {
        title = pTitle
    }
    var info = JSONKey.info
    if let pInfo = poiListModel.info {
        info = pInfo
    }
    var timestamp = JSONKey.timestamp
    if let pTimestamp = poiListModel.timestamp {
        timestamp = pTimestamp
    }
    let poiList = PoiList(title: title, info: info, timestamp: timestamp, pois: poiModels)
    if let json = poiList.toJSON() {
        print(json)
        return json
    }
    return nil
}

private func parsePoiListJSON(data: Data) -> PoiList? {
    do {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let pois = json["pois"] as? [[String: Any]] {
            var title = JSONKey.title
            if let pTitle = json[JSONKey.title] as? String {
                title = pTitle
            }
            var info = JSONKey.info
            if let pInfo = json[JSONKey.info] as? String {
                info = pInfo
            }
            var timestamp = JSONKey.timestamp
            if let pTimestamp = json[JSONKey.timestamp] as? String {
                timestamp = pTimestamp
            }
            var poiModels: [Poi] = []
            for poi in pois {
                var title = JSONKey.title
                if let pTitle = poi[JSONKey.title] as? String {
                    title = pTitle
                }
                var info = JSONKey.info
                if let pInfo = poi[JSONKey.info] as? String {
                    info = pInfo
                }
                var lat: Double = 0
                if let pLat = poi[JSONKey.lat] as? Double {
                    lat = pLat
                }
                var long: Double = 0
                if let pLong = poi[JSONKey.long] as? Double {
                    long = pLong
                }
                poiModels.insert(Poi(title: title, info: info, lat: lat, long: long), at: 0)
            }
            let poiList = PoiList(title: title, info: info, timestamp: timestamp, pois: poiModels)
            return poiList
        }
    } catch let error as NSError {
        print("Error deserializing JSON: \(error.localizedDescription), \(error.userInfo)")
    }
    return nil
}

// MARK: Model handling

func poiListModelForTimestamp(timestamp: String, managedObjectContext: NSManagedObjectContext?) -> PoiListModel? {
    let poiListFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiListModel")
    if let moc = managedObjectContext {
        poiListFetch.predicate = NSPredicate(format: "\(JSONKey.timestamp) == %@", timestamp)
        do {
            if let poiListsFetched = try moc.fetch(poiListFetch) as? [PoiListModel] {
                if poiListsFetched.count == 1 {
                    return poiListsFetched.first
                } else {
                    return nil
                }
            }
        } catch let error as NSError {
            print("Failed to check if PoiList exists: \(error.localizedDescription), \(error.userInfo)")
            return nil
        }
    }
    return nil
}

@discardableResult func insertNewPoiListModel(title: String?,
                                              info: String?,
                                              timestamp: String,
                                              managedObjectContext: NSManagedObjectContext?) -> PoiListModel? {
    if let moc = managedObjectContext {
        let newPoiList = PoiListModel(context: moc)
        newPoiList.timestamp = timestamp
        newPoiList.title = title
        newPoiList.info = info
        do {
            try moc.save()
        } catch let error as NSError {
            print("Failed to insert new PoiListModel \(error.localizedDescription), \(error.userInfo)")
            return nil
        }
        return newPoiList
    }
    return nil
}

func insertNewPoiModel(title: String?,
                       info: String?,
                       lat: Double,
                       long: Double,
                       poiListModel: PoiListModel?,
                       managedObjectContext: NSManagedObjectContext?) -> PoiModel? {
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
            } catch let error as NSError {
                print("Failed to insert new PoiModel \(error.localizedDescription), \(error.userInfo)")
                return nil
            }
            return newPoi
        }
    }
    return nil
}

@discardableResult func savePoiListModel(poiListModel: PoiListModel,
                                         title: String?,
                                         info: String?,
                                         managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let moc = managedObjectContext {
        poiListModel.title = title
        poiListModel.info = info
        do {
            try moc.save()
        } catch let error as NSError {
            print("Failed to save PoiListModel \(error.localizedDescription), \(error.userInfo)")
            return false
        }
        return true
    }
    return false
}

@discardableResult func savePoiModel(poiModel: PoiModel?,
                                     title: String?,
                                     info: String?,
                                     lat: Double?,
                                     long: Double?,
                                     managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let poi = poiModel {
        poi.title = title
        poi.info = info
        if let latitude = lat {
            poi.lat = latitude
        }
        if let longitude = long {
            poi.long = longitude
        }
        if poi.title == nil || poi.title == "" {
            poi.title = JSONKey.title
        }
        if let moc = managedObjectContext {
            do {
                try moc.save()
            } catch let error as NSError {
                print("Failed to save PoiModel \(error.localizedDescription), \(error.userInfo)")
                return false
            }
            return true
        }
    }
    return false
}

@discardableResult func deletePoiModel(poiModel: PoiModel, managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let moc = managedObjectContext {
        moc.delete(poiModel)
        do {
            try moc.save()
        } catch let error as NSError {
            print("Failed to delete PoiModel \(error.localizedDescription), \(error.userInfo)")
            return false
        }
        return true
    }
    return false
}

@discardableResult func deletePoiListModel(poiListModel: PoiListModel,
                                           managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let moc = managedObjectContext {
        moc.delete(poiListModel)
        do {
            try moc.save()
        } catch let error as NSError {
            print("Failed to delete PoiListModel \(error.localizedDescription), \(error.userInfo)")
            return false
        }
        return true
    }
    return false
}

private func deletePoiList(poiList: PoiList, managedObjectContext: NSManagedObjectContext?) -> Bool {
    let poiListFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PoiListModel")
    if let moc = managedObjectContext {
        poiListFetch.predicate = NSPredicate(format: "\(JSONKey.timestamp) == %@", poiList.timestamp)
        do {
            if let poiListsFetched = try moc.fetch(poiListFetch) as? [PoiListModel] {
                if poiListsFetched.count > 0 {
                    deletePoiListModel(poiListModel: poiListsFetched[0], managedObjectContext: managedObjectContext)
                }
            }
        } catch let error as NSError {
            print("Failed to delete PoiList: \(error.localizedDescription), \(error.userInfo)")
            return false
        }
        return true
    }
    return false
}

// MARK: - Import

private var importedPoiList: PoiList?

enum ImportState {
    case failed
    case success
    case exists
}

private func importPoiList(poiList: PoiList, managedObjectContext: NSManagedObjectContext?) -> Bool {
    if let moc = managedObjectContext {
        if let poiListModel = insertNewPoiListModel(title: poiList.title,
                                                    info: poiList.info,
                                                    timestamp: poiList.timestamp,
                                                    managedObjectContext: moc) {
            guard let pois = poiList.pois as? [Poi] else {
                return false
            }
            for poi in pois {
                let poiModel = insertNewPoiModel(title: poi.title,
                                                 info: poi.info,
                                                 lat: poi.lat,
                                                 long: poi.long,
                                                 poiListModel: poiListModel,
                                                 managedObjectContext: moc)
                if poiModel == nil {
                    return false
                }
            }
            return true
        }
    }
    return false
}

func stringContentResource(url: URL) -> String? {
    do {
        let contents = try String(contentsOf: url)
        return contents
    } catch let error as NSError {
        print("Unresolved error \(error.localizedDescription), \(error.userInfo)")
        return nil
    }
}

func importActionCancel() {
    importedPoiList = nil
}

@discardableResult func importActionSaveCopy(managedObjectContext: NSManagedObjectContext?) -> Bool {
    if importedPoiList != nil {
        importedPoiList?.title += " copy"
        importedPoiList?.timestamp = timestampAsString()
    }
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
        if deleteResult == true && importResult == true {
            return true
        }
    }
    return false
}

func importedList() -> PoiList? {
    return importedPoiList
}

@discardableResult func importListFromJSONData(contents: String,
                                               managedObjectContext: NSManagedObjectContext?) -> ImportState {
    if let data = contents.data(using: String.Encoding.utf8) {
        if let moc = managedObjectContext {
            if let poiList = parsePoiListJSON(data: data) {
                let exists = poiListExists(poiList: poiList, managedObjectContext: moc)
                if exists {
                    importedPoiList = poiList
                    return ImportState.exists
                } else {
                    let success = importPoiList(poiList: poiList, managedObjectContext: moc)
                    if success {
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
