//
//  MockViewController.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 13/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

struct MoveToParentDates {
    var removed: Date?
    var added: Date?
}

extension MoveToParentDates {
    var dates: [Date] {
        return [removed, added].compactMap { $0 }
    }
}

class MockViewController: UIViewController {
    var willBeAddedToParentDates: [Date] = []
    var willBeRemovedFromParentDates: [Date] = []
    var wasAddedToParentDates: [Date] = []
    var wasRemovedFromParentDates: [Date] = []

    var appearanceEventDates: [Date] {
        return [beginAppearanceTransitionDate, endAppearanceTransitionDate].compactMap { $0 }
    }

    var viewContainmentEventDates: [Date] {
        return willBeAddedToParentDates + wasAddedToParentDates + willBeRemovedFromParentDates + wasRemovedFromParentDates
    }

    var receivedEventDates: [Date] {
        return (appearanceEventDates + viewContainmentEventDates)
    }

    var didCallBeginAppearance: Bool? = nil
    var beginAppearanceIsAppearing: Bool? = nil
    var beginAppearanceAnimated: Bool? = nil
    var beginAppearanceTransitionDate: Date?
    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        didCallBeginAppearance = true
        beginAppearanceIsAppearing = isAppearing
        beginAppearanceAnimated = animated
        beginAppearanceTransitionDate = Date()
    }

    var didCallEndAppearance: Bool? = nil
    var endAppearanceTransitionDate: Date?
    override func endAppearanceTransition() {
        didCallEndAppearance = true
        endAppearanceTransitionDate = Date()
    }

    var didCallWillMoveToParent: Bool?
    var willMoveToParentParent: UIViewController?
    override func willMove(toParent parent: UIViewController?) {
        didCallWillMoveToParent = true
        willMoveToParentParent = parent

        if parent == nil { willBeRemovedFromParentDates.append(Date()) }
        else { willBeAddedToParentDates.append(Date()) }
    }

    var didCallDidMoveToParent: Bool?
    var didMoveToParentParent: UIViewController?
    override func didMove(toParent parent: UIViewController?) {
        didCallDidMoveToParent = true
        didMoveToParentParent = parent

        if parent == nil { wasRemovedFromParentDates.append(Date()) }
        else { wasAddedToParentDates.append(Date()) }
    }

    var didCallRemoveFromParent: Bool?
    override func removeFromParent() {
        didCallRemoveFromParent = true
        super.removeFromParent()
    }
}

