//
//  HorizontalSlideInteractiveController.swift
//  StackViewController
//
//  Created by Paolo Moroni on 12/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public class HorizontalSlideInteractiveController: NSObject {

    let animationController: UIViewControllerAnimatedTransitioning
    let context: UIViewControllerContextTransitioning

    private let gestureRecognizer: UIScreenEdgePanGestureRecognizer
    private var animationProgressInitialOffset: CGFloat = 0.0
    private var didStartInteractively = false

    private var interruptibleAnimator: UIViewImplicitlyAnimating? {
        return animationController.interruptibleAnimator?(using: context)
    }

    public init(animationController: UIViewControllerAnimatedTransitioning,
                gestureRecognizer: UIScreenEdgePanGestureRecognizer,
                context: UIViewControllerContextTransitioning) {
        self.animationController = animationController
        self.gestureRecognizer = gestureRecognizer
        self.context = context
        super.init()

        gestureRecognizer.addTarget(self, action: #selector(didDetectPanningFromEdge(_:)))
    }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension HorizontalSlideInteractiveController: UIViewControllerInteractiveTransitioning {

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

private extension HorizontalSlideInteractiveController {
    
    @objc func didDetectPanningFromEdge(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            didStartInteractively = true
            let panGestureStartLocation = recognizer.location(in: context.containerView)
            animationProgressInitialOffset = animationProgressUpdate(for: panGestureStartLocation)
            startInteractiveTransition(context)
        case .changed:
            updateInteractiveTransition(recognizer)
        case .cancelled:
            cancelInteractiveTransition()
        case .ended:
            stopInteractiveTransition()
        default:
            break
        }
    }

    func updateInteractiveTransition(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = recognizer.translation(in: context.containerView)
        let updatedProgress = animationProgressUpdate(for: translation)

        print("Pan translation: \(translation.x) (\(updatedProgress) %)")
        print("fractionComplete: \(updatedProgress + animationProgressInitialOffset)\n")

        interruptibleAnimator?.fractionComplete = updatedProgress
        context.updateInteractiveTransition(updatedProgress)
    }

    func cancelInteractiveTransition() {
        print("CANCEL PanningFromEdge")

        context.cancelInteractiveTransition()
        animate(to: .start)
    }

    func stopInteractiveTransition() {
        guard completionPosition() == .end else {
            cancelInteractiveTransition()
            return
        }

        print("STOP PanningFromEdge")

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
        let panGestureLocation = gestureRecognizer.location(in: context.containerView)
        let panGestureTranslation = gestureRecognizer.translation(in: context.containerView)
        let threshold = context.containerView.bounds.midX

        if panGestureLocation.x + panGestureTranslation.x > threshold {
            return .end
        } else {
            return .start
        }
    }
}
