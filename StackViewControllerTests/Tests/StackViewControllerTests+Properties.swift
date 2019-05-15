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

    // MARK: - viewControllers

    func testThat_whenSettingViewControllers_itCallsSetViewControllersNonAnimatedMethodOfInteractor() {
        // Arrange
        let stack = Stack.distinctElements(4)
        let stackHandler = StackHandler(stack: [])
        let mockInteractor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: mockInteractor)

        XCTAssertNil(mockInteractor.didCallSetStackAnimated)
        XCTAssertNil(mockInteractor.setStackStack)
        XCTAssertNil(mockInteractor.setStackAnimated)

        // Act
        sut.viewControllers = stack

        // Assert
        XCTAssertEqual(mockInteractor.didCallSetStackAnimated, true)
        XCTAssertEqual(mockInteractor.setStackStack, stack)
        XCTAssertEqual(mockInteractor.setStackAnimated, false)
    }

    func testThat_whenGettingViewControllers_itCallsTheGetterOfStackPropertyOfInteractor() {
        // Arrange
        let stack = Stack.distinctElements(1)
        let stackHandler = StackHandler(stack: stack)
        let mockInteractor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: mockInteractor)

        XCTAssertNil(mockInteractor.didCallStackGetter)

        // Act
        _ = sut.viewControllers

        // Assert
        XCTAssertEqual(mockInteractor.didCallStackGetter, true)
    }

    // MARK: - shouldAutomaticallyForwardAppearanceMethods

    func testThat_shouldAutomaticallyForwardAppearanceMethods_isFalse() {
        // Arrange
        sut = StackViewController.dummy

        // Act
        let value = sut.shouldAutomaticallyForwardAppearanceMethods

        // Assert
        XCTAssertFalse(value)
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
