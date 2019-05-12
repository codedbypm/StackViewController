//
//  Mock.StackHandlerDelegate.swift
//  StackViewControllerTests
//
//  Created by Paolo Moroni on 12/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

@testable import StackViewController

class MockStackHandlerDelegate: StackHandlerDelegate {
    var insertions: Stack.Insertions = []
    var removals: Stack.Removals = []
    var didCallStackDidChange = false

    func stackDidChange(_ difference: Stack.Difference) {
        self.insertions = difference.insertions
        self.removals = difference.removals
        self.didCallStackDidChange = true
    }
}
