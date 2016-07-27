//
//  BitLiveUITests.swift
//  BitLiveUITests
//
//  Created by Ace Green on 7/27/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import XCTest
@testable import BitLive

class BitLiveUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSegmentedControlSwitching() {
        
        let app = XCUIApplication()
        app.buttons["GBP"].tap()
        app.buttons["EUR"].tap()
        app.buttons["USD"].tap()
        
        let element = XCUIApplication().otherElements.childrenMatchingType(.Other).elementBoundByIndex(1)
        element.pressForDuration(1.0)
        element.swipeLeft()
        NSThread.sleepForTimeInterval(1.0)
        element.swipeRight()
        NSThread.sleepForTimeInterval(1.0)
    }
}
