//
//  UIKitCoordinator.swift
//  TestApp
//
//  Created by Paolo Moroni on 20/04/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import StackViewController

extension UINavigationController: StackViewControllerHandling {}

class UIKitCoordinator: NSObject {

    let debugPrefix = "[UIKit]"
    let canPrint = false

    var operation: UINavigationController.Operation = .none

    lazy var navigationController: UINavigationController = {
        let navController = UINavigationController(rootViewController: yellowViewController)
        navController.delegate = self
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.tabBarItem = UITabBarItem(title: debugPrefix, image: nil, tag: 1)
        return navController
    }()

    var interactionController: HorizontalSlideInteractiveController?

    lazy var yellowViewController: BaseViewController = {
        let yellow = BaseViewController(delegate: self, color: .yellow, title: titled("lazy var yellow"), showsBackButton: false)
        yellow.onNext = {
            self.navigationController.pushViewController(self.greenViewController, animated: true)
        }

        yellow.onReplaceViewControllers = {
            let root = self.newGreenViewController(title: self.titled("root green"))
            let top = self.newGreenViewController(title: self.titled("top green")) {
                self.navigationController.setViewControllers([], animated: false)
            }

            self.navigationController.setViewControllers([root, yellow, top], animated: true)
        }

        yellow.onEmptyStack = {
            self.navigationController.setViewControllers([], animated: true)
        }

        return yellow
    }()
    
    lazy var greenViewController: BaseViewController = {
        let green = newGreenViewController(title: titled("lazy var green"))
        green.delegate = self
        return green
    }()

    func newGreenViewController(title: String, onEmptyStack: (() -> Void)? = nil) -> BaseViewController {
        let green = BaseViewController(delegate: self, color: .green, title: title)
        green.navigationItem.title = title
        green.onBack = { self.navigationController.popViewController(animated: true) }
        green.onEmptyStack = onEmptyStack
        return green
    }

    func titled(_ title: String) -> String {
        return "\(debugPrefix) \(title)"
    }
}

extension UIKitCoordinator: UIGestureRecognizerDelegate {

//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return false
//    }
}

extension UIKitCoordinator: UINavigationControllerDelegate {

//    func navigationController(_ navigationController: UINavigationController,
//                              animationControllerFor operation: UINavigationController.Operation,
//                              from fromVC: UIViewController,
//                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//        self.operation = operation
//
//        switch operation {
//        case .push:
//            return HorizontalSlideAnimationController(type: .slideIn)
//        case .pop:
//            return HorizontalSlideAnimationController(type: .slideOut)
//        default:
//            return nil
//        }
//    }

//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
//        guard let gestureRecognizer = navigationController.interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer else { return nil }
//
//        gestureRecognizer.removeTarget(nil, action: nil)
//        interactionController = HorizontalSlideInteractiveController(animationController: animationController,
//                                                                     gestureRecognizer: gestureRecognizer)
//        return interactionController
//    }
}

extension UIKitCoordinator: DebugDelegate {

    func debug(_ text: String) {
        guard canPrint else { return }
        print(text)
    }
}
