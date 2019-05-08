//
//  StackInteractorTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 03/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

class StackInteractorTests: XCTestCase {
    var sut: StackInteractor!

    override func setUp() {
        sut = StackInteractor(stack: StackViewController.knownViewControllers)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }


     // MARK: - init(stack:)

    func testThat_whenPassingAStackContainingDuplicates_initThrowsErrorDuplicateViewControllers() {
        // Arrange
        let viewController = UIViewController()
        let stack = [viewController, viewController]

        // Act
        sut = StackInteractor(stack: stack)

        // Assert

        XCTAssertThrowsError(
            sut = StackInteractor(stack: stack),
            "StackInteractor init should throw when passing a stack containing duplicate elements as its input"
        ) { error in
            XCTAssertEqual(error as? StackViewControllerError, StackViewControllerError.duplicateViewControllers)
        }
    }
}
