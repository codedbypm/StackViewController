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
        guard didComplete else {
            return
        }

        view(forKey: .from)?.removeFromSuperview()
        viewController(forKey: .from)?.didMove(toParent: nil)
        viewController(forKey: .to)?.didMove(toParent: viewController(forKey: .from)?.parent)
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
        switch transitionType {
        case .slideIn:
            if let from = viewController(forKey: .from), from === vc {
                return containerView.bounds
            }
            return containerView.bounds.offsetBy(dx: containerView.bounds.width, dy: 0.0)
        case .slideOut:
            return containerView.bounds
        }
    }

    func finalFrame(for vc: UIViewController) -> CGRect {
        switch transitionType {
        case .slideIn:
            return containerView.bounds
        case .slideOut:
            if let to = viewController(forKey: .to), to === vc {
                return containerView.bounds
            }

            return containerView.bounds.offsetBy(dx: containerView.bounds.width, dy: 0.0)
        }
    }
}

// MARK: - Interactive transition

extension StackViewControllerTransitionContext {

    func updateInteractiveTransition(_ percentComplete: CGFloat) {}

    func finishInteractiveTransition() {}

    func cancelInteractiveTransition() {}

    func pauseInteractiveTransition() {}
}

