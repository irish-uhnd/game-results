//
//  AppUITests.swift
//  AppUITests
//
//  Created by Kyle Flavin on 2/17/22.
//

import XCTest

class AppUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
//        let app = XCUIApplication()
//        app.launchEnvironment = [ "UITest": "1" ]
//        setLanguage(app)
//        app.launch()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
                                        app.launch()
        
        let mainElement = XCUIApplication().webViews.webViews.webViews/*@START_MENU_TOKEN@*/.otherElements["main"]/*[[".otherElements[\"Notre Dame Football All Time Results\"].otherElements[\"main\"]",".otherElements[\"main\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        snapshot("01Main")
        mainElement.children(matching: .other).element(boundBy: 13).otherElements["\n"].tap()
        snapshot("02Filter1")
        mainElement.children(matching: .other).element(boundBy: 9).otherElements["\n"].tap()
        snapshot("03Filter2")
                
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
