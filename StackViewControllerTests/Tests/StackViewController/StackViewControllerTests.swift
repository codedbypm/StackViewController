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
    //       window == nil
    // then: no events
    //
    func testThat_initWithEmptyStack_itReceivesAndSendsProperEvents() throws {
        // Arrange

        // Act
        sut = MockStackViewController()

        // Assert
        let mockSut = try XCTUnwrap(sut as? MockStackViewController)
        XCTAssertEqual(mockSut.receivedEventDates.count, 0)
    }

    // when: stack = []
    //       window == nil
    //       pushViewController
    //
    // then: receives           => [pushViewController]
    //       sends to yellow    => [willMoveToParent]
    //
    // note: UINC receives viewDidLoad too
    //
    func testThat_whenInitWithEmptyStack_and_pushViewController_thenItReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = MockViewController()
        let sut = MockStackViewController()

        // Act
        sut.push(yellow, animated: false)

        // Assert
        XCTAssertEqual(sut.receivedEventDates.count, 1)
        XCTAssertEqual(sut.pushViewControllerDates.count, 1)

        XCTAssertEqual(yellow.receivedEventDates.count, 1)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)

        let timeline: [Date] = [
            sut.pushViewControllerDates.first,
            yellow.willBeAddedToParentDates.first
        ].compactMap { $0 }

        XCTAssertEqual(timeline, timeline.sorted())
    }

    // when: stack = [yellow, green]
    //       window == nil
    //       sut.stack = [red, black]
    //
    // then: receives           =>  [viewControllers]
    //                              [setViewControllers]
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
    func testThat_whenReplacingNonEmptyStackWithAnotherNonEmptyStack_thenItReceivesAndSendsProperEvents() throws {
        // Arrange
        let yellow = MockViewController()
        let green = MockViewController()
        sut = MockStackViewController()
        sut.stack = [yellow, green]

        let red = MockViewController()
        let black = MockViewController()

        // Act
        sut.stack = [red, black]

        // Assert
        let sut = try XCTUnwrap(self.sut as? MockStackViewController)
        XCTAssertEqual(sut.receivedEventDates.count, 4)
        XCTAssertEqual(sut.stackSetterDates.count, 2)
        XCTAssertEqual(sut.setStackDates.count, 2)

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
    //       window == nil
    //
    // then: receives           => [pushViewController]
    //       sends to yellow    => [willMoveToParent]
    //
    // note: UINC receives viewDidLoad too
    //
    func testThat_whenInitWithARootViewController_thenItReceivesAndSendsProperEvents() throws {
        // Arrange
        let yellow = MockViewController()

        // Act
        sut = MockStackViewController(rootViewController: yellow)

        // Assert
        let sut = try XCTUnwrap(self.sut as? MockStackViewController)
        XCTAssertEqual(sut.receivedEventDates.count, 1)
        XCTAssertEqual(sut.pushViewControllerDates.count, 1)

        XCTAssertEqual(yellow.receivedEventDates.count, 1)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)

        let timeline: [Date] = [
            sut.pushViewControllerDates.first,
            yellow.willBeAddedToParentDates.first
        ].compactMap { $0 }

        XCTAssertEqual(timeline, timeline.sorted())


    }

    // when: stack = [yellow, green, red], popToRootViewController
    // then: receives           =>  [viewControllers],
    //                              [setViewControllers],
    //                              [popToRootViewController]
    //       sends to yellow    =>  [willMoveToParent: sut],
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
    func testThat_whenCallingPopToRootViewControllerOnNonEmptyStack_itReceivesAndSendsProperEvents() throws {
        // Arrange
        let yellow = MockViewController()
        let green = MockViewController()
        let red = MockViewController()
        sut = MockStackViewController()
        sut.stack = [yellow, green, red]

        // Act
        sut.popToRootViewController(animated: false)

        // Assert
        let sut = try XCTUnwrap(self.sut as? MockStackViewController)
        XCTAssertEqual(sut.receivedEventDates.count, 3)
        XCTAssertEqual(
            sut.receivedEventDates,
            sut.stackSetterDates + sut.setStackDates + sut.popToRootDates
        )

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
            sut.stackSetterDates
                + sut.setStackDates
                + Array(yellow.willBeAddedToParentDates.prefix(1))
                + yellow.wasAddedToParentDates
                + green.willBeAddedToParentDates
                + green.wasAddedToParentDates
                + red.willBeAddedToParentDates
                + sut.popToRootDates
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
    //       window != nil
    // then: no events
    //
    func testThat_initWithEmptyStackAndWindowIsNotNil_itReceivesAndSendsProperEvents() throws {
        // Arrange
        window = UIWindow()

        // Act
        sut = MockStackViewController()
        window.rootViewController = sut
        window.makeKeyAndVisible()

        // Assert
        let mockSut = try XCTUnwrap(sut as? MockStackViewController)
        XCTAssertEqual(mockSut.receivedEventDates.count, 3)
        XCTAssertEqual(mockSut.viewDidLoadDates.count, 1)
        XCTAssertEqual(mockSut.viewWillAppearDates.count, 1)
        XCTAssertEqual(mockSut.viewDidAppearDates.count, 1)
    }

    // when: stack = []
    //       window != nil
    //       pushViewController
    //
    // then: receives           => [viewDidLoad]
    //                             [viewWillAppear]
    //                             [viewDidAppear]
    //                             [push]
    //       sends to yellow    => [willMoveToParent]
    //                             [viewDidLoad]
    //                             [beginAppearanceTransition]
    //                             [viewWillAppear]
    //                             [endAppearanceTransition]
    //                             [viewDidAppear]
    //                             [didMoveToParent]
    //
    // note: UINC does not send [endAppearanceTransition]
    func testThat_whenInitWithEmptyStackWhenWindowIsNotNilAndPushViewController_thenItReceivesAndSendsProperEvents() {
        // Arrange
        let window = UIWindow()
        let sut = MockStackViewController()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        let yellow = MockViewController()

        // Act
        sut.push(yellow, animated: false)

        // Assert
        XCTAssertEqual(sut.receivedEventDates.count, 4)
        XCTAssertEqual(sut.viewDidLoadDates.count, 1)
        XCTAssertEqual(sut.viewWillAppearDates.count, 1)
        XCTAssertEqual(sut.viewDidAppearDates.count, 1)
        XCTAssertEqual(sut.pushViewControllerDates.count, 1)

        XCTAssertEqual(yellow.receivedEventDates.count, 7)
        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.viewDidLoadDates.count, 1)
        XCTAssertEqual(yellow.beginAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.viewWillAppearDates.count, 1)
        XCTAssertEqual(yellow.endAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.viewDidAppearDates.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentDates.count, 1)

        let timeline: [Date] = [
            sut.pushViewControllerDates.first,
            yellow.willBeAddedToParentDates.first
        ].compactMap { $0 }

        XCTAssertEqual(timeline, timeline.sorted())
    }

    // when: stack = [yellow]
    //       window != nil
    //
    // then: receives    => [pushViewController],
    //                      [viewDidLoad]
    //                      [viewWillAppear]
    //                      [viewDidAppear]
    //       yellow      => [willMoveToParent]
    //                      [viewDidLoad]
    //                      [viewWillAppear]
    //                      [viewDidAppear]
    //                      [didMoveToParent]
    //
    func testThat_whenInitWithARootViewControllerAndViewIsAddedToWindow_thenItReceivesAndSendsProperEvents() throws {
        // Arrange
        let yellow = MockViewController()
        window = UIWindow()

        // Act
        sut = MockStackViewController(rootViewController: yellow)
        window.rootViewController = sut
        window.makeKeyAndVisible()

        // Assert
        let sut = try XCTUnwrap(self.sut as? MockStackViewController)
        XCTAssertEqual(sut.pushViewControllerDates.count, 1)
        XCTAssertEqual(sut.viewDidLoadDates.count, 1)
        XCTAssertEqual(sut.viewWillAppearDates.count, 1)
        XCTAssertEqual(sut.viewDidAppearDates.count, 1)
        XCTAssertEqual(sut.receivedEventDates.count, 4)

        XCTAssertEqual(yellow.willBeAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.viewDidLoadDates.count, 1)
        XCTAssertEqual(yellow.beginAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.endAppearanceTransitionDates.count, 1)
        XCTAssertEqual(yellow.wasAddedToParentDates.count, 1)
        XCTAssertEqual(yellow.receivedEventDates.count, 5)

        let timeline: [Date] = [
            sut.pushViewControllerDates.first,
            yellow.willBeAddedToParentDates.first,
            sut.viewDidLoadDates.first,
            yellow.viewDidLoadDates.first,
            sut.viewWillAppearDates.first,
            yellow.beginAppearanceTransitionDates.first,
            sut.viewDidAppearDates.first,
            yellow.endAppearanceTransitionDates.first,
            yellow.wasAddedToParentDates.first
        ].compactMap { $0 }

        XCTAssertEqual(timeline, timeline.sorted(), "\(timeline.sorted().difference(from: timeline))")
    }

}
