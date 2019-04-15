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

public class HorizontalSlideAnimator: NSObject {

    let animationsDuration: TimeInterval = 0.3

    private let transitionType: HorizontalSlideTransitionType
    private var propertyAnimator: UIViewPropertyAnimator?

    public required init(type: HorizontalSlideTransitionType) {
        transitionType = type
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension HorizontalSlideAnimator: UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationsDuration
    }

    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard let context = context as? StackViewControllerContextTransitioning else { return }

        switch transitionType {
        case .slideIn:
            animateSlideInTransition(using: context)
        case .slideOut:
            animateSlideOutTransition(using: context)
        }
    }

    public func interruptibleAnimator(using _: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let propertyAnimator = propertyAnimator else {
            fatalError("Fatal: the `propertyAnimator` cannot be nil")
        }

        return propertyAnimator
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        propertyAnimator = nil
    }
}

private extension HorizontalSlideAnimator {

    func animateSlideInTransition(using context: StackViewControllerContextTransitioning) {
        guard let to = context.viewController(forKey: .to) else { return }

        let containerView = context.containerView

        containerView.addSubview(to.view)
        to.view.frame = context.frameOfViewWhenOffScreen

        guard context.isAnimated else {
            to.view.frame = context.finalFrame(for: to)
            context.completeTransition(true)
            return
        }

        configurePropertyAnimator(using: context) {
            to.view.frame = context.finalFrame(for: to)
        }

        propertyAnimator?.startAnimation()
    }

    func animateSlideOutTransition(using context: StackViewControllerContextTransitioning) {
        guard let from = context.viewController(forKey: .from) else { return }
        guard let to = context.viewController(forKey: .to) else { return }

        let containerView = context.containerView

        containerView.insertSubview(to.view, belowSubview: from.view)
        to.view.frame = containerView.bounds

        guard context.isAnimated else {
            context.completeTransition(true)
            return
        }

        configurePropertyAnimator(using: context) {
            to.view.frame = context.finalFrame(for: to)
            from.view.frame = context.frameOfViewWhenOffScreen
        }

        propertyAnimator?.startAnimation()
    }

    func configurePropertyAnimator(using context: UIViewControllerContextTransitioning,
                                   animations: @escaping () -> Void) {

        propertyAnimator = UIViewPropertyAnimator(duration: animationsDuration,
                                                  curve: .easeInOut,
                                                  animations: animations)

        propertyAnimator?.addCompletion { position in
            let completed = (position == .end)
            context.completeTransition(completed)
        }
    }
}
