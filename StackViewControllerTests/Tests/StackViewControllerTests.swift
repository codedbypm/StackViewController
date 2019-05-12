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

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - didAddStackElements(_: Stack)

    func testThat_itCallsAddChildForEachElement() {
        // Arrange
        sut = StackViewController.withEmptyStack()
        let numberOfElements = 4
        let stack = Stack.distinctElements(numberOfElements)

        XCTAssertTrue(sut.children.isEmpty)

        // Act
        sut.didAddStackElements(stack)

        // Assert
        XCTAssertEqual(sut.children, stack)
    }

    func testThat_itCallsDidMoveToParentForEachElementBesidesTheLastOne() {
        // Arrange
        class MockViewController: UIViewController {
            var didCallDidMoveToParent = false
            var passedParent: UIViewController?
            override func didMove(toParent parent: UIViewController?) {
                didCallDidMoveToParent = true
                passedParent = parent
            }
        }

        sut = StackViewController.withEmptyStack()
        let numberOfElements = 4
        let stack: [MockViewController] = Stack.distinctElements(numberOfElements)

        XCTAssertEqual(stack.map { $0.didCallDidMoveToParent }, [false, false, false, false])
        XCTAssertEqual(stack.map { $0.passedParent }, [nil, nil, nil, nil])

        // Act
        sut.didAddStackElements(stack)

        // Assert
        XCTAssertEqual(stack.map { $0.didCallDidMoveToParent }, [true, true, true, false])
        XCTAssertEqual(stack.map { $0.passedParent }, [sut, sut, sut, nil])
    }

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
    func testThat_itCallsAddChildForElementXPlusOne_OnlyAfterHavingCalledDidMoveToParentForElementX() {
        // Arrange
        class MockViewController: UIViewController {
            var willMoveToParentDate: Date?
            var didMoveToParentDate: Date?
            override func willMove(toParent parent: UIViewController?) { willMoveToParentDate = Date() }
            override func didMove(toParent parent: UIViewController?) { didMoveToParentDate = Date() }
        }

        sut = StackViewController.withEmptyStack()
        let numberOfElements = 4
        let stack: [MockViewController] = Stack.distinctElements(numberOfElements)

        // Act
        sut.didAddStackElements(stack)

        // Assert
        let willDates = stack.compactMap { $0.willMoveToParentDate }
        let didDates = stack.compactMap { $0.didMoveToParentDate }

        var flattenedDates = zip(willDates, didDates).flatMap({ return [$0, $1] })
        flattenedDates.append(contentsOf: willDates.suffix(1))

        XCTAssertEqual(flattenedDates, flattenedDates.sorted())
        XCTAssertEqual(flattenedDates.count, 7)
    }
}
