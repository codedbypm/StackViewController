//
//  HorizontalSlideAnimationController.swift
//  StackViewController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

public enum HorizontalSlideTransitionType {
    case slideIn
    case slideOut
}

public class HorizontalSlideAnimationController: NSObject {

    // MARK: - Internal properties

    let animationsDuration: TimeInterval = 0.3

    // MARK: - Private properties

    private let transitionType: HorizontalSlideTransitionType
    private var propertyAnimator: UIViewPropertyAnimator?

    private var context: UIViewControllerContextTransitioning?
    private var from: UIViewController? { return context?.viewController(forKey: .from) }
    private var to: UIViewController? { return context?.viewController(forKey: .to) }

    // MARK: - Init

    public required init(type: HorizontalSlideTransitionType) {
        transitionType = type
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension HorizontalSlideAnimationController: UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationsDuration
    }

    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        self.context = context
        prepareTransition(using: context)

        if context.isAnimated {
            interruptibleAnimator(using: context).startAnimation()
        } else {
            completeNonAnimatedTransition(using: context)
        }
    }

    public func interruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        } else {
            let propertyAnimator = self.propertyAnimator(using: context)
            self.propertyAnimator = propertyAnimator
            return propertyAnimator
        }
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        propertyAnimator = nil
    }
}

private extension HorizontalSlideAnimationController {

    func prepareTransition(using context: UIViewControllerContextTransitioning) {
        switch transitionType {
        case .slideIn:
            prepareSlideInTransition(using: context)
        case .slideOut:
            prepareSlideOutTransition(using: context)
        }
    }

    func prepareSlideInTransition(using context: UIViewControllerContextTransitioning) {
        guard let to = to else { return }

        let containerView = context.containerView
        let frameOfViewWhenOffScreen = containerView.bounds.offsetBy(dx: containerView.bounds.width,
                                                                     dy: 0.0)
        containerView.addSubview(to.view)
        to.view.frame = frameOfViewWhenOffScreen
    }

    func prepareSlideOutTransition(using context: UIViewControllerContextTransitioning) {
        guard let from = from, let to = to else { return }

        let containerView = context.containerView
        
        containerView.insertSubview(to.view, belowSubview: from.view)
        to.view.frame = containerView.bounds.offsetBy(dx: -90.0, dy: 0.0)
    }

    typealias Animations = () -> Void

    func transitionAnimations(using context: UIViewControllerContextTransitioning) -> Animations {
        switch transitionType {
        case .slideIn:
            return {
                guard let from = self.from, let to = self.to else { return }

                to.view.frame = context.finalFrame(for: to)
                from.view.frame = from.view.frame.offsetBy(dx: -90.0, dy: 0.0)
            }
        case .slideOut:
            return {
                guard let from = self.from, let to = self.to else { return }

                let containerView = context.containerView
                let frameOfViewWhenOffScreen = containerView.bounds.offsetBy(dx: containerView.bounds.width,
                                                                             dy: 0.0)
                to.view.frame = context.finalFrame(for: to)
                from.view.frame = frameOfViewWhenOffScreen
            }
        }
    }

    func propertyAnimator(using context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        let animations = transitionAnimations(using: context)
        let propertyAnimator = UIViewPropertyAnimator(duration: animationsDuration,
                                                      curve: .easeInOut,
                                                      animations: animations)
        propertyAnimator.addCompletion { position in
            let completed = (position == .end)
            if completed {
                self.from?.view.removeFromSuperview()
            }
            context.completeTransition(completed)
        }

        return propertyAnimator
    }

    func completeNonAnimatedTransition(using context: UIViewControllerContextTransitioning) {
        guard let to = to else { return }

        to.view.frame = context.finalFrame(for: to)
        context.completeTransition(true)
    }
}
