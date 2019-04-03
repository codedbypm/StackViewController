//
//  StackViewControllerTransitionContext.swift
//  StackViewController
//
//  Created by Paolo Moroni on 03/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

class StackViewControllerTransitionContext: NSObject, UIViewControllerContextTransitioning {

    let containerView: UIView
    var isAnimated: Bool = false
    var isInteractive: Bool = false
    var transitionWasCancelled: Bool = false
    var presentationStyle: UIModalPresentationStyle = .custom
    var targetTransform: CGAffineTransform = .identity

    // MARK: - Private properties

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

    init(from: UIViewController, to: UIViewController, containerView: UIView) {
        self.containerView = containerView
        viewControllers = [.from: from, .to: to]
    }

    func completeTransition(_ didComplete: Bool) {
        
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
        if let from = viewController(forKey: .from), from === vc {
            return containerView.bounds
        }

        return .zero
    }

    func finalFrame(for vc: UIViewController) -> CGRect {
        if let to = viewController(forKey: .to), to === vc {
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

