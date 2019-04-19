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
    var context: UIViewControllerContextTransitioning!

    private let gestureRecognizer: UIScreenEdgePanGestureRecognizer
    private var animationProgressInitialOffset: CGFloat = 0.0
    private var didStartInteractively = false

    private var interruptibleAnimator: UIViewImplicitlyAnimating? {
        return animationController.interruptibleAnimator?(using: context)
    }

    public init(animationController: UIViewControllerAnimatedTransitioning,
                gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        self.animationController = animationController
        self.gestureRecognizer = gestureRecognizer
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

        print("Pan translation: \(translation)")
        print("Progress: \(updatedProgress)")
        print("fractionComplete: \(updatedProgress + animationProgressInitialOffset)\n")

        interruptibleAnimator?.fractionComplete = updatedProgress
        context.updateInteractiveTransition(updatedProgress)
    }

    func cancelInteractiveTransition() {
        print("CANCEL PanningFromEdge")
        //        interactiveAnimator?.cancel()
    }

    func stopInteractiveTransition() {
        print("STOP PanningFromEdge")
        //        interactiveAnimator?.finish()
    }

    func animationProgressUpdate(for translation: CGPoint) -> CGFloat {
        let maxTranslationX = context.containerView.bounds.width
        let percentage = translation.x/maxTranslationX
        return percentage
    }
}
