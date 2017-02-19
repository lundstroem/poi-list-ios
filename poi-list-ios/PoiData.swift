//
//  File.swift
//  poilist
//
//  Created by Harry Lundstrom on 07/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import Foundation
import MapKit

/*
var pinID: Int = 0
let lists_key = "songs"
let debug = true

class PoiList {
    var name: String
    var created: String
    var pinArray: [Pin]
    init(name: String, created: String, array: [Pin]) {
        self.name = name
        self.created = created
        self.pinArray = array
    }
    func addPin(pin: Pin) {
        self.pinArray.append(pin)
    }
    func removePin(pinID: Int) {
        self.pinArray.remove(at: pinID)
    }
}

class Pin {
    var id: Int
    var title: String
    var subtitle: String
    var location: CLLocationCoordinate2D
    init(title: String, subtitle: String, location: CLLocationCoordinate2D) {
        self.id = pinID
        self.title = title
        self.subtitle = subtitle
        self.location = location
        pinID+=1
    }
}

func debugLog(str: String) {
    if(debug) {
        print(str)
    }
}

class PoiDataManager: NSObject {
    
    private static var poiLists:[PoiList]? = nil
    
    static func newList(name: String) -> PoiList {
        let time_s_double: Double = NSDate().timeIntervalSince1970
        let time_ms_string: String = String(format:"%f", time_s_double*1000)
        let list = PoiList(name:name, created:time_ms_string, array:[Pin]())
        saveList(list: list)
        return list
    }

    static func saveList(list: PoiList) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: list, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                print(JSONString)
            }
            if(!listExists(list: list)) {
                addListToDefaults(list: list)
            }
            let fileName = list.name+"_"+list.created+".json"
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
            do {
                try jsonData.write(to: fileURL, options: .atomic)
            } catch {
                print(error)
            }
            
        } catch let error as NSError {
            print(error.description)
        }
    }

    static func deleteList(list: PoiList) {
        let fileName = list.name+"_"+list.created+".json"
        if(listExists(list:list)) {
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            guard let dirPath = paths.first else {
                return
            }
            //let filePath = "\(dirPath)/\(fileName)"
            let filePath = dirPath + fileName
            do {
                try FileManager.default.removeItem(atPath: filePath)
                debugLog(str:"trying to delete list:"+filePath)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            removeListFromDefaults(list: list)
        } else {
            debugLog(str:"cannot delete list because it does not exist:"+fileName)
        }
    }

    static func getLists() -> [PoiList]? {
        if(poiLists == nil) {
            let defaults = UserDefaults.standard
            if let optionalStringArray = defaults.array(forKey: lists_key) {
                for optionalString in optionalStringArray {
                    if let str = optionalString as? String {
                        debugLog(str: "list exists:"+str)
                        
                    }
                }
            }
        }
        return nil
    }
    
    private static func listFromJsonFile(fileName: String) -> PoiList? {
       let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
        
        do {
            let jsonData = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
            var allEntries = [[String:Any]]()
            
              //  allEntries = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String:Any]]
        }
        catch  let error as NSError {
            print(error.debugDescription)
        }
        
        
        /*
         let jsonData = try JSONSerialization.data(withJSONObject: list, options: JSONSerialization.WritingOptions.prettyPrinted)
         if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
         print(JSONString)
         }
         */
        return nil
    }

    private static func listExists(list: PoiList) -> Bool {
        let defaults = UserDefaults.standard
        let name_str = list.name + "_" + list.created + ".json"
        if let optionalStringArray = defaults.array(forKey: lists_key) {
            for optionalString in optionalStringArray {
                if let str = optionalString as? String {
                    debugLog(str: "list exists:"+str)
                    if(name_str == str) {
                        return true
                    }
                }
            }
        }
        debugLog(str:"list does not exist:"+name_str)
        return false;
    }

    private static func addListToDefaults(list: PoiList) {
        let defaults = UserDefaults.standard
        let name_str = list.name + "_" + list.created + ".json"
        var optionalStringArray = defaults.array(forKey: lists_key) as! [String]
        optionalStringArray.append(name_str)
        debugLog(str:"adding list:"+name_str)
        defaults.synchronize()
    }

    private static func removeListFromDefaults(list: PoiList) {
        let defaults = UserDefaults.standard
        let name_str = list.name + "_" + list.created + ".json"
        var index = -1
        var optionalStringArray = defaults.array(forKey: lists_key) as! [String]
        for i in 0 ..< optionalStringArray.count {
            if(name_str == optionalStringArray[i]) {
                debugLog(str:"removing list:"+name_str)
                index = i
                break
            }
        }
        if(index > -1) {
            optionalStringArray.remove(at: index)
        }
        defaults.synchronize()
    }
}
*/

