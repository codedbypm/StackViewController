//
//  StackViewModel.swift
//  StackViewController
//
//  Created by Paolo Moroni on 04/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewModelDelegate: StackViewControllerDelegate {
    func willStartTransition(using context: TransitionContext)
    func didEndTransition(using context: TransitionContext, completed: Bool)
}

class StackViewModel {

    weak var delegate: StackViewModelDelegate?

    private let stackHandler: StackHandler

    init(stack: Stack) {
        stackHandler = StackHandler(stack: stack)
    }

    var stack: Stack {
        return stackHandler.stack
    }

    var topViewController: UIViewController? {
        return stackHandler.top
    }

    var transition: Transition? {
        willSet {
            if newValue == nil { assert(transition != nil) }
            else { assert(transition == nil) }
        }
        didSet {
            if let transition = transition {
            }
        }
    }

    func push(_ viewControllers: [UIViewController], animated: Bool) {
        let from = topViewController
        stackHandler.push(viewControllers)
        transition = Transition(operation: .push, from: from, to: viewControllers.last)
    }

    func pop(animated: Bool) -> UIViewController? {
        return popToViewController(at: stack.endIndex.advanced(by: -2), animated: animated).first
    }

    func popToRoot(animated: Bool) -> Stack {
        return popToViewController(at: stack.startIndex, animated: animated)
    }

    func popTo(_ viewController: UIViewController, animated: Bool) -> Stack {
        guard let index = stack.firstIndex(of: viewController) else { return [] }
        return popToViewController(at: index, animated: animated)
    }

    private func popToViewController(at index: Int, animated: Bool) -> Stack {
        guard (0..<stack.endIndex).contains(index) else { return [] }

        let poppedCount = stack.endIndex - (index + 1)
        let poppedElements = stackHandler.popLast(poppedCount)

        transition = Transition(operation: .pop, from: poppedElements.last, to: topViewController)
        return poppedElements
    }

    func setStack(_ newStack: Stack, animated: Bool) {

        let from = topViewController
        let to = newStack.last
        let operation: StackViewController.Operation

        if let to = to {
            if stack.contains(to) {
                operation = .pop
            } else {
                operation = .push
            }
        } else {
            if from != nil {
                operation = .pop
            } else {
                return
//                operation = .none
            }
        }

        stackHandler.replaceStack(with: newStack)
        transition = Transition(operation: operation, from: from, to: to)
    }

    func canPopViewControllerInteractively() -> Bool {
        guard stackHandler.canPopLast(1) else { return false }
        return true
    }
    
    func transitionFinished(_ didComplete: Bool) {
        transition = nil
    }

    // MARK: - Transition Actors creation

    func context(for transition: Transition,
                 in containerView: UIView,
                 animated: Bool = true,
                 interactive: Bool = false) -> TransitionContext {


        assert(transition.from != nil || transition.to != nil)

        let animationsEnabled = (transition.from != nil && transition.to != nil)
        let context = TransitionContext(transition: transition, in: containerView)
        context.isAnimated = animated && animationsEnabled
        context.isInteractive = interactive

        return context
    }

    func defaultAnimationController(for transition: Transition) -> Animator {
        switch transition.operation {
        case .pop: return PopAnimator()
        case .push: return PushAnimator()
        }
    }

    func defaultInteractionController(
        animationController: UIViewControllerAnimatedTransitioning,
        context: UIViewControllerContextTransitioning) -> InteractivePopAnimator {

        return InteractivePopAnimator(animationController: animationController,
                                      context: context)
    }

    func animationController(for transition: Transition) -> UIViewControllerAnimatedTransitioning {
        guard let from = transition.from, let to = transition.to else {
            return defaultAnimationController(for: transition)
        }

        guard let delegate = delegate else {
            return defaultAnimationController(for: transition)
        }

        let controller = delegate.animationController(for: transition.operation,
                                                      from: from,
                                                      to: to)

        if let controller = controller {
            return controller
        } else {
            return defaultAnimationController(for: transition)
        }
    }

    func interactionController(
        animationController: UIViewControllerAnimatedTransitioning,
        context: UIViewControllerContextTransitioning) -> UIViewControllerInteractiveTransitioning {

        if let controller = delegate?.interactionController(for: animationController) {
            return controller
        } else {
            return defaultInteractionController(animationController: animationController,
                                                context: context)
        }
    }
}
