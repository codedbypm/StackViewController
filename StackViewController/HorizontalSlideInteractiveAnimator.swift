//
//  HorizontalSlideInteractiveAnimator.swift
//  StackViewController
//
//  Created by Paolo Moroni on 12/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

class HorizontalSlideInteractiveAnimator: NSObject {

    let animator: UIViewControllerAnimatedTransitioning

    private let context: UIViewControllerContextTransitioning
    private let gestureRecognizer: UIScreenEdgePanGestureRecognizer

    init(context: UIViewControllerContextTransitioning,
         animator: UIViewControllerAnimatedTransitioning,
         gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        self.context = context
        self.animator = animator
        self.gestureRecognizer = gestureRecognizer
        super.init()

        gestureRecognizer.addTarget(self, action: #selector(didDetectPanningFromEdge(_:)))
    }

    public func startInteractiveTransition() {
        startInteractiveTransition(context)
    }

    public func updateInteractiveTransition(progress: CGFloat) {
        context.updateInteractiveTransition(progress)
    }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension HorizontalSlideInteractiveAnimator: UIViewControllerInteractiveTransitioning {

    public func startInteractiveTransition(_ context: UIViewControllerContextTransitioning) {

        animator.animateTransition(using: context)
    }
}

private extension HorizontalSlideInteractiveAnimator {
    
    @objc func didDetectPanningFromEdge(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            print("START PanningFromEdge")
            startInteractiveTransition(context)
        case .changed:
            print("UPDATE PanningFromEdge")
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

        let translation = recognizer.translation(in: recognizer.view)
        let maxTranslationX: CGFloat

        if let view = recognizer.view {
            maxTranslationX = view.bounds.width
        } else {
            maxTranslationX = UIScreen.main.bounds.midX
        }
        let percentage = translation.x/maxTranslationX

        updateInteractiveTransition(progress: percentage)
    }

    func cancelInteractiveTransition() {
        print("CANCEL PanningFromEdge")
        //        interactiveAnimator?.cancel()
    }

    func stopInteractiveTransition() {
        print("STOP PanningFromEdge")
        //        interactiveAnimator?.finish()
    }
}
