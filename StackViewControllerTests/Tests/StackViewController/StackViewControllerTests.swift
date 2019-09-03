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
    var waiter: XCTWaiter!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        window.makeKeyAndVisible()
        waiter = XCTWaiter(delegate: self)
    }

    override func tearDown() {
        sut = nil
        window = nil
        waiter = nil
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
        XCTAssertEqual(sut.allEventsTimestamps.count, 0)
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
        let yellow = EventsReportingViewController(.yellow)
        let sut = StackViewController()

        // Act
        sut.push(yellow, animated: false)

        // Assert
        XCTAssertEqual(yellow.allEventsTimestamps.count, 1)
        XCTAssertEqual(yellow.willBeAddedToParentTimestamps.count, 1)
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
        let yellow = EventsReportingViewController(.yellow)
        let green = EventsReportingViewController(.green)
        sut = MockStackViewController()
        sut.stack = [yellow, green]

        let red = EventsReportingViewController(.red)
        let black = EventsReportingViewController(.black)

        // Act
        sut.stack = [red, black]

        // Assert
        XCTAssertEqual(yellow.allEventsTimestamps.count, 4)
        XCTAssertEqual(yellow.willBeAddedToParentTimestamps.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentTimestamps.count, 1)
        XCTAssertEqual(yellow.willBeRemovedFromParentTimestamps.count, 1)
        XCTAssertEqual(yellow.wasRemovedFromParentTimestamps.count, 1)

        XCTAssertEqual(green.allEventsTimestamps.count, 3)
        XCTAssertEqual(green.willBeAddedToParentTimestamps.count, 1)
        XCTAssertEqual(green.wasAddedToParentTimestamps.count, 0)
        XCTAssertEqual(green.willBeRemovedFromParentTimestamps.count, 1)
        XCTAssertEqual(green.wasRemovedFromParentTimestamps.count, 1)

        XCTAssertEqual(red.allEventsTimestamps.count, 2)
        XCTAssertEqual(red.willBeAddedToParentTimestamps.count, 1)
        XCTAssertEqual(red.wasAddedToParentTimestamps.count, 1)
        XCTAssertEqual(red.willBeRemovedFromParentTimestamps.count, 0)
        XCTAssertEqual(red.wasRemovedFromParentTimestamps.count, 0)

        XCTAssertEqual(black.allEventsTimestamps.count, 1)
        XCTAssertEqual(black.willBeAddedToParentTimestamps.count, 1)
        XCTAssertEqual(black.wasAddedToParentTimestamps.count, 0)
        XCTAssertEqual(black.willBeRemovedFromParentTimestamps.count, 0)
        XCTAssertEqual(black.wasRemovedFromParentTimestamps.count, 0)

        let timeline =
            yellow.willBeAddedToParentTimestamps
            + yellow.wasAddedToParentTimestamps
            + green.willBeAddedToParentTimestamps
            + yellow.willBeRemovedFromParentTimestamps
            + yellow.wasRemovedFromParentTimestamps
            + green.willBeRemovedFromParentTimestamps
            + green.wasRemovedFromParentTimestamps
            + red.willBeAddedToParentTimestamps
            + red.wasAddedToParentTimestamps
            + black.willBeAddedToParentTimestamps
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
        let yellow = EventsReportingViewController(.yellow)

        // Act
        sut = StackViewController(rootViewController: yellow)

        // Assert
        XCTAssertEqual(yellow.allEventsTimestamps.count, 1)
        XCTAssertEqual(yellow.willBeAddedToParentTimestamps.count, 1)
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
        let yellow = EventsReportingViewController(.yellow)
        let green = EventsReportingViewController(.green)
        let red = EventsReportingViewController(.red)
        sut = StackViewController()
        sut.stack = [yellow, green, red]

        // Act
        sut.popToRootViewController(animated: false)

        // Assert
        XCTAssertEqual(yellow.allEventsTimestamps.count, 5)
        XCTAssertEqual(yellow.willBeAddedToParentTimestamps.count, 2)
        XCTAssertEqual(yellow.wasAddedToParentTimestamps.count, 1)
        XCTAssertEqual(yellow.willBeRemovedFromParentTimestamps.count, 1)
        XCTAssertEqual(yellow.wasRemovedFromParentTimestamps.count, 1)

        XCTAssertEqual(green.allEventsTimestamps.count, 4)
        XCTAssertEqual(green.willBeAddedToParentTimestamps.count, 1)
        XCTAssertEqual(green.wasAddedToParentTimestamps.count, 1)
        XCTAssertEqual(green.willBeRemovedFromParentTimestamps.count, 1)
        XCTAssertEqual(green.wasRemovedFromParentTimestamps.count, 1)

        XCTAssertEqual(red.allEventsTimestamps.count, 3)
        XCTAssertEqual(red.willBeAddedToParentTimestamps.count, 1)
        XCTAssertEqual(red.willBeRemovedFromParentTimestamps.count, 1)
        XCTAssertEqual(red.wasRemovedFromParentTimestamps.count, 1)

        let totalEvents: [TimeInterval] =
            Array(yellow.willBeAddedToParentTimestamps.prefix(1))
                + yellow.wasAddedToParentTimestamps
                + green.willBeAddedToParentTimestamps
                + green.wasAddedToParentTimestamps
                + red.willBeAddedToParentTimestamps
                + yellow.willBeRemovedFromParentTimestamps
                + yellow.wasRemovedFromParentTimestamps
                + green.willBeRemovedFromParentTimestamps
                + green.wasRemovedFromParentTimestamps
                + red.willBeRemovedFromParentTimestamps
                + red.wasRemovedFromParentTimestamps
                + Array(yellow.willBeAddedToParentTimestamps.suffix(1))
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

        let yellow = EventsReportingViewController(.yellow)

        // Act
        sut.push(yellow, animated: false)

        // Assert
        XCTAssertEqual(yellow.allEventsTimestamps.count, 7)
        XCTAssertEqual(yellow.willBeAddedToParentTimestamps.count, 1)
        XCTAssertEqual(yellow.viewDidLoadTimestamps.count, 1)
        XCTAssertEqual(yellow.beginAppearanceTransitionTimestamps.count, 1)
        XCTAssertEqual(yellow.viewWillAppearTimestamps.count, 1)
        XCTAssertEqual(yellow.endAppearanceTransitionTimestamps.count, 1)
        XCTAssertEqual(yellow.viewDidAppearTimestamps.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentTimestamps.count, 1)

        let timeline: [TimeInterval] = [
            yellow.willBeAddedToParentTimestamps.first,
            yellow.viewDidLoadTimestamps.first,
            yellow.beginAppearanceTransitionTimestamps.first,
            yellow.viewWillAppearTimestamps.first,
            yellow.endAppearanceTransitionTimestamps.first,
            yellow.viewDidAppearTimestamps.first,
            yellow.wasAddedToParentTimestamps.first
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
    //                         [viewDidAppear]
    //                         [didMoveToParent]
    //
    // note: UIKit does     => [willMoveToParent]
    //                         [viewDidLoad]
    //                         [beginAppearanceTransition]
    //                         [viewWillAppear]
    //                         [viewDidAppear]
    //                         [didMoveToParent]
    //
    func testThat_whenInitWithARootViewControllerAndSetAsWindowRootViewController_thenProperEventsAreSent() throws {
        // Arrange
        let yellow = EventsReportingViewController(.yellow)
        let sut = UINavigationController(rootViewController: yellow)

        // Act
        window.rootViewController = sut
        window.setNeedsLayout()
        window.layoutIfNeeded()

        // Assert
        let _ = waiter.wait(
            for: [
                expectation(for: yellow.willBeAddedToParentTimestamps, toBeOfSize: 1),
                expectation(for: yellow.viewDidLoadTimestamps, toBeOfSize: 1),
                expectation(for: yellow.beginAppearanceTransitionTimestamps, toBeOfSize: 1),
                expectation(for: yellow.viewWillAppearTimestamps, toBeOfSize: 1),
//                expectation(for: yellow.endAppearanceTransitionTimestamps, toBeOfSize: 1),
                expectation(for: yellow.viewDidAppearTimestamps, toBeOfSize: 1),
                expectation(for: yellow.wasAddedToParentTimestamps, toBeOfSize: 1)
            ],
            timeout: 5,
            enforceOrder: true
        )
        XCTAssertEqual(yellow.allEventsTimestamps.count, 6)
    }
}

extension StackViewControllerTests {

    func expectation(
        for timestamps: [TimeInterval],
        toBeOfSize count: Int
    ) -> XCTestExpectation {
        let predicate = NSPredicate(value: timestamps.count == count)
        let exception = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        exception.assertForOverFulfill = true
        return exception
    }
}


