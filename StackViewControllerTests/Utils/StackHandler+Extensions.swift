//
//  StackHandler+Extensions.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 12/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

extension StackHandler {

    static func withDistinctElements(_ size: Int) -> StackHandler {
        return StackHandler(stack: Stack.distinctElements(size))
    }
    
}
