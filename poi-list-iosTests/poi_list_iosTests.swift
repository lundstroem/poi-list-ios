//
//  poi_list_iosTests.swift
//  poi-list-iosTests
//
//  Created by Harry Lundstrom on 12/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

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
