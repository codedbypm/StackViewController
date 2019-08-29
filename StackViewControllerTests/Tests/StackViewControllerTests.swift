//
//  StackViewControllerTests.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 24/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import XCTest
import UIKit

@testable import StackViewController

class StackViewControllerTests: XCTestCase {
    var sut: StackViewController!

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - init()

    // MARK: - init(rootViewController:)

    // MARK: - viewDidLoad()

    func testThat_whenViewDidLoadIsCalled_itAddsGesgtureRecognizerToTheView() {
        // Arrange
        sut = StackViewController.dummy

        XCTAssertNil(sut.screenEdgePanGestureRecognizer.view)

        // Act
        _ = sut.view

        // Assert
        XCTAssertNotNil(sut.screenEdgePanGestureRecognizer.view)
        XCTAssertEqual(sut.screenEdgePanGestureRecognizer.view, sut.view)
    }

    func testThat_whenViewDidLoadIsCalled_itAddsWrapperViewAsSubview() {
        // Arrange
        sut = StackViewController.dummy

        // Act
        _ = sut.view

        // Assert
        XCTAssertEqual(sut.viewControllerWrapperView.superview, sut.view)
        XCTAssertNotEqual(sut.viewControllerWrapperView.frame, CGRect.zero)
        XCTAssertEqual(sut.viewControllerWrapperView.frame, sut.view.bounds)
    }

    func testThat_whenViewDidLoadIsCalled_andTheStackIsNotEmpty_itAddsTopViewControllerViewAsSubviewOfWrapperView() {
        // Arrange
        sut = StackViewController.withDefaultStack()

        // Act
        _ = sut.view

        // Assert
        XCTAssertEqual(sut.topViewController?.view.superview, sut.viewControllerWrapperView)
    }

    // MARK: - screenEdgeGestureRecognizerDidChangeState(_:)

    func testThat_whenTheGestureRecognizerSendItsAction_itCallshandleScreenEdgePanGestureRecognizerStateChangeOnTheInteractor() {
        // Arrange
        let gestureRecognizer = ScreenEdgePanGestureRecognizer(target: nil, action: nil)
        let stackHandler = MockStackHandler(stack: [])
        let interactor = MockStackViewControllerInteractor(stackHandler: stackHandler)
        sut = StackViewController(interactor: interactor)

        XCTAssertNil(interactor.didCallHandleScreenEdgePanGestureRecognizerStateChange)
        XCTAssertNil(interactor.gestureRecognizer)

        // Act
        sut.screenEdgeGestureRecognizerDidChangeState(gestureRecognizer)

        // Assert
        XCTAssertEqual(interactor.didCallHandleScreenEdgePanGestureRecognizerStateChange, true)
        XCTAssertTrue(interactor.gestureRecognizer === gestureRecognizer)
    }

    // MARK: - Sequence of events

    // when: stack = []
    // then: no events
    //
    func testThat_initWithEmptyStack_itReceivesAndSendsProperEvents() {
        // Arrange

        // Act
        sut = MockStackViewController()

        // Assert
        guard let sut = sut as? MockStackViewController else {
            XCTFail("Expected sut of type MockStackViewController")
            return
        }

        XCTAssertEqual(
            sut.receivedEventDates,
            []
        )
    }

    // when: stack = [] and pushViewController
    // then: receives => [pushViewController, viewDidLoad]
    //       sends    => [willMoveToParent]
    //
    func testThat_initWithEmptyStackFollowedByPushViewController_itReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = MockViewController()
        sut = MockStackViewController()

        // Act
        sut.pushViewController(yellow, animated: false)

        // Assert
        guard let sut = sut as? MockStackViewController else {
            XCTFail("Expected sut of type MockStackViewController")
            return
        }

