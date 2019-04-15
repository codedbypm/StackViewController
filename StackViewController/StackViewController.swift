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

    private lazy var popGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer()
        recognizer.edges = .left
        recognizer.delegate = self
        return recognizer
    }()

    private var interactiveAnimator: HorizontalSlideInteractiveAnimator?

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
        performTransition(from: from, to: to, animated: animated)
    }

    public func popViewController(animated: Bool) -> UIViewController? {
        guard let from = topViewController else {
            assertionFailure("Error: Cannot hide a view controller which is not on top of the stack")
            return nil
        }

        guard let to = viewControllerBefore(from) else {
            assertionFailure("Error: Cannot pop the last view controller")
            return nil
        }

        performTransition(from: from, to: to, animated: animated)
        return viewControllers.removeLast()
    }
}

// MARK: - UIViewController

public extension StackViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(popGestureRecognizer)

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

// MARK: - Private

private extension StackViewController {

    func viewControllerBefore(_ viewController: UIViewController) -> UIViewController? {
        let indexOfViewControllerInStack = viewControllers.firstIndex(of: viewController)

        guard let beforeIndex = indexOfViewControllerInStack?.advanced(by: -1), beforeIndex >= 0 else {
            return nil
        }

        return viewControllers[beforeIndex]
    }

    func animatorForTransitionFrom(_ from: UIViewController,
                                   to: UIViewController) -> UIViewControllerAnimatedTransitioning {

        if let animator = delegate?.stackViewController(self,
                                                        animationControllerForTransitionFrom: from,
                                                        to: to) {
            return animator
        } else {
            let transitionType = self.transitionType(fromViewController: from, toViewController: to)
            return HorizontalSlideAnimator(type: transitionType)
        }
    }

    func transitionContextForTransitionFrom(_ from: UIViewController,
                                            to: UIViewController,
                                            animated: Bool = true,
                                            interactive: Bool = false) -> StackViewControllerTransitionContext {

        let transitionType = self.transitionType(fromViewController: from, toViewController: to)

        let context = StackViewControllerTransitionContext(from: from,
                                                           to: to,
                                                           containerView: view,
                                                           transitionType: transitionType)
        context.isAnimated = animated
        context.isInteractive = interactive
        context.onTransitionFinished = { didComplete in
            guard didComplete else { return }

            from.view.removeFromSuperview()
            from.removeFromParent()
            from.endAppearanceTransition()

            to.didMove(toParent: self)
            to.endAppearanceTransition()
        }

        return context
    }

    func transitionType(fromViewController from: UIViewController, toViewController to: UIViewController) -> HorizontalSlideTransitionType {
        if let topViewController = topViewController, topViewController === to {
            return .slideIn
        } else {
            return .slideOut
        }
    }

    func performTransition(from: UIViewController, to: UIViewController, animated: Bool) {

        let context = transitionContextForTransitionFrom(from, to: to, animated: animated)
        let animator = animatorForTransitionFrom(from, to: to)

        from.willMove(toParent: nil)
        from.beginAppearanceTransition(false, animated: animated)

        addChild(to)
        to.beginAppearanceTransition(true, animated: animated)

        animator.animateTransition(using: context)
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

extension StackViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === popGestureRecognizer else { return false }
        return viewControllers.count > 1
    }
}
