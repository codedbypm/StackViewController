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
        let navController = UINavigationController(rootViewController: yellowViewController())
        navController.delegate = self
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.tabBarItem = UITabBarItem(title: "UIKit", image: nil, tag: 1)
        return navController
    }()

    var interactionController: HorizontalSlideInteractiveController?

    func start() -> UIViewController {
        return navigationController
    }

    func yellowViewController() -> UIViewController {
        let yellow = YellowViewController()
        yellow.onNext = {
            self.navigationController.pushViewController(self.pinkViewController(), animated: true)
        }
        return yellow
    }

    func pinkViewController() -> UIViewController {
        let pink = PinkViewController()
        pink.onBack = { self.navigationController.popViewController(animated: true) }
        return pink
    }
}

extension UIKitCoordinator: UIGestureRecognizerDelegate {

//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return false
//    }
}

extension UIKitCoordinator: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        self.operation = operation

        switch operation {
        case .push:
            return HorizontalSlideAnimationController(type: .slideIn)
        case .pop:
            return HorizontalSlideAnimationController(type: .slideOut)
        default:
            return nil
        }
    }

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

