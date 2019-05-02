//
//  PushAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit

//TODO: remove this public
public class PushAnimator: Animator {

    override func prepareTransition(using context: UIViewControllerContextTransitioning) {
        super.prepareTransition(using: context)

        guard let to = context.viewController(forKey: .to) else { return }

        let containerView = context.containerView
        containerView.addSubview(to.view)
        to.view.frame = frameOfViewWhenOffScreen
    }

    override func transitionAnimations(using context: UIViewControllerContextTransitioning) -> Animations {
        return {
            guard let from = context.viewController(forKey: .from) else { return }
            guard let to = context.viewController(forKey: .to) else { return }
            let containerView = context.containerView

            to.view.frame = context.finalFrame(for: to)

            let initialOffsetX = containerView.frame.width * (-0.3)
            from.view.frame = from.view.frame.offsetBy(dx: initialOffsetX, dy: 0.0)
        }
    }
}
