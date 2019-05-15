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
    
    // MARK: - finishAddingChild(_ viewController: UIViewController)

    // MARK: - prepareRemovingChild(_ viewController: UIViewController)

    // MARK: - finishRemovingChild(_ viewController: UIViewController)

    // MARK: - prepareAppearance(of viewController: UIViewController, animated: Bool)

    // MARK: - finishAppearance(of viewController: UIViewController)

    // MARK: - prepareDisappearance(of viewController: UIViewController, animated: Bool)

    // MARK: - finishDisappearance(of viewController: UIViewController)    
}
