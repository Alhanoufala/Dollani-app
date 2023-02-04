//
//  signUpTest.swift
//  DollaniTests
//
//  Created by Layan Alwadie on 13/07/1444 AH.
//

import XCTest
@testable import Dollani

final class signUpTest: XCTestCase {
   var sut: SignupViewController!
    override func setUpWithError() throws {
        sut = SignupViewController()
    }
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testName(){
        let test = sut.invalidName("")
        XCTAssertEqual(test, "مطلوب")
    }
    

}
