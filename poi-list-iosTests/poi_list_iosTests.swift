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

/*
 manual tests required for better test coverage:
 
 - Import JSON file from e-mail:
       Cancel: No list should be added.
    Save Copy: A list with a new name should be created.
    Overwrite: The existing list should be replaced with the new one.
 
 - Move pin to red X on map:
    The pin should be deleted.
 
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
        let mock1 = Bundle.main.url(forResource: "mockList1", withExtension: "poilist", subdirectory: nil)
        if let mock1ListString = stringContentResource(url: mock1!) {
            let state = importListFromJSONData(contents: mock1ListString, managedObjectContext: moc)
            if state == ImportState.success {
                print("import success")
            } else if state == ImportState.exists {
                XCTFail("expected importstate success")
            } else if state == ImportState.failed {
                XCTFail("expected importstate success")
            }
        } else {
            XCTFail("mock list import error")
        }

        // import same mock list, expected state is "exists"
        let mock2 = Bundle.main.url(forResource: "mockList1", withExtension: "poilist", subdirectory: nil)
        if let mock2ListString = stringContentResource(url: mock2!) {
            let state = importListFromJSONData(contents: mock2ListString, managedObjectContext: moc)
            if state == ImportState.success {
                XCTFail("expected importstate exists")
            } else if state == ImportState.exists {
                print("import exists")
            } else if state == ImportState.failed {
                XCTFail("expected importstate exists")
            }
        } else {
            XCTFail("mock list import error")
        }

        importActionCancel()

        let importResult = importActionSaveCopy(managedObjectContext: moc)
        if importResult {
            XCTFail("should not be able to save because we canceled the import.")
        }

        // import same mock list again, expected state is "exists"
        let mock3 = Bundle.main.url(forResource: "mockList1", withExtension: "poilist", subdirectory: nil)
        if let mock3ListString = stringContentResource(url: mock3!) {
            let state = importListFromJSONData(contents: mock3ListString, managedObjectContext: moc)
            if state == ImportState.success {
                XCTFail("expected importstate exists")
            } else if state == ImportState.exists {
                print("import exists")
            } else if state == ImportState.failed {
                XCTFail("expected importstate exists")
            }
        } else {
            XCTFail("mock list import error")
        }

        let importResult1 = importActionSaveCopy(managedObjectContext: moc)
        if !importResult1 {
            XCTFail("could not save copy of list.")
        }

        // import same mock list again
        let mock4 = Bundle.main.url(forResource: "mockList1", withExtension: "poilist", subdirectory: nil)
        if let mock4ListString = stringContentResource(url: mock4!) {
            let state = importListFromJSONData(contents: mock4ListString, managedObjectContext: moc)
            if state == ImportState.success {
                XCTFail("expected importstate exists")
            } else if state == ImportState.exists {
                print("import exists")
            } else if state == ImportState.failed {
                XCTFail("expected importstate exists")
            }
        } else {
            XCTFail("mock list import error")
        }

        let importResult2 = importActionOverwrite(managedObjectContext: moc)
        if !importResult2 {
            XCTFail("could not overwrite list.")
        }

        // import new mock list
        let mock5 = Bundle.main.url(forResource: "mockList2",
                                    withExtension: "poilist",
                                    subdirectory: nil)
        if let mock5ListString = stringContentResource(url: mock5!) {
            let state = importListFromJSONData(contents: mock5ListString, managedObjectContext: moc)
            if state == ImportState.success {
                print("import success")
            } else if state == ImportState.exists {
                XCTFail("expected importstate success")
            } else if state == ImportState.failed {
                XCTFail("expected importstate success")
            }
        } else {
            XCTFail("mock list import error")
        }

        // check initial values of mockList2, export to JSON, import JSON, see if values remain the same.
        if let poiListModel: PoiListModel = poiListModelForTimestamp(timestamp: "1490786294051",
                                                                    managedObjectContext: moc) {
            let title = poiListModel.title
            let info = poiListModel.info
            let timestamp = poiListModel.timestamp
            var poi1Title = ""
            var poi1Info = ""
            var poi1Lat: Double = 0
            var poi1Long: Double = 0
            var poi2Title = ""
            var poi2Info = ""
            var poi2Lat: Double = 0
            var poi2Long: Double = 0
            var poi3Title = ""
            var poi3Info = ""
            var poi3Lat: Double = 0
            var poi3Long: Double = 0
            var iteration = 0
            if let pois = poiListModel.pois, let poiArray: [PoiModel] = Array(pois) as? [PoiModel] {
                let sortedArray = poiArray.sorted(by: {$0.lat < $1.lat})
                for case let poiModel in sortedArray {
                    if iteration == 0 {
                        poi1Title = poiModel.title!
                        poi1Info = poiModel.info!
                        poi1Lat = poiModel.lat
                        poi1Long = poiModel.long
                    }
                    if iteration == 1 {
                        poi2Title = poiModel.title!
                        poi2Info = poiModel.info!
                        poi2Lat = poiModel.lat
                        poi2Long = poiModel.long
                    }
                    if iteration == 2 {
                        poi3Title = poiModel.title!
                        poi3Info = poiModel.info!
                        poi3Lat = poiModel.lat
                        poi3Long = poiModel.long
                    }
                    iteration += 1
                }
                XCTAssertTrue(iteration == 3)
            }
            let poiListjson = poiListAsJSON(poiListModel: poiListModel, managedObjectContext: moc)
            XCTAssertTrue(deletePoiListModel(poiListModel: poiListModel, managedObjectContext: moc))
            let state = importListFromJSONData(contents: poiListjson!, managedObjectContext: moc)
            if state == ImportState.success {
                print("import success")
                if let importedPoiListModel: PoiListModel = poiListModelForTimestamp(timestamp: "1490786294051",
                                                                                    managedObjectContext: moc) {
                    var iteration = 0
                    XCTAssertTrue(importedPoiListModel.title == title)
                    XCTAssertTrue(importedPoiListModel.info == info)
                    XCTAssertTrue(importedPoiListModel.timestamp == timestamp)
                    if let pois = importedPoiListModel.pois, let poiArray: [PoiModel] = Array(pois) as? [PoiModel] {
                        let sortedArray = poiArray.sorted(by: {$0.lat < $1.lat})
                        for case let poiModel in sortedArray {
                            if iteration == 0 {
                                XCTAssertTrue(poiModel.title == poi1Title)
                                XCTAssertTrue(poiModel.info == poi1Info)
                                XCTAssertTrue(poiModel.lat == poi1Lat)
                                XCTAssertTrue(poiModel.long == poi1Long)
                            }
                            if iteration == 1 {
                                XCTAssertTrue(poiModel.title == poi2Title)
                                XCTAssertTrue(poiModel.info == poi2Info)
                                XCTAssertTrue(poiModel.lat == poi2Lat)
                                XCTAssertTrue(poiModel.long == poi2Long)
                            }
                            if iteration == 2 {
                                XCTAssertTrue(poiModel.title == poi3Title)
                                XCTAssertTrue(poiModel.info == poi3Info)
                                XCTAssertTrue(poiModel.lat == poi3Lat)
                                XCTAssertTrue(poiModel.long == poi3Long)
                            }
                            iteration += 1
                        }
                        XCTAssertTrue(iteration == 3)
                    } else {
                        XCTFail("could not unwrap importedPoiListModel")
                    }
                }
            } else {
                XCTFail("unexpected import state")
            }

        } else {
            XCTFail("mock list with timestamp 1490786294051 not found")
        }
    }

    func testCoreData() {
        // create PoiListModel
        let moc = setUpInMemoryManagedObjectContext()
        let poiListTitle = "poi list title"
        let poiListInfo = "poi list info"
        let poiListTimestamp = timestampAsString()
        let poiListModel = insertNewPoiListModel(title: poiListTitle,
                                                 info: poiListInfo,
                                                 timestamp: poiListTimestamp,
                                                 managedObjectContext: moc)
        XCTAssertTrue(poiListModel?.title == poiListTitle)
        XCTAssertTrue(poiListModel?.info == poiListInfo)
        XCTAssertTrue(poiListModel?.timestamp == poiListTimestamp)

        // create PoiModel
        let poiTitle = "poi title"
        let poiInfo = "poi info"
        let poiLat = 40.741895
        let poiLong = -73.989308
        let poiModel = insertNewPoiModel(title: poiTitle,
                                         info: poiInfo,
                                         lat: poiLat,
                                         long: poiLong,
                                         poiListModel: poiListModel,
                                         managedObjectContext: moc)
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
