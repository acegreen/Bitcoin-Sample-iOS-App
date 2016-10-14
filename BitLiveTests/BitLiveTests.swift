//
//  BitLiveTests.swift
//  BitLiveTests
//
//  Created by Ace Green on 7/27/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import XCTest
//import DataCache
@testable import BitLive

class BitLiveTests: XCTestCase {
    
    let viewController = ViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQueryCurrentValue() {
        
        let expectation: XCTestExpectation = self.expectation(description: "QueryCurrentValue Expectation")
        let queryLink = "https://api.coindesk.com/v1/bpi/currentprice.json"
        
        viewController.queryCurrentValue { (resultsJSON) in
            
            // Assert results are not empty and no error
            XCTAssertNil(resultsJSON.error, "Query error")
            XCTAssertNotNil(resultsJSON, "Query results came back empty")
            
            // Assert data was cached
            //XCTAssertNotNil(DataCache.defaultCache.readDataForKey("\(queryLink)"), "Data not Cached")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler:nil)
    }
    
    func testQueryUpdateHistoricValues() {
        
        let expectation: XCTestExpectation = self.expectation(description: "QueryHistoricValues Expectation")
        let today = Date()
        let daysAgo = viewController.dateBySubtractingDays(today, numberOfDays: -(28))
        let daysAgoFormatted = viewController.dateFormattedString(daysAgo)
        
        let queryLink = "https://api.coindesk.com/v1/bpi/historical/close.json?start=\(daysAgoFormatted)&end=2016-07-27&currency=USD"
        
        viewController.queryHistoricValues(weeks: 4) { (resultsJSON) in
            
            // Assert results are not empty and no error
            XCTAssertNil(resultsJSON.error, "Query error")
            XCTAssertNotNil(resultsJSON, "Query results came back empty")
            
            // Assert data was cached
            //XCTAssertNotNil(DataCache.defaultCache.readDataForKey("\(queryLink)"), "Data not Cached")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler:nil)
    }
    
    func testHistoricValuesChartUpdatingPerformance() {

        viewController.queryHistoricValues(weeks: 4) { (resultsJSON) in
            
            // Measure performance of charting
            self.measureBlock {
                self.viewController.updateHistoricData(resultsJSON)
            }
        }
    }
}
