//
//  ConsoleDebuggable.swift
//  TestApp
//
//  Created by Paolo Moroni on 01/05/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import Foundation

public protocol DebugDelegate: class {
    var debugPrefix: String { get }
    func debug(_ text: String)
}

public protocol ConsoleDebuggable: class {
    var debugDelegate: DebugDelegate? { get }
    var debugArrow: String { get }

    func debugFunc(_ functionName: String, allowed: Bool, appending string: String?)
}

public extension ConsoleDebuggable {
    var debugArrow: String {
        return "\t=>\t"
    }
}

extension ConsoleDebuggable {

    public func debugFunc(_ functionName: String, allowed: Bool, appending string: String? = nil) {
        if allowed {
            debugDelegate?.debug(String(describing: self)
                .appending(debugArrow)
                .appending(functionName)
                .appending(string ?? ""))
        }
    }
}
