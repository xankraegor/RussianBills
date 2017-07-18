//
//  RussianBillsTests.swift
//  RussianBillsTests
//
//  Created by Xan Kraegor on 03.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import XCTest
import Alamofire
@testable import RussianBills

class RussianBillsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func billSearchQueryHasAnyFilledFieldsTest() {
        var query = BillSearchQuery()
        query.name = "курения"
        query.status = BillStatus.signed
        query.registrationStart = "2005-01-01"
        XCTAssert(query.hasAnyFilledFields() == true)
        print(query.hasAnyFilledFields())
        query.name = nil
        query.status = nil
        query.registrationStart = nil
        XCTAssert(query.hasAnyFilledFields() == false)
        print(query.hasAnyFilledFields())

    }
    
    func billRequestURL() {
        let number = "15455-7"
        if let url = RequestRouter.bill(number: number).urlRequest {
            print(url)
        }
    }

    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
