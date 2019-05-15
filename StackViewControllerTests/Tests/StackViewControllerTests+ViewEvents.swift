//
//  StackViewControllerTests+ViewEvents.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 15/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
@testable import StackViewController

extension StackViewControllerTests {

    // MARK: - viewWillAppear

    func testThat_whenViewWillAppear_beginAppearanceTransitionIsCalledOnTopViewController() {
        // Arrange
        let viewControllerA = MockViewController()
        let viewControllerB = MockViewController()
        let stack = [viewControllerA, viewControllerB]
        let stackHandler = StackHandler(stack: stack)
        let interactor = StackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let animated = true

        XCTAssertNil(viewControllerB.didCallBeginAppearance)
        XCTAssertNil(viewControllerB.passedIsAppearing)
        XCTAssertNil(viewControllerB.passedAnimated)

        // Act
        sut.viewWillAppear(animated)

        // Assert
        XCTAssertEqual(sut.topViewController, viewControllerB)
        XCTAssertEqual(viewControllerB.didCallBeginAppearance, true)
        XCTAssertEqual(viewControllerB.passedIsAppearing, true)
        XCTAssertEqual(viewControllerB.passedAnimated, animated)
    }

    // MARK: - viewDidAppear

    func testThat_whenViewDidAppear_endAppearanceTransitionIsCalledOnTopViewController() {
        // Arrange
        let viewControllerA = MockViewController()
        let viewControllerB = MockViewController()
        let stack = [viewControllerA, viewControllerB]
        let stackHandler = StackHandler(stack: stack)
        let interactor = StackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let dontcare = true

        XCTAssertNil(viewControllerB.didCallEndAppearance)

        // Act
        sut.viewDidAppear(dontcare)

        // Assert
        XCTAssertEqual(sut.topViewController, viewControllerB)
        XCTAssertEqual(viewControllerB.didCallEndAppearance, true)
    }

    // MARK: - viewWillDisappear

    func testThat_whenViewWillDisappear_beginAppearanceTransitionIsCalledOnTopViewController() {
        // Arrange
        let viewControllerA = MockViewController()
        let viewControllerB = MockViewController()
        let stack = [viewControllerA, viewControllerB]
        let stackHandler = StackHandler(stack: stack)
        let interactor = StackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let animated = true

        XCTAssertNil(viewControllerB.didCallBeginAppearance)
        XCTAssertNil(viewControllerB.passedIsAppearing)
        XCTAssertNil(viewControllerB.passedAnimated)

        // Act
        sut.viewWillDisappear(animated)

        // Assert
        XCTAssertEqual(sut.topViewController, viewControllerB)
        XCTAssertEqual(viewControllerB.didCallBeginAppearance, true)
        XCTAssertEqual(viewControllerB.passedIsAppearing, false)
        XCTAssertEqual(viewControllerB.passedAnimated, animated)
    }

    // MARK: - viewDidDisappear

    func testThat_whenViewDidDisappear_endAppearanceTransitionIsCalledOnTopViewController() {
        // Arrange
        let viewControllerA = MockViewController()
        let viewControllerB = MockViewController()
        let stack = [viewControllerA, viewControllerB]
        let stackHandler = StackHandler(stack: stack)
        let interactor = StackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)
        let dontcare = true

        XCTAssertNil(viewControllerB.didCallEndAppearance)

        // Act
        sut.viewDidDisappear(dontcare)

        // Assert
        XCTAssertEqual(sut.topViewController, viewControllerB)
        XCTAssertEqual(viewControllerB.didCallEndAppearance, true)
    }
}
