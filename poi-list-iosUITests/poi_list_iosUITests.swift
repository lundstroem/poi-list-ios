
//
//  poi_list_iosUITests.swift
//  poi-list-iosUITests
//
//  Created by Harry Lundstrom on 12/02/17.
//  Copyright © 2017 Harry Lundström. All rights reserved.
//

import XCTest

class poi_list_iosUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //XCUIApplication().launch()
        let app = XCUIApplication()
        app.launchArguments.append("UITEST")
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateAndRemovePoiList() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    
        // create
        let app = XCUIApplication()
        let poiListNavigationBar = app.navigationBars["POI List"]
        poiListNavigationBar.buttons["Add"].tap()
        app.textFields["title"].typeText("poi-list-title")
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("poi-list-description")
        app.navigationBars["New List"].buttons["Done"].tap()
        
        // remove
        poiListNavigationBar.buttons["Edit"].tap()
        let tablesQuery = app.tables
        tablesQuery.buttons["Delete poi-list-title"].tap()
        tablesQuery.buttons["Delete"].tap()
    }
    
    func testAddAndEditPin() {
        
        // create
        let app = XCUIApplication()
        let poiListNavigationBar = app.navigationBars["POI List"]
        poiListNavigationBar.buttons["Add"].tap()
        app.textFields["title"].typeText("poi-list-title")
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("poi-list-description")
        app.navigationBars["New List"].buttons["Done"].tap()
        
        // go to detailview
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
                
        // if on a fresh install, this dialog needs to be dismissed or the test will fail.
        if app.alerts.element.collectionViews.buttons["Allow"].exists {
            app.alerts.element.collectionViews.buttons["Allow"].tap()
        }

        // add pin
        let map = app.otherElements.containing(.navigationBar, identifier:"poi-list-title").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .map).element
        map.press(forDuration:2.0)
        app.sheets.buttons["OK"].tap()
        
        // edit pin
        app.otherElements["title, info"].tap()
        app.buttons["More Info"].tap()
        app.textFields.containing(.button, identifier:"Clear text").element.typeText("y")
        
        let textView2 = app.textViews["info"]
        textView2.tap()
        textView2.typeText("y")
        app.navigationBars["title"].buttons["poi-list-title"].tap()
        
        // check if title and info has been updated
        app.otherElements["titley, yinfo"].tap()
        
        // go back
        app.navigationBars["poi-list-title"].buttons["POI List"].tap()

        // remove list
        poiListNavigationBar.buttons["Edit"].tap()
        let tablesQuery = app.tables
        tablesQuery.buttons["Delete poi-list-title"].tap()
        tablesQuery.buttons["Delete"].tap()
    }
    
    func testEditPoiList() {
        
        // create
        let app = XCUIApplication()
        let poiListNavigationBar = app.navigationBars["POI List"]
        poiListNavigationBar.buttons["Add"].tap()
        app.textFields["title"].typeText("poi-list-title")
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("poi-list-description")
        app.navigationBars["New List"].buttons["Done"].tap()
        
        // go to detailview
        app.tables.children(matching: .cell).element(boundBy: 0).tap()
                
        // edit poi list data
        let editButton = app.toolbars.buttons["Edit"]
        editButton.tap()
        let titleTextField = app.textFields["title"]
        titleTextField.typeText("2")
        let textView3 = app.textViews["poi-list-description"]
        textView3.tap()
        textView3.typeText("2")
        let listNavigationBar = app.navigationBars["poi-list-title"]
        listNavigationBar.buttons["Cancel"].tap()
        editButton.tap()
        titleTextField.typeText("2")
        textView.tap()
        textView.typeText("2")
        listNavigationBar.buttons["Done"].tap()
        
        // go back
        app.navigationBars["poi-list-title2"].buttons["POI List"].tap()
        
        // remove list
        poiListNavigationBar.buttons["Edit"].tap()
        let tablesQuery = app.tables
        tablesQuery.buttons["Delete poi-list-title2"].tap()
        tablesQuery.buttons["Delete"].tap()
    }
}
