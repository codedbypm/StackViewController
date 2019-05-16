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
    
    static func stacked(on stack: StackViewControllerHandling?,
                        delegate: DebugDelegate,
                        color: Color = .random) -> BaseViewController {

        let controller = BaseViewController(debugDelegate: delegate, color: color)
        controller.stack = stack

        controller.navigationItem.title = color.rawValue

        controller.onPopAnimated = {
            _ = controller.stack?.popViewController(animated: true)
        }

        controller.onPopNonAnimated = {
            _ = controller.stack?.popViewController(animated: false)
        }

        controller.onPushAnimated = {
            let next = self.stacked(on: controller.stack, delegate: delegate)
            controller.stack?.pushViewController(next, animated: true)
        }

        controller.onPushNonAnimated = {
            let next = self.stacked(on: controller.stack, delegate: delegate)
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

        controller.onSetViewControllersEmptyNonAnimated = {
            controller.stack?.setViewControllers([], animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                controller.onPushAnimated?()
            })
        }

        controller.onSetVarViewControllersEmpty = {
            controller.stack?.viewControllers = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                controller.onPushAnimated?()
            })
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
            let insert = self.stacked(on: controller.stack, delegate: delegate)
            var modifiedStack = controller.stack?.viewControllers
            modifiedStack?.insert(insert, at: 0)

            guard let newStack = modifiedStack else { return assertionFailure() }
            controller.stack?.viewControllers = newStack
        }

        return controller
    }}
