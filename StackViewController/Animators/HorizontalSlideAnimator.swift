//
//  HorizontalSlideAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

public enum HorizontalSlideTransitionType {
    case slideIn
    case slideOut
}

public class HorizontalSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let animationDuration: TimeInterval = 0.3

    private let transitionType: HorizontalSlideTransitionType

    public required init(type: HorizontalSlideTransitionType) {
        transitionType = type
        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard
            let from = context.viewController(forKey: .from),
            let to = context.viewController(forKey: .to)
        else {
            context.completeTransition(false)
            return
        }

        let containerView = context.containerView
        let horizontalOffset = containerView.bounds.width
        let frameWhenOffScreen = containerView.bounds.offsetBy(dx: horizontalOffset, dy: 0.0)
        let isSlidingIn = (transitionType == .slideIn)

        let beforeAnimationsStart: (() -> Void) = {
            if isSlidingIn {
                containerView.addSubview(to.view)
                to.view.frame = frameWhenOffScreen
            } else {
                containerView.insertSubview(to.view, belowSubview: from.view)
                to.view.frame = containerView.bounds
            }
        }

        let animations: (() -> Void) = {
            if isSlidingIn {
                to.view.frame = context.finalFrame(for: to)
            } else {
                to.view.frame = context.finalFrame(for: to)
                from.view.frame = frameWhenOffScreen
            }
        }

        let whenAnimationsFinish: ((Bool) -> Void) = { context.completeTransition($0) }

        beforeAnimationsStart()

        guard context.isAnimated else {
            animations()
            whenAnimationsFinish(true)
            return
        }

        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: animations,
            completion: whenAnimationsFinish)
    }
}
