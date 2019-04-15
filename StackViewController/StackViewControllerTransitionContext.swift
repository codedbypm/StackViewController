//
//  StackViewControllerTransitionContext.swift
//  StackViewController
//
//  Created by Paolo Moroni on 03/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewControllerContextTransitioning: UIViewControllerContextTransitioning {
    var frameOfViewWhenOffScreen: CGRect { get }
}

class StackViewControllerTransitionContext: NSObject, StackViewControllerContextTransitioning {

    let containerView: UIView
    var isAnimated: Bool = false
    var isInteractive: Bool = false
    var transitionWasCancelled: Bool = false
    var presentationStyle: UIModalPresentationStyle = .custom
    var targetTransform: CGAffineTransform = .identity
    var onTransitionFinished: ((Bool) -> Void)?

    var frameOfViewWhenOffScreen: CGRect {
        let horizontalOffset = containerView.bounds.width
        return containerView.bounds.offsetBy(dx: horizontalOffset, dy: 0.0)
    }

    // MARK: - Private properties

    private let transitionType: HorizontalSlideTransitionType
    private var viewControllers: [UITransitionContextViewControllerKey: UIViewController]
    private var views: [UITransitionContextViewKey: UIView] {
        var views = [UITransitionContextViewKey: UIView]()

        if let fromView = view(forKey: .from) {
            views[.from] = fromView
        }

        if let toView = view(forKey: .to) {
            views[.to] = toView
        }
        return views
    }

    // MARK: - Init

    init(from: UIViewController,
         to: UIViewController,
         containerView: UIView,
         transitionType: HorizontalSlideTransitionType) {
        self.containerView = containerView
        viewControllers = [.from: from, .to: to]
        self.transitionType = transitionType
    }

    func completeTransition(_ didComplete: Bool) {
        onTransitionFinished?(didComplete)
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return viewControllers[key]
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        if case .from = key, let fromVC = viewControllers[.from], fromVC.isViewLoaded {
            return fromVC.view
        }

        if case .to = key, let toVC = viewControllers[.to], toVC.isViewLoaded {
            return toVC.view
        }

        return nil
    }

    func initialFrame(for vc: UIViewController) -> CGRect {
        if vc == viewController(forKey: .from) {
            return containerView.bounds
        }
        return .zero
    }

    func finalFrame(for vc: UIViewController) -> CGRect {
        if vc == viewController(forKey: .to) {
            return containerView.bounds
        }
        return .zero
    }
}

// MARK: - Interactive transition

extension StackViewControllerTransitionContext {

    func updateInteractiveTransition(_ percentComplete: CGFloat) {}

    func finishInteractiveTransition() {}

    func cancelInteractiveTransition() {}

    func pauseInteractiveTransition() {}
}

