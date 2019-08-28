//
//  ViewControllerFactory.swift
//  TestApp
//
//  Created by Paolo Moroni on 28/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit
import StackViewController

extension UIViewController {

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
            controller.stack?.pushViewController(next, animated: true)
        }

        controller.onPushNonAnimated = {
            let next = colored()
            controller.stack?.pushViewController(next, animated: false)
        }

        controller.onSetViewControllersSameAnimated = {
            controller.stack?.setViewControllers(controller.stack?.viewControllers ?? [], animated: true)
        }

        controller.onSetViewControllersSameNonAnimated = {
            controller.stack?.setViewControllers(controller.stack?.viewControllers ?? [], animated: false)
        }

        controller.onSetVarViewControllersSame = {
            controller.stack?.viewControllers = controller.stack?.viewControllers ?? []
        }

        controller.onSetViewControllersEmptyAnimated = {
            controller.stack?.setViewControllers([], animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                controller.onPushAnimated?()
            })
        }

        controller.onSwapIntermediateControllers = {
            while controller.stack!.viewControllers.count < 4 {
                let insert = colored()
                controller.stack?.pushViewController(insert, animated: false)
            }

            let midSwap = controller.stack!.viewControllers.dropLast().dropFirst().reversed()
            let newStack = Array(controller.stack!.viewControllers.prefix(1)) + Array(midSwap) + Array(controller.stack!.viewControllers.suffix(1))
            controller.stack?.setViewControllers(Array(newStack), animated: true)
        }

        controller.onSetVarViewControllersEmpty = {
            controller.stack?.viewControllers = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                controller.onPushAnimated?()
            })
        }

        controller.onPopToRootAnimated = {
            _ = controller.stack?.popToRootViewController(animated: true)
        }

        controller.onSwapRootWithTop = {
            guard let root = controller.stack?.viewControllers.first else { return assertionFailure() }
            guard let top = controller.stack?.viewControllers.last else { return assertionFailure() }
            guard root !== top else { return assertionFailure() }

            let middle = controller.stack!.viewControllers.dropFirst().dropLast()
            let stack = [top] + Array(middle) + [root]
            controller.stack?.setViewControllers(stack, animated: true)
        }

        controller.onInsertAtIndexZero = {
            let insert = colored()
            var modifiedStack = controller.stack?.viewControllers
            modifiedStack?.insert(insert, at: 0)

            guard let newStack = modifiedStack else { return assertionFailure() }
            controller.stack?.viewControllers = newStack
        }

        return controller
    }}
