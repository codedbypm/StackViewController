//
//  StackViewController+ObjectFactory.swift
//  StackViewController
//
//  Created by Paolo Moroni on 30/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

extension StackViewController {

    func animationController(for transition: Transition) -> UIViewControllerAnimatedTransitioning {

        if let from = transition.from, let to = transition.to, let controller = delegate?.animationController(for: transition.operation, from: from, to: to) {
            return controller
        } else {
            return viewModel.defaultAnimationController(for: transition)
        }
    }

    func interactionController(
        animationController: UIViewControllerAnimatedTransitioning,
        context: UIViewControllerContextTransitioning) -> UIViewControllerInteractiveTransitioning {

        if let controller = delegate?.interactionController(for: animationController) {
            return controller
        } else {
            return viewModel.defaultInteractionController(
                animationController: animationController,
                gestureRecognizer: screenEdgePanGestureRecognizer,
                context: context)
        }
    }
}
