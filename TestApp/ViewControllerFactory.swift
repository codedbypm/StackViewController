//
//  ViewControllerFactory.swift
//  TestApp
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

extension BaseViewController {

    static func colored(_ color: Color = .random) -> BaseViewController {

        let controller = BaseViewController(color: color)
        controller.navigationItem.title = color.rawValue

        controller.onPopAnimated = {
            _ = controller.stack?.popViewController(animated: true)
        }

        controller.onPopNonAnimated = {
            _ = controller.stack?.popViewController(animated: false)
        }

        controller.onPushAnimated = {
            let next = colored()
            next.stack = controller.stack
            controller.stack?.pushViewController(next, animated: true)
        }

        controller.onPushNonAnimated = {
            let next = colored()
            next.stack = controller.stack
            controller.stack?.pushViewController(next, animated: false)
        }

        controller.onSetViewControllersSameAnimated = {
            controller.stack?.setViewControllers(controller.stack?.stack ?? [], animated: true)
        }

        controller.onSetViewControllersSameNonAnimated = {
            controller.stack?.setViewControllers(controller.stack?.stack ?? [], animated: false)
        }

        controller.onSetVarViewControllersSame = {
            controller.stack?.stack = controller.stack?.stack ?? []
        }

        controller.onSetViewControllersEmptyAnimated = {
            controller.stack?.setViewControllers([], animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                controller.onPushAnimated?()
            })
        }

        controller.onSwapIntermediateControllers = {
            while controller.stack!.stack.count < 4 {
                let insert = colored()
                controller.stack?.pushViewController(insert, animated: false)
            }

            let midSwap = controller.stack!.stack.dropLast().dropFirst().reversed()
            let newStack = Array(controller.stack!.stack.prefix(1)) + Array(midSwap) + Array(controller.stack!.stack.suffix(1))
            controller.stack?.setViewControllers(Array(newStack), animated: true)
        }

        controller.onSetVarViewControllersEmpty = {
            controller.stack?.stack = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                controller.onPushAnimated?()
            })
        }

        controller.onPopToRootAnimated = {
            _ = controller.stack?.popToRootViewController(animated: true)
        }

        controller.onSwapRootWithTop = {
            guard let root = controller.stack?.stack.first else { return assertionFailure() }
            guard let top = controller.stack?.stack.last else { return assertionFailure() }
            guard root !== top else { return assertionFailure() }

            let middle = controller.stack!.stack.dropFirst().dropLast()
            let stack = [top] + Array(middle) + [root]
            controller.stack?.setViewControllers(stack, animated: true)
        }

        controller.onInsertAtIndexZero = {
            let insert = colored()
            insert.stack = controller.stack
            var modifiedStack = controller.stack?.stack
            modifiedStack?.insert(insert, at: 0)

            guard let newStack = modifiedStack else { return assertionFailure() }
            controller.stack?.stack = newStack
        }

        return controller
    }}
