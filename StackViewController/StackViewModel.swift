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

public typealias Stack = [UIViewController]

class StackViewModel: ExceptionThrowing {

    weak var delegate: StackViewModelDelegate?
    lazy var viewControllerWrapperView: UIView = ViewControllerWrapperView()

    private var context: TransitionContext?
    private var animationController: UIViewControllerAnimatedTransitioning?
    private var interactionController: UIViewControllerInteractiveTransitioning?
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private(set) var stack = Stack()

    init(stack: Stack) {
        guard !stack.hasDuplicates else {
            throwError(.duplicateViewControllers, userInfo: ["stack": stack])
            return
        }

        self.stack = stack
    }

    var topViewController: UIViewController? { return stack.last }

    var transition: Transition? {
        willSet {
            if newValue == nil { assert(transition != nil) }
            else { assert(transition == nil) }
        }
        didSet {
            if let transition = transition {
                prepareTransition(transition)
                startTransition(transition)
            }
        }
    }

    func transitionForPush(_ viewControllers: Stack, animated: Bool) -> Transition? {
        guard canPush(viewControllers) else { return nil }

        let from = topViewController
        let to = viewControllers.last

        stack.append(contentsOf: viewControllers)

        return Transition(operation: .push, from: from, to: to, animated: animated)
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

    @discardableResult
    private func popToViewController(at index: Int,
                                     animated: Bool,
                                     interactive: Bool = false) -> Stack {
        guard (0..<stack.endIndex).contains(index) else { return [] }

        let poppedCount = stack.endIndex - (index + 1)
        let poppedElements = stack.suffix(poppedCount)

        stack.removeLast(poppedCount)
        transition = Transition(operation: .pop,
                                from: poppedElements.last,
                                to: topViewController,
                                animated: animated,
                                interactive: interactive)
        return Array(poppedElements)
    }

    func setStack(_ newStack: Stack, animated: Bool) {
        guard canReplaceStack(with: newStack) else { return }


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

        stack = newStack
        transition = Transition(operation: operation, from: from, to: to, animated: animated)
    }

    func screenEdgeGestureRecognizerDidChangeState(
        _ gestureRecognizer: UIScreenEdgePanGestureRecognizer
    ) {
        switch gestureRecognizer.state {
        case .possible:
            print("Possible")
        case .began:
            print("Began")
            screenEdgePanGestureRecognizer = gestureRecognizer
            popToViewController(at: stack.endIndex.advanced(by: -2),
                                animated: true,
                                interactive: true)
        case .changed:
            print("Changed")

        case .ended:
            screenEdgePanGestureRecognizer = nil
            print("Ended")

        case .cancelled:
            screenEdgePanGestureRecognizer = nil
            print("Cancelled")

        case .failed:
            screenEdgePanGestureRecognizer = nil
            print("Failed")

        @unknown default:
            break
        }
    }

    func prepareTransition(_ transition: Transition) {
        context = self.context(for: transition, in: viewControllerWrapperView)

        let animationController = self.animationController(for: transition)
        self.animationController = animationController

        if transition.isInteractive {
            interactionController = self.interactionController(animationController: animationController)
        }
    }

    private func startTransition(_ transition: Transition) {
        guard let context = context else { return assertionFailure() }

        delegate?.willStartTransition(using: context)

        if context.isInteractive {
            interactionController?.startInteractiveTransition(context)
        } else {
            animationController?.animateTransition(using: context)
        }
    }

    func transitionFinished(_ didComplete: Bool) {
        transition = nil
        interactionController = nil
        animationController = nil
        context = nil
    }

    // MARK: - Transition Actors creation

    func context(for transition: Transition,
                 in containerView: UIView) -> TransitionContext {

        assert(transition.from != nil || transition.to != nil)

        let animationsEnabled = (transition.from != nil && transition.to != nil)
        let context = TransitionContext(transition: transition, in: containerView)
        context.isAnimated = transition.isAnimated && animationsEnabled
        context.isInteractive = transition.isInteractive
        context.onTransitionFinished = { [weak self] didComplete in
            self?.animationController?.animationEnded?(didComplete)
            self?.transitionFinished(didComplete)
//            self?.debugEndTransition()
        }


        return context
    }

    func defaultAnimationController(for transition: Transition) -> Animator {
        switch transition.operation {
        case .pop: return PopAnimator()
        case .push: return PushAnimator()
        }
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
        animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning {

        if let controller = delegate?.interactionController(for: animationController) {
            return controller
        } else {
            return InteractivePopAnimator(animationController: animationController)
        }
    }

    private func canPush(_ stack: Stack) -> Bool {
        guard !(self.stack + stack).hasDuplicates else { return false }
        return true
    }

    func canPopLast(_ count: Int) -> Bool {
        guard (0...stack.count).contains(count) else { return false }
        return true
    }

    private func canReplaceStack(with newStack: Stack) -> Bool {
        guard !stack.elementsEqual(newStack) else { return false }
        guard !newStack.hasDuplicates else { return false }
        return true
    }

    func canPopViewControllerInteractively() -> Bool {
        guard canPopLast(1) else { return false }
        guard interactionController == nil else { return false }
        return true
    }
}
