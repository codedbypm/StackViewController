//
//  ScreenEdgePanGestureRecognizer.swift
//  StackViewController
//
//  Created by Paolo Moroni on 07/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import UIKit.UIGestureRecognizer

class ScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer {
    var initialTouchLocation: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first?.location(in: view)
    }
}
