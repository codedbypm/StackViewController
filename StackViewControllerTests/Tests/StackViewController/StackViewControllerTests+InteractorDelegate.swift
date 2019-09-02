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

    // MARK: - animationController(for:from:to:)

    func testThat_whenAskedForAnimationController_thenItReturnsWhatDelegateReturns() {
        // Arrange
        let animationController = MockAnimatedTransitioning()
        let delegate = MockStackViewControllerDelegate()
        delegate.animationController = animationController

        let sut = StackViewController()
        sut.delegate = delegate

        // Act
        let controller = sut.animationController(
            for: .push,
            from: UIViewController(),
            to: UIViewController()
        )

        // Assert
        XCTAssertTrue(controller === animationController)
    }

    // MARK: - interactionController(for:)

    func testThat_whenAskedForInteractiveController_thenItReturnsWhatDelegateReturns() {
        // Arrange
        let interactiveController = MockInteractiveTransitioning()
        let delegate = MockStackViewControllerDelegate()
        delegate.interactiveController = interactiveController

        let sut = StackViewController()
        sut.delegate = delegate

        // Act
        let controller = sut.interactionController(for: MockAnimatedTransitioning())

        // Assert
        XCTAssertTrue(controller === interactiveController)
    }


    // MARK: - startInteractivePopTransition()

    func testThat_whenStartInteractivePopTransitionIsCalled_itCallsInteractorPopAnimatedAndInteractive() {
        // Arrange
        let stack = Stack.default
        let stackHandler = MockStackHandler(stack: stack)
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
        let child = EventReportingViewController()
        sut = StackViewController.dummy

        XCTAssertTrue(child.parent !== sut)
        XCTAssertNil(child.didCallDidMoveToParent)

        // Act
        sut.prepareAddingChild(child)

        // Assert
        XCTAssertTrue(child.parent === sut)
        XCTAssertNil(child.didCallDidMoveToParent)
    }

    // MARK: - finishAddingChild(_:)

    func testThat_whenFinishAddingChildIsCalled_itCallsDidMoveToParentOnChild() {
        // Arrange
        let child = EventReportingViewController()
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
        let child = EventReportingViewController()
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
        let child = EventReportingViewController()
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
        let yellow = EventReportingViewController()
        let animated = true
        sut = StackViewController.dummy

        XCTAssertNil(yellow.didCallBeginAppearanceTransition)
        XCTAssertNil(yellow.isAppearing)

        // Act
        sut.prepareAppearance(of: yellow, animated: animated)

        // Assert
        XCTAssertEqual(yellow.didCallBeginAppearanceTransition, true)
        XCTAssertEqual(yellow.isAnimated, animated)
        XCTAssertEqual(yellow.isAppearing, true)
    }

    // MARK: - finishAppearance(of:)

    func testThat_whenFinishAppearanceIsCalled_itCallsEndAppearanceTransitionOnTheViewController() {
        // Arrange
        let yellow = EventReportingViewController()
        sut = StackViewController.dummy

        XCTAssertNil(yellow.didCallEndAppearanceTransition)

        // Act
        sut.finishAppearance(of: yellow)

        // Assert
        XCTAssertEqual(yellow.didCallEndAppearanceTransition, true)
    }

    // MARK: - prepareDisappearance(of:animated:)

    func testThat_whenPrepareDisappearanceIsCalled_itCallsBeginAppearanceTransitionOnTheViewController() {
        // Arrange
        let yellow = EventReportingViewController()
        let animated = true
        sut = StackViewController.dummy

        XCTAssertNil(yellow.didCallBeginAppearanceTransition)
        XCTAssertNil(yellow.isDisappearing)

        // Act
        sut.prepareDisappearance(of: yellow, animated: animated)

        // Assert
        XCTAssertEqual(yellow.didCallBeginAppearanceTransition, true)
        XCTAssertEqual(yellow.isAnimated, animated)
        XCTAssertEqual(yellow.isDisappearing, true)

    }

    // MARK: - finishDisappearance(of:)

    func testThat_whenFinishDisappearanceIsCalled_itCallsEndAppearanceTransitionOnTheViewController() {
        // Arrange
        let yellow = EventReportingViewController()
        sut = StackViewController.dummy

        XCTAssertNil(yellow.didCallEndAppearanceTransition)

        // Act
        sut.finishDisappearance(of: yellow)

        // Assert
        XCTAssertEqual(yellow.didCallEndAppearanceTransition, true)
    }
}
