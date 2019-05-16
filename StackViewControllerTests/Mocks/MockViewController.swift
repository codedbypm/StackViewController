//
//  MockViewController.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 13/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

class MockViewController: UIViewController {

    var appearanceEventDates: [Date?] {
        return [beginAppearanceTransitionDate, endAppearanceTransitionDate]
    }

    var viewContainmentEventDates: [Date?] {
        return [willMoveToParentDate, didMoveToParentDate]
    }

    var events: [Date?] {
        return appearanceEventDates + viewContainmentEventDates
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
    var willMoveToParentDate: Date?
    var willMoveToParentParent: UIViewController?
    override func willMove(toParent parent: UIViewController?) {
        didCallWillMoveToParent = true
        willMoveToParentDate = Date()
        willMoveToParentParent = parent
    }

    var didCallDidMoveToParent: Bool?
    var didMoveToParentDate: Date?
    var didMoveToParentParent: UIViewController?
    override func didMove(toParent parent: UIViewController?) {
        didCallDidMoveToParent = true
        didMoveToParentDate = Date()
        didMoveToParentParent = parent
    }

    var didCallRemoveFromParent: Bool?
    override func removeFromParent() {
        didCallRemoveFromParent = true
    }
}

