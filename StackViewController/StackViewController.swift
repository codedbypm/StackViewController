//
//  StackViewController.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

public protocol StackViewControllerHandling: UIViewController {
    func popViewController(animated: Bool) -> UIViewController?
    func pushViewController(_: UIViewController, animated: Bool)
}

public protocol StackViewControllerDelegate: class {
    func stackViewController(_: StackViewController,
                             animationControllerForTransitionFrom from: UIViewController,
                             to: UIViewController) -> UIViewControllerAnimatedTransitioning?

}

public class StackViewController: UIViewController, StackViewControllerHandling {

    // MARK: - Public properties

    public weak var delegate: StackViewControllerDelegate?

    public var viewControllers: [UIViewController] = []

    public var topViewController: UIViewController? {
        return viewControllers.last
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    // MARK: - Private properties

    private lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        return recognizer
    }()

    private var interactiveController: HorizontalSlideInteractiveController?

    // MARK: - Init

    public required init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Public methods

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard isViewLoaded else {
            assertionFailure("Error: Cannot push a view controller before the \(String(describing: self))'s view is loaded")
            return
        }

        guard let from = topViewController else {
            showTopViewController()
            return
        }

        let to = viewController

        viewControllers.append(viewController)
        performTransition(from: from, to: to, animated: animated, interactive: false)
    }

    public func popViewController(animated: Bool) -> UIViewController? {
        let last = viewControllers.last
        _popViewController(animated: animated)
        return last
    }

    public func _popViewController(animated: Bool) {

        guard let from = topViewController else {
            assertionFailure("Error: Cannot hide a view controller which is not on top of the stack")
            return
        }

        guard let to = viewControllerBefore(from) else {
            assertionFailure("Error: Cannot pop the last view controller")
            return
        }

        performTransition(from: from, to: to, animated: animated, interactive: false)
    }
}

// MARK: - UIViewController

public extension StackViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(screenEdgePanGestureRecognizer)

        showTopViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topViewController?.endAppearanceTransition()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension StackViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === screenEdgePanGestureRecognizer {
            return screenEdgePanGestureRecognizerShouldBegin()
        } else {
            return false
        }
    }

    private func screenEdgePanGestureRecognizerShouldBegin() -> Bool {
        guard interactiveController == nil else { return false }
        guard let from = topViewController else { return false }
        guard let to = viewControllerBefore(from) else { return false }

        performInteractiveTransition(from: from, to: to)
        return true
    }
}

// MARK: - Transition

private extension StackViewController {

    func performInteractiveTransition(from: UIViewController, to: UIViewController) {
        performTransition(from: from, to: to, animated: true, interactive: true)
    }

    func performTransition(from: UIViewController, to: UIViewController, animated: Bool, interactive: Bool) {
        let transitionType = self.transitionType(fromViewController: from, toViewController: to)

        let context = transitionContextForTransition(from: from,
                                                     to: to,
                                                     animated: animated,
                                                     interactive: interactive)

        context.onTransitionFinished = { didComplete in
            defer { self.interactiveController = nil }

            guard didComplete else { return }

            self.sendFinalViewAppearanceEvents(from: from, to: to)

            if transitionType == .slideOut {
                self.viewControllers.removeLast()
            }
        }

        sendInitialViewAppearanceEvents(from: from, to: to, animated: animated)

        let animationController = animatorForTransition(from: from, to: to)

        if interactive {
            interactiveController = HorizontalSlideInteractiveController(animationController: animationController,
                                                                         gestureRecognizer: screenEdgePanGestureRecognizer,
                                                                         context: context)
        } else {
            animationController.animateTransition(using: context)
        }
    }

    func sendInitialViewAppearanceEvents(from: UIViewController, to: UIViewController, animated: Bool) {
        from.willMove(toParent: nil)
        from.beginAppearanceTransition(false, animated: animated)

        addChild(to)
        to.beginAppearanceTransition(true, animated: animated)
    }

    func sendFinalViewAppearanceEvents(from: UIViewController, to: UIViewController) {
        from.view.removeFromSuperview()
        from.removeFromParent()
        from.endAppearanceTransition()

        to.didMove(toParent: self)
        to.endAppearanceTransition()
    }

    func showTopViewController() {
        guard let to = topViewController else {
            assertionFailure("Error: trying to show the top viewController but there are no view controllers in the stack")
            return
        }

        addChild(to)
        view.addSubview(to.view)
        to.view.pinEdgesToSuperView()
        to.didMove(toParent: self)
    }
}

// MARK: - Object creation

private extension StackViewController {

    func viewControllerBefore(_ viewController: UIViewController) -> UIViewController? {
        let indexOfViewControllerInStack = viewControllers.firstIndex(of: viewController)

        guard let beforeIndex = indexOfViewControllerInStack?.advanced(by: -1), beforeIndex >= 0 else {
            return nil
        }

        return viewControllers[beforeIndex]
    }

    func animatorForTransition(from: UIViewController,
                               to: UIViewController) -> UIViewControllerAnimatedTransitioning {

        if let animator = delegate?.stackViewController(self,
                                                        animationControllerForTransitionFrom: from,
                                                        to: to) {
            return animator
        } else {
            let transitionType = self.transitionType(fromViewController: from, toViewController: to)
            return HorizontalSlideAnimationController(type: transitionType)
        }
    }

    func transitionContextForTransition(from: UIViewController,
                                        to: UIViewController,
                                        animated: Bool = true,
                                        interactive: Bool = false) -> StackViewControllerTransitionContext {

        let context = StackViewControllerTransitionContext(from: from,
                                                           to: to,
                                                           containerView: view)
        context.isAnimated = animated
        context.isInteractive = interactive

        return context
    }

    func transitionType(fromViewController from: UIViewController, toViewController to: UIViewController) -> HorizontalSlideTransitionType {
        if let topViewController = topViewController, topViewController === to {
            return .slideIn
        } else {
            return .slideOut
        }
    }
}
