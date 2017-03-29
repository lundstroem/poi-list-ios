//
//  poi_list_iosTests.swift
//  poi-list-iosTests
//
//  Created by Harry Lundstrom on 12/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

/*
 manual tests required for complete coverage:
 
 - Import JSON file from e-mail:
       Cancel: No list should be added.
    Save Copy: A list with a new name should be created.
    Overwrite: The existing list should be replaced with the new one.
 
 - Move pin to red X on map:
    The pin should be deleted.
 
 - Export
 
 - Any more?
 
 */

import XCTest
import CoreData
@testable import poi_list_ios

class poi_list_iosTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testImport() {
        
        // import mock list
        let moc = setUpInMemoryManagedObjectContext()
        let mock1 = Bundle.main.url(forResource: "mockList1", withExtension:"poilist", subdirectory:nil)
        if let mock1ListString = getStringContentResource(url: mock1!) {
            let state = importListFromData(contents:mock1ListString, managedObjectContext: moc)
            if(state == ImportState.success) {
                print("import success")
            } else if(state == ImportState.exists) {
                XCTFail("expected importstate success")
            } else if(state == ImportState.failed) {
                XCTFail("expected importstate success")
            }
        } else {
            XCTFail("mock list import error")
        }
        
        // import same mock list, expected state is "exists"
        let mock2 = Bundle.main.url(forResource: "mockList1", withExtension:"poilist", subdirectory:nil)
        if let mock2ListString = getStringContentResource(url: mock2!) {
            let state = importListFromData(contents:mock2ListString, managedObjectContext: moc)
            if(state == ImportState.success) {
                XCTFail("expected importstate exists")
            } else if(state == ImportState.exists) {
                print("import exists")
            } else if(state == ImportState.failed) {
                XCTFail("expected importstate exists")
            }
        } else {
            XCTFail("mock list import error")
        }
        
        importActionCancel()

        let importResult = importActionSaveCopy(managedObjectContext: moc)
        if(importResult == true) {
            XCTFail("should not be able to save because we canceled the import.")
        }
        
        // import same mock list again, expected state is "exists"
        let mock3 = Bundle.main.url(forResource: "mockList1", withExtension:"poilist", subdirectory:nil)
        if let mock3ListString = getStringContentResource(url: mock3!) {
            let state = importListFromData(contents:mock3ListString, managedObjectContext: moc)
            if(state == ImportState.success) {
                XCTFail("expected importstate exists")
            } else if(state == ImportState.exists) {
                print("import exists")
            } else if(state == ImportState.failed) {
                XCTFail("expected importstate exists")
            }
        } else {
            XCTFail("mock list import error")
        }
        
        let importResult1 = importActionSaveCopy(managedObjectContext: moc)
        if(importResult1 == false) {
            XCTFail("could not save copy of list.")
        }
        
        // import same mock list again
        let mock4 = Bundle.main.url(forResource: "mockList1", withExtension:"poilist", subdirectory:nil)
        if let mock4ListString = getStringContentResource(url: mock4!) {
            let state = importListFromData(contents:mock4ListString, managedObjectContext: moc)
            if(state == ImportState.success) {
                XCTFail("expected importstate exists")
            } else if(state == ImportState.exists) {
                print("import exists")
            } else if(state == ImportState.failed) {
                XCTFail("expected importstate exists")
            }
        } else {
            XCTFail("mock list import error")
        }
        
        let importResult2 = importActionOverwrite(managedObjectContext: moc)
        if(importResult2 == false) {
            XCTFail("could not overwrite list.")
        }
        
        // import new mock list
        let mock5 = Bundle.main.url(forResource: "mockList2", withExtension:"poilist", subdirectory:nil)
        if let mock5ListString = getStringContentResource(url: mock5!) {
            let state = importListFromData(contents:mock5ListString, managedObjectContext: moc)
            if(state == ImportState.success) {
                print("import success")
            } else if(state == ImportState.exists) {
                XCTFail("expected importstate success")
            } else if(state == ImportState.failed) {
                XCTFail("expected importstate success")
            }
        } else {
            XCTFail("mock list import error")
        }
    }
    
    func testCoreData() {
        // create PoiListModel
        let moc = setUpInMemoryManagedObjectContext()
        let poiListTitle = "poi list title"
        let poiListInfo = "poi list info"
        let poiListTimestamp = getTimestamp()
        let poiListModel = insertNewPoiListModel(title: poiListTitle, info: poiListInfo, timestamp: poiListTimestamp, managedObjectContext: moc)
        XCTAssertTrue(poiListModel?.title == poiListTitle)
        XCTAssertTrue(poiListModel?.info == poiListInfo)
        XCTAssertTrue(poiListModel?.timestamp == poiListTimestamp)
        
        // create PoiModel
        let poiTitle = "poi title"
        let poiInfo = "poi info"
        let poiLat = 40.741895
        let poiLong = -73.989308
        let poiModel = insertNewPoiModel(title: poiTitle, info: poiInfo, lat: poiLat, long: poiLong, poiListModel: poiListModel, managedObjectContext: moc)
        XCTAssertTrue(poiModel?.title == poiTitle)
        XCTAssertTrue(poiModel?.info == poiInfo)
        XCTAssertTrue(poiModel?.lat == poiLat)
        XCTAssertTrue(poiModel?.long == poiLong)
        
        // delete PoiModel
        XCTAssertTrue(deletePoiModel(poiModel: poiModel!, managedObjectContext: moc))
        
        // delete PoiListModel
        XCTAssertTrue(deletePoiListModel(poiListModel: poiListModel!, managedObjectContext: moc))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
