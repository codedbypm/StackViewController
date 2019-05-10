//
//  StackViewControllerTests+Properties.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

extension StackViewControllerTests {

    // MARK: - screenEdgePanGestureRecognizer

    func testThat_screenEdgePanGestureRecognizerIsProperlyConfigured() {
        // Arrange
        sut = StackViewController.dummy

        // Act
        let gestureRecognizer = sut.screenEdgePanGestureRecognizer

        // Assert
        XCTAssertEqual(gestureRecognizer.edges, .left)
        XCTAssert(gestureRecognizer.delegate === sut)
    }


    // MARK: - topViewController

    func testThat_whenTheStackIsEmpty_topViewControllerIsNil() {
        // Arrange
        sut = StackViewController.withEmptyStack()

        // Act
        let topViewController = sut.topViewController

        // Assert
        XCTAssertNil(topViewController)
    }

    func testThat_whenTheStackIsNotEmpty_topViewControllerEqualsTheLastElementOfTheStack() {
        // Arrange
        sut = StackViewController.withNumberOfViewControllers(3)

        // Act
        let topViewController = sut.topViewController

        // Assert
        XCTAssertNotNil(topViewController)
        XCTAssertEqual(topViewController, sut.viewControllers.last)
    }
}
