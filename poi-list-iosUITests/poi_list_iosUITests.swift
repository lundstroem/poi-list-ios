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

import XCTest

class PoiListIosUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test.
        // Doing this in setup will make sure it happens for each test method.
        //XCUIApplication().launch()
        let app = XCUIApplication()
        app.launchArguments.append("UITEST")
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation -
        // required for your tests before they run. The setUp method is a good place to do this.
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
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other)
            .element.children(matching: .other)
            .element.children(matching: .textView).element
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
        let textView = app.children(matching: .window).element(boundBy: 0)
            .children(matching: .other)
            .element.children(matching: .other)
            .element.children(matching: .textView).element
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
        let map = app.otherElements.containing(.navigationBar, identifier: "poi-list-title").children(matching: .other)
            .element.children(matching: .other)
            .element.children(matching: .other).element.children(matching: .other)
            .element.children(matching: .other).element.children(matching: .map).element
        map.press(forDuration: 2.0)
        app.sheets.buttons["OK"].tap()

        // edit pin
        app.otherElements["title, info"].tap()
        app.buttons["More Info"].tap()
        app.textFields.containing(.button, identifier: "Clear text").element.typeText("y")

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
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other)
            .element.children(matching: .other)
            .element.children(matching: .textView).element
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
