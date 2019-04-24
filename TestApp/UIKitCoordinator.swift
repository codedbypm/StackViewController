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

    var operation: UINavigationController.Operation = .none

    lazy var navigationController: UINavigationController = {
        let navController = UINavigationController(rootViewController: yellowViewController)
        navController.delegate = self
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.tabBarItem = UITabBarItem(title: "UIKit", image: nil, tag: 1)
        return navController
    }()

    var interactionController: HorizontalSlideInteractiveController?

    lazy var yellowViewController: YellowViewController = {
        let yellow = YellowViewController()
        yellow.navigationItem.title = "var yellow"
        yellow.onNext = {
            self.navigationController.pushViewController(self.pinkViewController, animated: true)
        }

        yellow.onReplaceViewControllers = {
            let viewControllers = [
                self.newPinkViewController(title: "root pink"),
                yellow,
                self.newPinkViewController(title: "top pink") {
                    self.navigationController.setViewControllers([], animated: false)
                }
            ]

            self.navigationController.setViewControllers(viewControllers, animated: true)
        }

        yellow.onEmptyStack = {
            self.navigationController.setViewControllers([], animated: true)
        }
        return yellow
    }()
    
    lazy var pinkViewController: UIViewController = newPinkViewController(title: "var pink")

    func newPinkViewController(title: String, onEmptyStack: (() -> Void)? = nil) -> UIViewController {
        let pink = PinkViewController()
        pink.navigationItem.title = title
        pink.onBack = { self.navigationController.popViewController(animated: true) }
        pink.onEmptyStack = onEmptyStack
        return pink
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

