//
//  MockViewController.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 13/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

struct MoveToParentDates {
    var removed: Date?
    var added: Date?
}

extension MoveToParentDates {
    var dates: [Date] {
        return [removed, added].compactMap { $0 }
    }
}

class EventReportingViewController: UIViewController, Tracing {
    var willBeAddedToParentDates: [Date] = []
    var willBeRemovedFromParentDates: [Date] = []
    var wasAddedToParentDates: [Date] = []
    var wasRemovedFromParentDates: [Date] = []

    var viewCycleEventDates: [Date] {
        return
            viewDidLoadDates
            + viewWillAppearDates
            + viewDidAppearDates
            + viewWillDisappearDates
            + viewDidDisappearDates
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
        trace(.viewLifeCycle, self, #function)
        viewDidLoadDates.append(Date())
        super.viewDidLoad()
    }

    var viewWillAppearDates: [Date] = []
    override func viewWillAppear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewWillAppearDates.append(Date())
    }

    var viewDidAppearDates: [Date] = []
    override func viewDidAppear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewDidAppearDates.append(Date())
    }

    var viewWillDisappearDates: [Date] = []
    override func viewWillDisappear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewWillDisappearDates.append(Date())
    }

    var viewDidDisappearDates: [Date] = []
    override func viewDidDisappear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewDidDisappearDates.append(Date())
    }

    // MARK: - AppearanceTransition

    var isAppearing: Bool?
    var isDisappearing: Bool?
    var isAnimated: Bool?
    
    var didCallBeginAppearanceTransition: Bool?
    var beginAppearanceTransitionDates: [Date] = []
    var beginDisappearanceTransitionDates: [Date] = []
    override func beginAppearanceTransition(_ appearing: Bool, animated: Bool) {
        didCallBeginAppearanceTransition = true
        isAnimated = animated

        if appearing {
            isAppearing = true
            beginAppearanceTransitionDates.append(Date())
        } else {
            isDisappearing = true
            beginDisappearanceTransitionDates.append(Date())
        }

        super.beginAppearanceTransition(appearing, animated: animated)
    }

    var didCallEndAppearanceTransition: Bool?
    var endAppearanceTransitionDates: [Date] = []
    var endDisppearanceTransitionDates: [Date] = []
    override func endAppearanceTransition() {
        didCallEndAppearanceTransition = true

        if case .some(true) = isAppearing {
            endAppearanceTransitionDates.append(Date())
        } else if case .some(true) = isDisappearing {
            endDisppearanceTransitionDates.append(Date())
        }

        super.endAppearanceTransition()
    }

    var didCallWillMoveToParent: Bool?
    var willMoveToParentParent: UIViewController?
    override func willMove(toParent parent: UIViewController?) {
        didCallWillMoveToParent = true
        willMoveToParentParent = parent

        if parent == nil { willBeRemovedFromParentDates.append(Date()) }
        else { willBeAddedToParentDates.append(Date()) }

        super.willMove(toParent: parent)
    }

    var didCallDidMoveToParent: Bool?
    var didMoveToParentParent: UIViewController?
    override func didMove(toParent parent: UIViewController?) {
        didCallDidMoveToParent = true
        didMoveToParentParent = parent

        if parent == nil { wasRemovedFromParentDates.append(Date()) }
        else { wasAddedToParentDates.append(Date()) }

        super.didMove(toParent: parent)
    }

    var didCallRemoveFromParent: Bool?
    override func removeFromParent() {
        didCallRemoveFromParent = true
        super.removeFromParent()
    }
}