        XCTAssertEqual(
            sut.receivedEventDates,
            sut.pushViewControllerDates + sut.viewDidLoadDates
        )
        XCTAssertEqual(yellow.receivedEventDates, yellow.willBeAddedToParentDates)
    }

    // when: stack = [yellow, green] and .viewControllers = [red, black]
    // then: receives           =>  [viewControllers, setViewControllers]
    //       sends to yellow    =>  [willMoveToParent: sut],
    //                              [didMoveToParent: sut],
    //                              [willMoveToParent: nil],
    //                              [didMoveToParent: nil]
    //       sends to green     =>  [willMoveToParent: sut],
    //                              [willMoveToParent: nil],
    //                              [didMoveToParent: nil]
    //       sends to red       =>  [willMoveToParent: sut],
    //                              [didMoveToParent: sut]
    //       sends to black     =>  [willMoveToParent: sut]
    //
    func testThat_whenReplacingStackWithNonEmptyStack_itReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = MockViewController()
        let green = MockViewController()
        sut = MockStackViewController()
        sut.viewControllers = [yellow, green]

        let red = MockViewController()
        let black = MockViewController()

        // Act
        sut.viewControllers = [red, black]

        // Assert
        guard let sut = sut as? MockStackViewController else {
            XCTFail("Expected sut of type MockStackViewController")
            return
        }

        XCTAssertEqual(sut.receivedEventDates.count, 4)
        XCTAssertEqual(
            sut.receivedEventDates,
            (sut.viewControllersSetterDates + sut.setStackDates).sorted()
        )

        XCTAssertEqual(yellow.receivedEventDates.count, 4)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.willBeRemovedFromParentDates.count, 1)
        XCTAssertEqual(yellow.wasRemovedFromParentDates.count, 1)

        XCTAssertEqual(green.receivedEventDates.count, 3)
        XCTAssertEqual(green.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(green.wasAddedToParentDates.count, 0)
        XCTAssertEqual(green.willBeRemovedFromParentDates.count, 1)
        XCTAssertEqual(green.wasRemovedFromParentDates.count, 1)

        XCTAssertEqual(red.receivedEventDates.count, 2)
        XCTAssertEqual(red.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(red.wasAddedToParentDates.count, 1)
        XCTAssertEqual(red.willBeRemovedFromParentDates.count, 0)
        XCTAssertEqual(red.wasRemovedFromParentDates.count, 0)

        XCTAssertEqual(black.receivedEventDates.count, 1)
        XCTAssertEqual(black.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(black.wasAddedToParentDates.count, 0)
        XCTAssertEqual(black.willBeRemovedFromParentDates.count, 0)
        XCTAssertEqual(black.wasRemovedFromParentDates.count, 0)

        let totalEvents =
            yellow.willBeAddedToParentDates
            + yellow.wasAddedToParentDates
            + green.willBeAddedToParentDates
            + yellow.willBeRemovedFromParentDates
            + yellow.wasRemovedFromParentDates
            + green.willBeRemovedFromParentDates
            + green.wasRemovedFromParentDates
            + red.willBeAddedToParentDates
            + red.wasAddedToParentDates
            + black.willBeAddedToParentDates
        XCTAssertEqual(totalEvents, totalEvents.sorted())
    }

    // when: stack = [yellow]
    // then: receives => [pushViewController, viewDidLoad]
    //       sends    => [willMoveToParent]
    //
    func testThat_whenInitWithARootViewController_itReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = MockViewController()

        // Act
        sut = MockStackViewController(rootViewController: yellow)

        // Assert
        guard let sut = sut as? MockStackViewController else {
            XCTFail("Expected sut of type MockStackViewController")
            return
        }

        XCTAssertEqual(
            sut.receivedEventDates,
            sut.pushViewControllerDates + sut.viewDidLoadDates
        )
        XCTAssertEqual(yellow.receivedEventDates, yellow.willBeAddedToParentDates)
    }

    // when: stack = [yellow, green, red], popToRootViewController
    // then: receives           =>  [viewControllers],
    //                              [setViewControllers],
    //                              [popToRootViewController]
    //       sends to yellow    =>  [willMoveToParent: sut],
    //                              [didMoveToParent: sut],
    //                              [viewDidLoad]
    //       sends to green     =>  [willMoveToParent: sut],
    //                              [didMoveToParent: sut],
    //                              [willMoveToParent: nil],
    //                              [didMoveToParent: nil],
    //       sends to red       =>  [willMoveToParent: sut],
    //                              [willMoveToParent: nil],
    //                              [didMoveToParent: nil],
    //
    func testThat_whenCallingPopToRootViewControllerOnNonEmptyStack_itReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = MockViewController()
        let green = MockViewController()
        let red = MockViewController()
        sut = MockStackViewController()
        sut.viewControllers = [yellow, green, red]

        // Act
        sut.popToRootViewController(animated: false)

        // Assert
        guard let sut = sut as? MockStackViewController else {
            XCTFail("Expected sut of type MockStackViewController")
            return
        }

        XCTAssertEqual(sut.receivedEventDates.count, 3)
        XCTAssertEqual(
            sut.receivedEventDates,
            sut.viewControllersSetterDates + sut.setStackDates + sut.popToRootDates
        )

        XCTAssertEqual(yellow.receivedEventDates.count, 3)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.viewDidLoadDates.count, 1)

        XCTAssertEqual(green.receivedEventDates.count, 4)
        XCTAssertEqual(green.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(green.wasAddedToParentDates.count, 1)
        XCTAssertEqual(green.willBeRemovedFromParentDates.count, 1)
        XCTAssertEqual(green.wasRemovedFromParentDates.count, 1)

        XCTAssertEqual(red.receivedEventDates.count, 3)
        XCTAssertEqual(red.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(red.willBeRemovedFromParentDates.count, 1)
        XCTAssertEqual(red.wasRemovedFromParentDates.count, 1)

        let totalEvents: [Date] =
            sut.viewControllersSetterDates
                + sut.setStackDates
                + yellow.willBeAddedToParentDates
                + yellow.wasAddedToParentDates
                + green.willBeAddedToParentDates
                + green.wasAddedToParentDates
                + red.willBeAddedToParentDates
                + sut.popToRootDates
                + green.willBeRemovedFromParentDates
                + green.wasRemovedFromParentDates
                + red.willBeRemovedFromParentDates
                + red.wasRemovedFromParentDates
                + yellow.viewDidLoadDates
        XCTAssertEqual(totalEvents, totalEvents.sorted())
    }

}
