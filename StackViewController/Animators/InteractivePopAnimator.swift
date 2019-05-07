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

    // MARK: - Private properties

    private var didStartInteractively = false
    private var animationProgressInitialOffset: CGFloat = 0.0

    private var context: UIViewControllerContextTransitioning?
    private var interruptibleAnimator: UIViewImplicitlyAnimating? {
        guard let context = context else { return nil }
        return animationController.interruptibleAnimator?(using: context)
    }

    // MARK: - Init

    public init(animationController: UIViewControllerAnimatedTransitioning) {
        self.animationController = animationController
        super.init()
    }

    // MARK: - UIViewControllerInteractiveTransitioning

    public func startInteractiveTransition(_ context: UIViewControllerContextTransitioning) {
        self.context = context

        animationController.animateTransition(using: context)

        if didStartInteractively {
            interruptibleAnimator?.pauseAnimation()
            context.pauseInteractiveTransition()
        }
    }

    public var wantsInteractiveStart: Bool {
        return didStartInteractively
    }

//    func startInteractiveTransition(_ recognizer: UIScreenEdgePanGestureRecognizer) {
//        didStartInteractively = true
//        let panGestureStartLocation = recognizer.location(in: context.containerView)
//        animationProgressInitialOffset = animationProgressUpdate(for: panGestureStartLocation)
//        startInteractiveTransition(context)
//    }

    func updateInteractiveTransition(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard let recognizerView = recognizer.view else { return assertionFailure() }

        let updatedProgress = animationProgressUpdate(for: recognizer)

//        print("Pan translation: \(translation.x) (\(updatedProgress) %)")
//        print("fractionComplete: \(updatedProgress + animationProgressInitialOffset)\n")
//
        interruptibleAnimator?.fractionComplete = updatedProgress
        context?.updateInteractiveTransition(updatedProgress)
    }

    func cancelInteractiveTransition() {
        context?.cancelInteractiveTransition()
        animate(to: .start)
    }

    func stopInteractiveTransition(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard completionPosition(for: gestureRecognizer) == .end else {
            cancelInteractiveTransition()
            return
        }

        context?.finishInteractiveTransition()
        animate(to: .end)
    }
}

private extension InteractivePopAnimator {
    
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

    func animationProgressUpdate(for recognizer: UIScreenEdgePanGestureRecognizer) -> CGFloat {
        guard let recognizerView = recognizer.view else {
            assertionFailure()
            return 0.0
        }

        let translation = recognizer.translation(in: recognizerView)
        let maximumTranslation = recognizerView.bounds.width
        let percentage = translation.x/maximumTranslation
        return percentage
    }

    func completionPosition(for recognizer: UIScreenEdgePanGestureRecognizer) -> UIViewAnimatingPosition {
        guard let recognizerView = recognizer.view else {
            assertionFailure()
            return .start
        }

        let panGestureTranslation = recognizer.translation(in: recognizerView)
        let threshold = recognizerView.bounds.midX

        if panGestureTranslation.x > threshold {
            return .end
        } else {
            return .start
        }
    }
}
