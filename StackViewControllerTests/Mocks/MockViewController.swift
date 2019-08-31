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

    var viewCycleEventDates: [Date] {
        return
            viewDidLoadDates
            + viewWillAppearDates
            + viewDidAppearDates
    }

    var appearanceEventDates: [Date] {
        return beginAppearanceTransitionDates
            + beginDisappearanceTransitionDates
            + endAppearanceTransitionDates
            + endDisppearanceTransitionDates
    }

    var viewContainmentEventDates: [Date] {
        return willBeAddedToParentDates
            + wasAddedToParentDates
            + willBeRemovedFromParentDates
            + wasRemovedFromParentDates
    }

    var receivedEventDates: [Date] {
        return (viewCycleEventDates + appearanceEventDates + viewContainmentEventDates)
    }

    var viewDidLoadDates: [Date] = []
    override func viewDidLoad() {
        viewDidLoadDates.append(Date())
        super.viewDidLoad()
    }

    var viewWillAppearDates: [Date] = []
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearDates.append(Date())
    }

    var viewDidAppearDates: [Date] = []
    override func viewDidAppear(_ animated: Bool) {
        viewDidAppearDates.append(Date())
    }

    var viewWillDisappearDates: [Date] = []
    override func viewWillDisappear(_ animated: Bool) {
        viewWillDisappearDates.append(Date())
    }

    var viewDidDisappearDates: [Date] = []
    override func viewDidDisappear(_ animated: Bool) {
        viewDidDisappearDates.append(Date())
    }

    var didCallBeginAppearance: Bool? = nil
    var beginAppearanceIsAppearing: Bool? = nil
    var beginAppearanceAnimated: Bool? = nil
    var beginAppearanceTransitionDates: [Date] = []
    var beginDisappearanceTransitionDates: [Date] = []
    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        didCallBeginAppearance = true
        beginAppearanceIsAppearing = isAppearing
        beginAppearanceAnimated = animated
        if isAppearing { beginAppearanceTransitionDates.append(Date()) }
        else { beginDisappearanceTransitionDates.append(Date()) }
    }

    var didCallEndAppearance: Bool? = nil
    var endAppearanceTransitionDates: [Date] = []
    var endDisppearanceTransitionDates: [Date] = []
    override func endAppearanceTransition() {
        didCallEndAppearance = true
        switch beginAppearanceIsAppearing {
        case .some(true): endAppearanceTransitionDates.append(Date())
        case .some(false): endDisppearanceTransitionDates.append(Date())
        case .none: break
        }
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

