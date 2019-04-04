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

    let animationDuration: TimeInterval = 0.3

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
        let isSlidingIn = transitionContext.initialFrame(for: toViewController).minX == containerView.bounds.width
        let animated = transitionContext.isAnimated

        fromViewController.beginAppearanceTransition(false, animated: animated)
        toViewController.beginAppearanceTransition(true, animated: animated)

        toViewController.view.frame = transitionContext.initialFrame(for: toViewController)

        if isSlidingIn {
            containerView.addSubview(toViewController.view)
        } else {
            containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        }

        let animations: (() -> Void) = {
            if isSlidingIn {
                toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            } else {
                fromViewController.view.frame = transitionContext.finalFrame(for: fromViewController)
            }
        }

        let whenAnimationsDone: ((Bool) -> Void) = { didFinish in
            transitionContext.completeTransition(didFinish)
            
            fromViewController.endAppearanceTransition()
            toViewController.endAppearanceTransition()
        }

        guard animated else {
            animations()
            whenAnimationsDone(true)
            return
        }

        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: animations,
            completion: whenAnimationsDone)
    }
}