//
//  StackViewControllerTests+StackActions.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

extension StackViewControllerTests {

    // MARK: - pushViewController(_:animated)

    func testThat_whenAViewControllerIsPushed_itCallsInteractorMethod() {
        // Arrange
        let stackHandler = MockStackHandler(stack: [])
        let interactor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let pushedViewController = UIViewController()
        let animated = true

        XCTAssertNil(interactor.didCallPushViewControllerAnimated)
        XCTAssertNil(interactor.pushedViewController)
        XCTAssertNil(interactor.pushedViewControllerAnimated)

        // Act
        sut.push(pushedViewController, animated: animated)

        // Assert
        XCTAssertTrue(interactor === sut.interactor)
        XCTAssertEqual(interactor.didCallPushViewControllerAnimated, true)
        XCTAssertEqual(interactor.pushedViewController, pushedViewController)
        XCTAssertEqual(interactor.pushedViewControllerAnimated, animated)
    }

    // MARK: - popViewController(animated:interactive:)

    func testThat_whenPopAnimatedIsCalled_itCallsInteractorMethod_and_keepsTheDefaultValues() {
        // Arrange
        let viewController = UIViewController()
        let stackHandler = MockStackHandler(stack: [viewController])
        let interactor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let animated = true

        XCTAssertNil(interactor.didCallPopAnimatedInteractive)
        XCTAssertNil(interactor.popAnimated)
        XCTAssertNil(interactor.popInteractive)
        interactor.popReturnValue = viewController
        
        // Act
        let poppedViewController = sut.popViewController(animated: animated)

        // Assert
        XCTAssertTrue(interactor === sut.interactor)
        XCTAssertEqual(interactor.didCallPopAnimatedInteractive, true)
        XCTAssertEqual(interactor.popAnimated, animated)
        XCTAssertEqual(interactor.popInteractive, false)
        XCTAssertEqual(poppedViewController, viewController)
    }

    // MARK: - popToRootViewController(animated:)

    func testThat_whenPoppingToRootViewController_itCallsInteractorMethod() {
        // Arrange
        let stackHandler = MockStackHandler(stack: Stack.default)
        let interactor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let animated = true
        let poppedViewControllers = Stack.distinctElements(3)

        XCTAssertNil(interactor.didCallPopToRootAnimated)
        XCTAssertNil(interactor.popToRootAnimated)
        interactor.popToRootReturnValue = poppedViewControllers

        // Act
        let popped = sut.popToRootViewController(animated: animated)

        // Assert
        XCTAssertTrue(interactor === sut.interactor)
        XCTAssertEqual(interactor.didCallPopToRootAnimated, true)
        XCTAssertEqual(interactor.popToRootAnimated, animated)
        XCTAssertEqual(popped, poppedViewControllers)
    }

    // MARK: - popToViewController(_:animated:)

    func testThat_whenPoppingToAViewController_itCallsInteractorMethod() {
        // Arrange
        let stackHandler = MockStackHandler(stack: Stack.default)
        let interactor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let animated = true
        let toViewController = UIViewController()
        let poppedViewControllers = Stack.distinctElements(3)

        XCTAssertNil(interactor.didCallPopToViewControllerAnimated)
        XCTAssertNil(interactor.popToViewControllerViewController)
        XCTAssertNil(interactor.popToViewControllerAnimated)
        interactor.popToViewControllerReturnValue = poppedViewControllers

        // Act
        let popped = sut.popToViewController(toViewController, animated: animated)

        // Assert
        XCTAssertTrue(interactor === sut.interactor)
        XCTAssertEqual(interactor.didCallPopToViewControllerAnimated, true)
        XCTAssertEqual(interactor.popToViewControllerViewController, toViewController)
        XCTAssertEqual(interactor.popToViewControllerAnimated, animated)
        XCTAssertEqual(popped, poppedViewControllers)
    }

    // MARK: - setStack(_,animated:)

    func testThat_whenSettingStack_itCallsInteractorMethod() {
        // Arrange
        let stackHandler = MockStackHandler(stack: Stack.default)
        let interactor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let animated = true
        let stack = Stack.distinctElements(3)

        XCTAssertNil(interactor.didCallSetStackAnimated)
        XCTAssertNil(interactor.setStackStack)
        XCTAssertNil(interactor.setStackAnimated)

        // Act
        sut.setStack(stack, animated: animated)

        // Assert
        XCTAssertTrue(interactor === sut.interactor)
        XCTAssertEqual(interactor.didCallSetStackAnimated, true)
        XCTAssertEqual(interactor.setStackStack, stack)
        XCTAssertEqual(interactor.setStackAnimated, animated)
    }
}
