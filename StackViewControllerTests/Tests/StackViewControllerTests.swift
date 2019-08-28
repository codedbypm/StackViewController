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

    // when: stack = []
    //
    // then: no events
    //
    func testThat_init_itReceivesAndSendsProperEvents() {
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
    //
    // then: receives => [pushViewController, viewDidLoad]
    //       sends    => [willMoveToParent]
    //
    func testThat_initFollowedByPushViewController_itReceivesAndSendsProperEvents() {
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
            [sut.pushViewControllerDate, sut.viewDidLoadDate]
        )
        XCTAssertEqual(yellow.receivedEventDates, [yellow.willMoveToParentDate])
    }

    // when: stack = [] and .viewControllers = [yellow]
    //
    // then: receives => [viewControllers, setViewControllers]
    //       sends    => [willMoveToParent]
    //
    func testThat_initFollowedBySetViewControllers_itReceivesAndSendsProperEvents() {
        // Arrange
        let yellow = MockViewController()
        sut = MockStackViewController()

        // Act
        sut.viewControllers = [yellow]

        // Assert
        guard let sut = sut as? MockStackViewController else {
            XCTFail("Expected sut of type MockStackViewController")
            return
        }

        XCTAssertEqual(
            sut.receivedEventDates,
            [sut.viewControllersSetterDate, sut.setStackDate]
        )
        XCTAssertEqual(yellow.receivedEventDates, [yellow.willMoveToParentDate])
    }

    // MARK: - init(rootViewController:)

    // when: stack = [yellow]
    //
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
            [sut.pushViewControllerDate, sut.viewDidLoadDate]
        )
        XCTAssertEqual(yellow.receivedEventDates, [yellow.willMoveToParentDate])
    }


    //    StackVC  =>  viewDidLoad()
    //    StackVC  =>  viewWillAppear(_:)
    //    Yellow   =>  viewWillAppear(_:)
    //    StackVC  =>  viewDidAppear(_:)
    //    Yellow   =>  viewDidAppear(_:)
    //    StackVC  =>  didMoveToParent(_:)

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

    // MARK: - didAddStackElements(_: Stack)

    /// UIKit sends the event in this sequence
    ///
    /// - VC1 willMove
    /// - VC1 didMove
    /// - VC2 willMove
    /// - ...
    ///
    /// To guarantee the same behavior, this tests mark for each view controller the time stamp of
    /// both calls `willMoveToParent` and `didMoveToPatent`. After that, flatMapping the sequence got
    /// from zip(willDates, didDates) and adding the very last willMove, will give the ordered
    /// array of timestamps.
//    func testThat_whenAddingElementsToTheStack_theViewContainmentEventsAreSentTheSameWayUIKitDoes() {
//        // Arrange
//        sut = StackViewController.withEmptyStack()
//        let stack: [MockViewController] = Stack.distinctElements(4)
//
//        // Act
////        sut.didAddStackElements(stack)
//
//        // Assert
//        let willMoveDates = stack.compactMap { $0.willMoveToParentDate }
//        XCTAssertEqual(willMoveDates.count, 4)
//
//        let didMoveDates = stack.compactMap { $0.didMoveToParentDate }
//        XCTAssertEqual(didMoveDates.count, 3)
//
//        var flattenedDates = zip(willMoveDates, didMoveDates).flatMap({ return [$0, $1] })
//        flattenedDates.append(contentsOf: willMoveDates.suffix(1))
//        XCTAssertEqual(flattenedDates, flattenedDates.sorted())
//        XCTAssertEqual(flattenedDates.count, 7)
//    }
//
//    // MARK: - didRemoveStackElements(_: Stack)
//
//    func testThat_whenRemovingElementsFromTheStack_theViewContainmentEventsAreSentTheSameWayUIKitDoes() {
//        // Arrange
//        let stack: [MockViewController] = Stack.distinctElements(4)
//        sut = StackViewController(viewControllers: stack)
//
//        // Act
////        sut.didRemoveStackElements(stack)
//
//        // Assert
//        let willMoveDates = stack.compactMap { $0.willMoveToParentDate }
//        XCTAssertEqual(willMoveDates.count, 4)
//
//        let didMoveDates = stack.compactMap { $0.didMoveToParentDate }
//        XCTAssertEqual(didMoveDates.count, 4)
//
//        let flattenedDates = zip(willMoveDates, didMoveDates).flatMap({ return [$0, $1] })
//        XCTAssertEqual(flattenedDates, flattenedDates.sorted())
//        XCTAssertEqual(flattenedDates.count, 8)
//    }


//    Start NC with stack = [Black, Red, Green]
//  
//    [UIKit] Black    =>    willMove(toParent:)
//    [UIKit] Black    =>    didMove(toParent:)
//    [UIKit] Red    =>    willMove(toParent:)
//    [UIKit] Red    =>    didMove(toParent:)
//    [UIKit] Green    =>    willMove(toParent:)
//    func testThat_whenInitWithANonEmptyStack_itSendsCorrectSequenceOfEventsToHisChildren() {
//        // Arrange
//        let stack: [MockViewController] = Stack.distinctElements(3)
//
//        // Act
//        sut = StackViewController(viewControllers: stack)
//
//        // Assert
//        let willMoveDates = stack.compactMap { $0.willMoveToParentDate }
//        XCTAssertEqual(willMoveDates.count, 3)
//
//        let didMoveDates = stack.compactMap { $0.didMoveToParentDate }
//        XCTAssertEqual(didMoveDates.count, 2)
//
//        var flattenedDates = zip(willMoveDates, didMoveDates).flatMap({ return [$0, $1] })
//        flattenedDates.append(contentsOf: willMoveDates.suffix(1))
//        XCTAssertEqual(flattenedDates, flattenedDates.sorted())
//        XCTAssertEqual(flattenedDates.count, 5)
//    }
}
