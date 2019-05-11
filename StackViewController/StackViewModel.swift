//
//  StackViewModel.swift
//  StackViewController
//
//  Created by Paolo Moroni on 11/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

protocol StackViewModelDelegate: class {
    func didAddStackElements(_ additions: Stack)
    func didRemoveStackElements(_ removals: Stack)
    func didReplaceStack(_ oldStack: Stack, with newStack: Stack)

    func didCreateTransition(_: Transition)
}

class StackViewModel: StackInteractorDelegate  {

    // MARK: - Internal properties

    weak var delegate: StackViewModelDelegate?

    var stack: Stack { return stackInteractor.stack }
    
    var topViewController: UIViewController? { return stack.last }

    // MARK: - Private properties

    private let stackInteractor: StackInteractor

    private var currentTransition: Transition?
 
    // MARK: - Init

    init(stackInteractor: StackInteractor) {
        self.stackInteractor = stackInteractor
    }

    // MARK: - Internal methods

    func push(_ viewController: UIViewController, animated: Bool) {
        currentTransition = Transition(operation: .push, animated: animated)
        stackInteractor.push(viewController)
    }

    func push(_ stack: Stack, animated: Bool) {
        currentTransition = Transition(operation: .push, animated: animated)
        stackInteractor.push(stack)
    }

    @discardableResult
    func pop(animated: Bool, interactive: Bool = false) -> UIViewController? {
        currentTransition = Transition(operation: .pop, animated: animated, interactive: interactive)
        return stackInteractor.pop()
    }

    @discardableResult
    func popToRoot(animated: Bool) -> Stack {
        currentTransition = Transition(operation: .pop, animated: animated)
        return stackInteractor.popToRoot()
    }

    @discardableResult
    func popTo(_ viewController: UIViewController, animated: Bool, interactive: Bool = false) -> Stack {
        currentTransition = Transition(operation: .pop, animated: animated, interactive: interactive)
        return stackInteractor.popTo(viewController)
    }

    func setStack(_ newStack: Stack, animated: Bool) {
        let operation = stackOperation(whenReplacing: stack, with: newStack)
        currentTransition = Transition(operation: operation, animated: animated)

        stackInteractor.setStack(newStack)
    }

    // MARK: - StackInteractorDelegate

    func stackDidChange(_ difference: Stack.Difference) {
        notifyDelegateAboutChanges(difference)

//        let oldStack = interactor.stack.applying(Stack.Difference(removals + inserts)!)
//        currentTransition?.from = oldStack?.last
//        currentTransition?.to = topViewController
//
//        if let transition = currentTransition {
//            didCreateTransition(transition)
//        }
    }

    private func stackOperation(whenReplacing oldStack: Stack, with newStack: Stack) -> StackViewController.Operation {
        let from = topViewController
        let to = newStack.last

        if let to = to {
            if oldStack.contains(to) { return .pop }
            else { return .push }
        } else {
            if from != nil { return .pop }
            else { return .none }
        }
    }

    private func notifyDelegateAboutChanges(_ difference: Stack.Difference) {
        let insertedViewControllers = difference.insertions.map { $0._element }
        delegate?.didAddStackElements(insertedViewControllers)

        let removedViewControllers = difference.removals.map { $0._element }
        delegate?.didRemoveStackElements(removedViewControllers)

        let moves = difference.inferringMoves()
    }
}
