//
//  EventsReportingViewController.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 13/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

class EventsReportingViewController: UIViewController, Tracing {

    private let color: Color
    override var description: String { return "ERVC \(color)" }

    init(_ color: Color) {
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        let view = View(description.appending(" view"))
        self.view = view
    }


    /// View life cycle
    var viewDidLoadTimestamps: [TimeInterval] = []
    var viewWillAppearTimestamps: [TimeInterval] = []
    var viewDidAppearTimestamps: [TimeInterval] = []
    var viewWillDisappearTimestamps: [TimeInterval] = []
    var viewDidDisappearTimestamps: [TimeInterval] = []

    /// Appearance transition
    var beginAppearanceTransitionTimestamps: [TimeInterval] = []
    var beginDisappearanceTransitionTimestamps: [TimeInterval] = []
    var endAppearanceTransitionTimestamps: [TimeInterval] = []
    var endDisppearanceTransitionTimestamps: [TimeInterval] = []

    /// View controller containment
    var willBeAddedToParentTimestamps: [TimeInterval] = []
    var wasAddedToParentTimestamps: [TimeInterval] = []
    var willBeRemovedFromParentTimestamps: [TimeInterval] = []
    var wasRemovedFromParentTimestamps: [TimeInterval] = []

    /// All events
    var allEventsTimestamps: [TimeInterval] {
        return viewLifeCycleTimestamps
            + appearanceTransitionTimestamps
            + viewControllerContainmentTimestamps
    }

    /// Misc
    var isAppearing: Bool?
    var isDisappearing: Bool?
    var isAnimated: Bool?
    var didCallBeginAppearanceTransition: Bool?
    var didCallEndAppearanceTransition: Bool?
    var didCallWillMoveToParent: Bool?
    var willMoveToParentParent: UIViewController?
    var didCallDidMoveToParent: Bool?
    var didMoveToParentParent: UIViewController?
    var didCallRemoveFromParent: Bool?
}

// MARK: - View Life Cycle

extension EventsReportingViewController {

    var viewLifeCycleTimestamps: [TimeInterval] {
        return viewDidLoadTimestamps
            + viewWillAppearTimestamps
            + viewDidAppearTimestamps
            + viewWillDisappearTimestamps
            + viewDidDisappearTimestamps
    }

    override func viewDidLoad() {
        trace(.viewLifeCycle, self, #function)
        viewDidLoadTimestamps.append(Date().timeIntervalSinceReferenceDate)
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewWillAppearTimestamps.append(Date().timeIntervalSinceReferenceDate)
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewDidAppearTimestamps.append(Date().timeIntervalSinceReferenceDate)
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewWillDisappearTimestamps.append(Date().timeIntervalSinceReferenceDate)
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        trace(.viewLifeCycle, self, #function)
        viewDidDisappearTimestamps.append(Date().timeIntervalSinceReferenceDate)
        super.viewDidDisappear(animated)
    }
}

// MARK: - Appearance transition

extension EventsReportingViewController {

    var appearanceTransitionTimestamps: [TimeInterval] {
        return beginAppearanceTransitionTimestamps
            + beginDisappearanceTransitionTimestamps
            + endAppearanceTransitionTimestamps
            + endDisppearanceTransitionTimestamps
    }

    override func beginAppearanceTransition(_ appearing: Bool, animated: Bool) {
        didCallBeginAppearanceTransition = true
        isAnimated = animated

        if appearing {
            trace(.appearanceTransitions, self, #function, "isAppearing")
            isAppearing = true
            beginAppearanceTransitionTimestamps.append(Date().timeIntervalSinceReferenceDate)
        } else {
            trace(.appearanceTransitions, self, #function, "isDisappearing")
            isDisappearing = true
            beginDisappearanceTransitionTimestamps.append(Date().timeIntervalSinceReferenceDate)
        }

        super.beginAppearanceTransition(appearing, animated: animated)
    }

    override func endAppearanceTransition() {
        didCallEndAppearanceTransition = true

        if case .some(true) = isAppearing {
            trace(.appearanceTransitions, self, #function, "hasAppeared")
            endAppearanceTransitionTimestamps.append(Date().timeIntervalSinceReferenceDate)
        } else if case .some(true) = isDisappearing {
            trace(.appearanceTransitions, self, #function, "hasDisappeared")
            endDisppearanceTransitionTimestamps.append(Date().timeIntervalSinceReferenceDate)
        }
        super.endAppearanceTransition()
    }
}

// MARK: - View controller containment

extension EventsReportingViewController {

    var viewControllerContainmentTimestamps: [TimeInterval] {
        return willBeAddedToParentTimestamps
            + wasAddedToParentTimestamps
            + willBeRemovedFromParentTimestamps
            + wasRemovedFromParentTimestamps
    }

    override func willMove(toParent parent: UIViewController?) {
        didCallWillMoveToParent = true
        willMoveToParentParent = parent

        if parent == nil {
            trace(.viewControllerContainment, self, #function, "nil")
            willBeRemovedFromParentTimestamps.append(Date().timeIntervalSinceReferenceDate)
        } else {
            trace(.viewControllerContainment, self, #function)
            willBeAddedToParentTimestamps.append(Date().timeIntervalSinceReferenceDate)
        }

        super.willMove(toParent: parent)
    }

    override func didMove(toParent parent: UIViewController?) {
        didCallDidMoveToParent = true
        didMoveToParentParent = parent

        if parent == nil {
            trace(.viewControllerContainment, self, #function, "nil")
            wasRemovedFromParentTimestamps.append(Date().timeIntervalSinceReferenceDate)
        } else {
            trace(.viewControllerContainment, self, #function)
            wasAddedToParentTimestamps.append(Date().timeIntervalSinceReferenceDate)
        }

        super.didMove(toParent: parent)
    }

    override func removeFromParent() {
        didCallRemoveFromParent = true
        super.removeFromParent()
    }
}

