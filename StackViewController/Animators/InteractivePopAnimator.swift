//
//  InteractivePopAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 12/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

//TODO: remove this public
public class InteractivePopAnimator: NSObject, UIViewControllerInteractiveTransitioning {

    // MARK: - Internal properties

    let animationController: UIViewControllerAnimatedTransitioning
    let context: UIViewControllerContextTransitioning

    // MARK: - Private properties

    private var didStartInteractively = false
    private var animationProgressInitialOffset: CGFloat = 0.0

    private var interruptibleAnimator: UIViewImplicitlyAnimating? {
        return animationController.interruptibleAnimator?(using: context)
    }

    // MARK: - Init

    public init(animationController: UIViewControllerAnimatedTransitioning,
                context: UIViewControllerContextTransitioning) {
        self.animationController = animationController
        self.context = context
        super.init()
    }

    // MARK: - UIViewControllerInteractiveTransitioning

    public func startInteractiveTransition(_ context: UIViewControllerContextTransitioning) {
        animationController.animateTransition(using: context)

        if didStartInteractively {
            interruptibleAnimator?.pauseAnimation()
            context.pauseInteractiveTransition()
        }
    }

    public var wantsInteractiveStart: Bool {
        return didStartInteractively
    }
}

private extension InteractivePopAnimator {
    
    @objc func didDetectPanningFromEdge(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    }

    func updateInteractiveTransition(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = recognizer.translation(in: context.containerView)
        let updatedProgress = animationProgressUpdate(for: translation)

//        print("Pan translation: \(translation.x) (\(updatedProgress) %)")
//        print("fractionComplete: \(updatedProgress + animationProgressInitialOffset)\n")
//
        interruptibleAnimator?.fractionComplete = updatedProgress
        context.updateInteractiveTransition(updatedProgress)
    }

    func cancelInteractiveTransition() {
        context.cancelInteractiveTransition()
        animate(to: .start)
    }

    func stopInteractiveTransition() {
        guard completionPosition() == .end else {
            cancelInteractiveTransition()
            return
        }

        context.finishInteractiveTransition()
        animate(to: .end)
    }

    func animate(to position: UIViewAnimatingPosition) {
        let durationFraction: CGFloat
        let isReversed: Bool

        switch position {
        case .start:
            durationFraction = interruptibleAnimator?.fractionComplete ?? 0
            isReversed = true
        case .end:
            durationFraction = 1 - (interruptibleAnimator?.fractionComplete ?? 0)
            isReversed = false
        case .current:
            fallthrough
        @unknown default:
            return
        }

        interruptibleAnimator?.isReversed = isReversed
        interruptibleAnimator?.continueAnimation?(withTimingParameters: nil, durationFactor: durationFraction)
    }

    func animationProgressUpdate(for translation: CGPoint) -> CGFloat {
        let maxTranslationX = context.containerView.bounds.width
        let percentage = translation.x/maxTranslationX
        return percentage
    }

    func completionPosition() -> UIViewAnimatingPosition {
        let panGestureTranslation = gestureRecognizer.translation(in: context.containerView)
        let threshold = context.containerView.bounds.midX

        if panGestureTranslation.x > threshold {
            return .end
        } else {
            return .start
        }
    }
}
