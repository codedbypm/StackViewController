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
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        sut = nil
        window = nil
        super.tearDown()
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
}

// MARK: - View not in hierarchy

extension StackViewControllerTests {

    // MARK: - Sequence of events

    // when: stack = []
    //       stack.view.window == nil
    // then: no events
    //
    func testThat_initWithEmptyStack_itReceivesAndSendsProperEvents() {
        // Arrange

        // Act
        let sut = MockStackViewController()

        // Assert
        XCTAssertEqual(sut.receivedEventDates.count, 0)
    }

    // when: stack = []
    //       stack.view.window == nil
    //       pushViewController
    //
    // then: sends to yellow    => [willMoveToParent]
    //
    // note: UINC receives viewDidLoad too
    //
    func testThat_whenInitWithEmptyStack_and_pushViewController_thenItReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = EventReportingViewController()
        let sut = StackViewController()

        // Act
        sut.push(yellow, animated: false)

        // Assert
        XCTAssertEqual(yellow.receivedEventDates.count, 1)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
    }

    // when: stack = [yellow, green]
    //       stack.view.window == nil
    //       sut.stack = [red, black]
    //
    // then: sends to yellow    =>  [willMoveToParent: sut],
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
    func testThat_whenReplacingNonEmptyStackWithAnotherNonEmptyStack_thenItReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = EventReportingViewController()
        let green = EventReportingViewController()
        sut = MockStackViewController()
        sut.stack = [yellow, green]

        let red = EventReportingViewController()
        let black = EventReportingViewController()

        // Act
        sut.stack = [red, black]

        // Assert
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

        let timeline =
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
        XCTAssertEqual(timeline, timeline.sorted())
    }

    // when: stack = [yellow]
    //       stack.view.window == nil
    //
    // then: receives           => [pushViewController]
    //       sends to yellow    => [willMoveToParent]
    //
    // note: UINC receives viewDidLoad too
    //
    func testThat_whenInitWithARootViewController_thenItReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = EventReportingViewController()

        // Act
        sut = StackViewController(rootViewController: yellow)

        // Assert
        XCTAssertEqual(yellow.receivedEventDates.count, 1)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
    }

    // when: stack = [yellow, green, red],
    //       popToRootViewController
    //
    // then: sends to yellow    =>  [willMoveToParent: sut],
    //                              [didMoveToParent: sut],
    //                              [willMoveToParent: nil],
    //                              [didMoveToParent: nil],
    //                              [willMoveToParent: sut],
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
        let yellow = EventReportingViewController()
        let green = EventReportingViewController()
        let red = EventReportingViewController()
        sut = StackViewController()
        sut.stack = [yellow, green, red]

        // Act
        sut.popToRootViewController(animated: false)

        // Assert
        XCTAssertEqual(yellow.receivedEventDates.count, 5)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 2)
        XCTAssertEqual(yellow.wasAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.willBeRemovedFromParentDates.count, 1)
        XCTAssertEqual(yellow.wasRemovedFromParentDates.count, 1)

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
            Array(yellow.willBeAddedToParentDates.prefix(1))
                + yellow.wasAddedToParentDates
                + green.willBeAddedToParentDates
                + green.wasAddedToParentDates
                + red.willBeAddedToParentDates
                + yellow.willBeRemovedFromParentDates
                + yellow.wasRemovedFromParentDates
                + green.willBeRemovedFromParentDates
                + green.wasRemovedFromParentDates
                + red.willBeRemovedFromParentDates
                + red.wasRemovedFromParentDates
                + Array(yellow.willBeAddedToParentDates.suffix(1))
        XCTAssertEqual(totalEvents, totalEvents.sorted())
    }
}

// MARK: - View in hierarchy

extension StackViewControllerTests {

    // when: stack = []
    //       window.rootViewController = SVC
    //       push(yellow)
    //
    // then: yellow receives    => [willMoveToParent]
    //                             [viewDidLoad]
    //                             [beginAppearanceTransition]
    //                             [viewWillAppear]
    //                             [endAppearanceTransition]
    //                             [viewDidAppear]
    //                             [didMoveToParent]
    //
    // note: UINC does not send [endAppearanceTransition]
    func testThat_whenInitWithEmptyStackAndSetAsWindowRootViewControllerOnPushViewController_thenProperEventsAreSent() {
        // Arrange
        let sut = StackViewController()
        window.rootViewController = sut

        let yellow = EventReportingViewController()

        // Act
        sut.push(yellow, animated: false)

        // Assert
        XCTAssertEqual(yellow.receivedEventDates.count, 7)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.viewDidLoadDates.count, 1)
        XCTAssertEqual(yellow.beginAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.viewWillAppearDates.count, 1)
        XCTAssertEqual(yellow.endAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.viewDidAppearDates.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentDates.count, 1)

        let timeline: [Date] = [
            yellow.willBeAddedToParentDates.first,
            yellow.viewDidLoadDates.first,
            yellow.beginAppearanceTransitionDates.first,
            yellow.viewWillAppearDates.first,
            yellow.endAppearanceTransitionDates.first,
            yellow.viewDidAppearDates.first,
            yellow.wasAddedToParentDates.first
        ].compactMap { $0 }
        XCTAssertEqual(timeline, timeline.sorted())
        XCTAssertEqual(timeline.count, 7)
    }

    // when: stack = [yellow]
    //       window.rootViewController = SVC
    //
    // then: yellow         => [willMoveToParent]
    //                         [viewDidLoad]
    //                         [beginAppearanceTransition]
    //                         [viewWillAppear]
    //                         [endAppearanceTransition]
    //                         [viewDidAppear]
    //                         [didMoveToParent]
    //
    func testThat_whenInitWithARootViewControllerAndSetAsWindowRootViewController_thenProperEventsAreSent() throws {
        // Arrange
        let yellow = EventReportingViewController()
        let sut = UINavigationController(rootViewController: yellow)

        // Act
        window.rootViewController = sut
        window.makeKeyAndVisible()

        // Assert
        let predicate = NSPredicate(value: sut.view.subviews.contains(yellow.view))
        let expectation = self.expectation(for: predicate, evaluatedWith: nil)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        print(result)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.viewDidLoadDates.count, 1)
        XCTAssertEqual(yellow.beginAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.viewWillAppearDates.count, 1)
        XCTAssertEqual(yellow.endAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.viewDidAppearDates.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.receivedEventDates.count, 7)

        let timeline: [TimeInterval] = [
            yellow.willBeAddedToParentDates.first,
            yellow.beginAppearanceTransitionDates.first,
            yellow.viewDidLoadDates.first,
            yellow.viewWillAppearDates.first,
            yellow.endAppearanceTransitionDates.first,
            yellow.viewDidAppearDates.first,
            yellow.wasAddedToParentDates.first
            ].compactMap { $0?.timeIntervalSince1970 }

        XCTAssertEqual(timeline, timeline.sorted())
        XCTAssertEqual(timeline.count, 7)
    }

}
