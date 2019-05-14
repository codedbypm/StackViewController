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

    private var context: UIViewControllerContextTransitioning?
    private var interruptibleAnimator: UIViewImplicitlyAnimating? {
        guard let context = context else { return nil }
        return animationController.interruptibleAnimator?(using: context)
    }

    // MARK: - Init

    public init(animationController: UIViewControllerAnimatedTransitioning,
                screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        self.animationController = animationController

        super.init()

        let selector = #selector(screenEdgeGestureRecognizerDidChangeState(_:))
        screenEdgePanGestureRecognizer.addTarget(self, action: selector)
    }

    deinit {
        print("\(String(describing: self)): \(#function)")
    }

    public override var description: String {
        return String(describing: type(of: self))
    }

    // MARK: - UIViewControllerInteractiveTransitioning

    public func startInteractiveTransition(_ context: UIViewControllerContextTransitioning) {
        self.context = context

        animationController.animateTransition(using: context)

        interruptibleAnimator?.pauseAnimation()
        context.pauseInteractiveTransition()
    }

    public var wantsInteractiveStart: Bool {
        return true
    }

    func updateInteractiveTransition(_ recognizer: ScreenEdgePanGestureRecognizer) {
        let updatedProgress = animationProgressUpdate(for: recognizer)

//        print("Pan translation: \(recognizer.translation(in: recognizer.view!).x)")
//        print("Initial offset: \(recognizer.initialTouchLocation?.x)")
//        print("Total X covered: \(recognizer.translation(in: recognizer.view!).x + recognizer.initialTouchLocation!.x)")
//        print("fractionComplete: \(updatedProgress)\n")

        interruptibleAnimator?.fractionComplete = updatedProgress
        context?.updateInteractiveTransition(updatedProgress)
    }

    func cancelInteractiveTransition() {
        context?.cancelInteractiveTransition()
        animate(to: .start)
    }

    func stopInteractiveTransition(_ gestureRecognizer: ScreenEdgePanGestureRecognizer) {
        guard completionPosition(for: gestureRecognizer) == .end else {
            cancelInteractiveTransition()
            return
        }

        context?.finishInteractiveTransition()
        animate(to: .end)
    }

    @objc
    func screenEdgeGestureRecognizerDidChangeState(_ recognizer: ScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            updateInteractiveTransition(recognizer)
        case .cancelled:
            cancelInteractiveTransition()
        case .ended:
            stopInteractiveTransition(recognizer)
        case .possible, .failed, .began:
            break
        @unknown default:
            assertionFailure()
        }

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

    func animationProgressUpdate(for recognizer: ScreenEdgePanGestureRecognizer) -> CGFloat {
        guard let recognizerView = recognizer.view else {
            assertionFailure()
            return 0.0
        }

        let initialTouchLocationX = recognizer.initialTouchLocation?.x ?? 0
        let translation = recognizer.translation(in: recognizerView)
        let maximumTranslation = recognizerView.bounds.width
        let totalTranslation = initialTouchLocationX + translation.x
        let percentage = totalTranslation/maximumTranslation
        return percentage
    }

    func completionPosition(for recognizer: ScreenEdgePanGestureRecognizer) -> UIViewAnimatingPosition {
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
