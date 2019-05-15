//
//  StackViewControllerTests+InteractorDelegate.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 15/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

extension StackViewControllerTests {

    // MARK: - startInteractivePopTransition()

    func testThat_whenStartInteractivePopTransitionIsCalled_itCallsInteractorPopAnimatedAndInteractive() {
        // Arrange
        let stack = Stack.default
        let stackHandler = StackHandler(stack: stack)
        let interactor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)

        XCTAssertNil(interactor.didCallPopAnimatedInteractive)
        XCTAssertNil(interactor.popAnimated)
        XCTAssertNil(interactor.popInteractive)

        // Act
        sut.startInteractivePopTransition()

        // Assert
        XCTAssertTrue(sut.interactor === interactor)
        XCTAssertEqual(interactor.didCallPopAnimatedInteractive, true)
        XCTAssertEqual(interactor.popAnimated, true)
        XCTAssertEqual(interactor.popInteractive, true)
    }

    // MARK: - prepareAddingChild(_:)

    func testThat_whenPrepareAddingChildIsCalled_itCallsAddChild() {
        // Arrange
        let child = MockViewController()
        sut = StackViewController.dummy

        XCTAssertTrue(child.parent !== sut)
        XCTAssertNil(child.didMoveToParentDate)

        // Act
        sut.prepareAddingChild(child)

        // Assert
        XCTAssertTrue(child.parent === sut)
        XCTAssertNil(child.didMoveToParentDate)
    }

    // MARK: - finishAddingChild(_:)

    func testThat_whenFinishAddingChildIsCalled_itCallsDidMoveToParentOnChild() {
        // Arrange
        let child = MockViewController()
        sut = StackViewController.dummy


        XCTAssertNil(child.didMoveToParentParent)

        // Act
        sut.finishAddingChild(child)

        // Assert
        XCTAssertEqual(child.didMoveToParentParent, sut)
    }

    // MARK: - prepareRemovingChild(_:)

    func testThat_whenPrepareRemovingChildIsCalled_itCallsWillMoveToParentOnChild() {
        // Arrange
        let child = MockViewController()
        sut = StackViewController.dummy
        child.willMoveToParentParent = sut

        XCTAssertNil(child.didCallWillMoveToParent)
        XCTAssertNotNil(child.willMoveToParentParent)

        // Act
        sut.prepareRemovingChild(child)

        // Assert
        XCTAssertEqual(child.didCallWillMoveToParent, true)
        XCTAssertNil(child.willMoveToParentParent)

    }

    // MARK: - finishRemovingChild(_ viewController: UIViewController)

    func testThat_whenFinishRemovingChildIsCalled_itCallsRemoveFromParentOnChild() {
        // Arrange
        let child = MockViewController()
        sut = StackViewController.dummy

        XCTAssertNil(child.didCallRemoveFromParent)

        // Act
        sut.finishRemovingChild(child)

        // Assert
        XCTAssertEqual(child.didCallRemoveFromParent, true)
    }

    // MARK: - prepareAppearance(of:animated:)

    func testThat_whenPrepareAppearanceIsCalled_itCallsBeginAppearanceTransitionOnTheViewController() {
        // Arrange
        let viewController = MockViewController()
        let animated = true
        sut = StackViewController.dummy

        XCTAssertNil(viewController.didCallBeginAppearance)
        XCTAssertNil(viewController.beginAppearanceIsAppearing)
        XCTAssertNil(viewController.beginAppearanceAnimated)

        // Act
        sut.prepareAppearance(of: viewController, animated: animated)

        // Assert
        XCTAssertEqual(viewController.didCallBeginAppearance, true)
        XCTAssertEqual(viewController.beginAppearanceIsAppearing, true)
        XCTAssertEqual(viewController.beginAppearanceAnimated, animated)
    }

    // MARK: - finishAppearance(of:)

    func testThat_whenFinishAppearanceIsCalled_itCallsEndAppearanceTransitionOnTheViewController() {
        // Arrange
        let viewController = MockViewController()
        sut = StackViewController.dummy

        XCTAssertNil(viewController.didCallEndAppearance)

        // Act
        sut.finishAppearance(of: viewController)

        // Assert
        XCTAssertEqual(viewController.didCallEndAppearance, true)
    }

    // MARK: - prepareDisappearance(of:animated:)

    func testThat_whenPrepareDisappearanceIsCalled_itCallsBeginAppearanceTransitionOnTheViewController() {
        // Arrange
        let viewController = MockViewController()
        let animated = true
        sut = StackViewController.dummy

        XCTAssertNil(viewController.didCallBeginAppearance)
        XCTAssertNil(viewController.beginAppearanceIsAppearing)
        XCTAssertNil(viewController.beginAppearanceAnimated)

        // Act
        sut.prepareDisappearance(of: viewController, animated: animated)

        // Assert
        XCTAssertEqual(viewController.didCallBeginAppearance, true)
        XCTAssertEqual(viewController.beginAppearanceIsAppearing, false)
        XCTAssertEqual(viewController.beginAppearanceAnimated, animated)
    }

    // MARK: - finishDisappearance(of:)

    func testThat_whenFinishDisappearanceIsCalled_itCallsEndAppearanceTransitionOnTheViewController() {
        // Arrange
        let viewController = MockViewController()
        sut = StackViewController.dummy

        XCTAssertNil(viewController.didCallEndAppearance)

        // Act
        sut.finishDisappearance(of: viewController)

        // Assert
        XCTAssertEqual(viewController.didCallEndAppearance, true)
    }
}
