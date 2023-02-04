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
    
    func testvalidName(){
        let test = sut.validateName(value: "sara")
        XCTAssertEqual(test, false)
    }
    func testInvalidName(){
        let test = sut.invalidName( "gfhhfhfhfhhfhfhfhfhfhfhfhfhfhhfjrkkfjffbnibogguuguuguguguuguguuguguguguguguguguguuuguguugugugugu")
        XCTAssertEqual(test, "الحد الاقصى ٢٠ حرف")
    }
    func testEmail(){
        let test = sut.invalidEmail("saara@gmail.com")
      //  XCTAssertNotEqual(test, "")
        XCTAssertTrue(test=="")
    }

}
