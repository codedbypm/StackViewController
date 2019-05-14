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

    // MARK: - Delegate

    func testThat_whenSettingTheStackViewControllerDelegate_theStackViewControllerDelegatePropertyOfInteractorIsSetToThatValue() {
        // Arrange
        sut = StackViewController.dummy
        let mockDelegate = MockStackViewControllerDelegate()

        XCTAssertNil(sut.delegate)
        XCTAssertNil(sut.interactor.stackViewControllerDelegate)

        // Act
        sut.delegate = mockDelegate

        // Assert
        XCTAssertTrue(sut.delegate === sut.interactor.stackViewControllerDelegate)
    }

    func testThat_whenGettingTheStackViewControllerDelegate_itReturnsTheSameValueOfInteractorStackViewControllerDelegateProperty() {
        // Arrange
        sut = StackViewController.dummy

        sut.interactor.stackViewControllerDelegate = nil
        XCTAssertNil(sut.delegate)

        let mockDelegate = MockStackViewControllerDelegate()
        sut.interactor.stackViewControllerDelegate = mockDelegate

        // Act
        let delegate = sut.delegate

        // Assert
        XCTAssertTrue(delegate === mockDelegate)
    }


    // MARK: - screenEdgePanGestureRecognizer

    func testThat_screenEdgePanGestureRecognizerIsProperlyConfigured() {
        // Arrange
        sut = StackViewController.dummy

        // Act
        let gestureRecognizer = sut.screenEdgePanGestureRecognizer

        // Assert
        XCTAssertEqual(gestureRecognizer.edges, .left)
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
