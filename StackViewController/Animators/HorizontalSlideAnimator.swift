//
//  HorizontalSlideAnimator.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

enum HorizontalSlideTransitionType {
    case slideIn
    case slideOut
}

class HorizontalSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    required init(direction: HorizontalSlideTransitionType) {
        self.transitionType = direction
    }

    let animationDuration: TimeInterval = 0.3
    let transitionType: HorizontalSlideTransitionType

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            return
        }

        let containerView = transitionContext.containerView

        toViewController.view.frame = transitionContext.initialFrame(for: toViewController)
        
        if case .slideIn = transitionType {
            containerView.addSubview(toViewController.view)
        } else if case .slideOut = transitionType {
            containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        }

        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: {
                if case .slideIn = self.transitionType {
                    toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
                } else if case .slideOut = self.transitionType {
                    fromViewController.view.frame = transitionContext.finalFrame(for: fromViewController)
                }
            }) { done in
                transitionContext.completeTransition(done)
        }
    }
}
