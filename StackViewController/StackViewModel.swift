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
}

class StackViewModel: StackInteractorDelegate  {

    // MARK: - Internal properties

    weak var delegate: StackViewModelDelegate?

    var stack: Stack { return stackInteractor.stack }
    
    var topViewController: UIViewController? { return stack.last }

    // MARK: - Private properties

    private let stackInteractor: StackInteractor

    // MARK: - Init

    init(stackInteractor: StackInteractor) {
        self.stackInteractor = stackInteractor
    }

    func stackDidChange(_ difference: Stack.Difference) {
//        didRemoveStackElements(removals.map { $0._element } )
//        didAddStackElements(inserts.map { $0._element } )
//
//        let oldStack = interactor.stack.applying(Stack.Difference(removals + inserts)!)
//        currentTransition?.from = oldStack?.last
//        currentTransition?.to = topViewController
//
//        if let transition = currentTransition {
//            didCreateTransition(transition)
//        }
    }
}
