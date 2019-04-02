//
//  HorizontalSlideAnimator.swift
//  NavigationController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

class HorizontalSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let animationDuration: TimeInterval = 0.3

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            return
        }
        let containerView = transitionContext.containerView

        setInitialFrameOfDestinationView(toView, inContainerView: containerView)

        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [], animations: {
            self.setFinalFrameOfDestinationView(toView, inContainerView: containerView)
        }) { done in
            transitionContext.completeTransition(done)
        }
    }
}

private extension HorizontalSlideAnimator {

    func setInitialFrameOfDestinationView(_ view: UIView, inContainerView containerView: UIView) {
        let containerViewBounds = containerView.bounds
        let containerViewWidth = containerViewBounds.width

        let translation = CGAffineTransform(translationX: containerViewWidth, y: 0.0)
        view.frame = containerViewBounds.applying(translation)
    }

    func setFinalFrameOfDestinationView(_ view: UIView, inContainerView containerView: UIView) {
        view.frame = containerView.bounds
    }
}
