//
//  StackHandlerTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 03/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

class StackHandlerTests: XCTestCase {
    var sut: StackHandler!

    override func setUp() {

    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }


    // MARK: - init(stack:)

//    func testThat_whenPassingAStackContainingDuplicates_initThrowsErrorDuplicateViewControllers() {
//        // Arrange
//        let viewController = UIViewController()
//        let stack = [viewController, viewController]
//
//        // Act
//
//        // Assert
//
//        XCTAssertThrows((StackHandler(stack: stack)), "") { error in
//            guard let stackError = error as? StackViewControllerError else {
//                XCTFail("Wrong error type: expected \(StackViewControllerError.self), but got \(type(of: error))")
//                return
//            }
//
//            XCTAssertEqual(stackError, StackViewControllerError.duplicateViewControllers)
//        }
//    }
}
