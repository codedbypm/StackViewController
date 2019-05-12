//
//  Animator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 01/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

//TODO: remove this public
public class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Internal properties

    typealias Animations = () -> Void

    let animationsDuration: TimeInterval = 0.3

    var frameOfViewWhenOffScreen: CGRect = .zero

    // MARK: - Private properties

    private var propertyAnimator: UIViewPropertyAnimator?

    deinit {
        print("\(String(describing: self)): \(#function)")
    }

    public override var description: String {
        return String(describing: type(of: self))
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationsDuration
    }

    public func animateTransition(
        using context: UIViewControllerContextTransitioning
    ) {
        prepareTransition(using: context)

        propertyAnimator = createPropertyAnimator(using: context)
        propertyAnimator?.startAnimation()

        if !context.isAnimated {
            propertyAnimator?.stopAnimation(false)
            propertyAnimator?.finishAnimation(at: .end)
        }
    }

    public func interruptibleAnimator(
        using context: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        } else {
            let propertyAnimator = createPropertyAnimator(using: context)
            self.propertyAnimator = propertyAnimator
            return propertyAnimator
        }
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        propertyAnimator = nil
    }

    // MARK: - Internal methods

    func prepareTransition(using context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        let horizontalOffset = containerView.bounds.width
        frameOfViewWhenOffScreen = containerView.bounds.offsetBy(dx: horizontalOffset, dy: 0.0)
    }

    func transitionAnimations(using context: UIViewControllerContextTransitioning) -> Animations? {
        assertionFailure("Error: prepareTransition(using:) must be overriden")
        return nil
    }

    func createPropertyAnimator(using context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        let animations = transitionAnimations(using: context)
        let propertyAnimator = UIViewPropertyAnimator(duration: animationsDuration,
                                                      curve: .easeInOut,
                                                      animations: animations)
        propertyAnimator.addCompletion { position in
            let completed = (position == .end)
            if completed {
                let from = context.viewController(forKey: .from)
                from?.view.removeFromSuperview()
            }
            context.completeTransition(completed)
        }

        return propertyAnimator
    }

    func completeNonAnimatedTransition(using context: UIViewControllerContextTransitioning) {
        guard let to = context.viewController(forKey: .to) else { return }

        to.view.frame = context.finalFrame(for: to)
        context.completeTransition(true)
    }
}
