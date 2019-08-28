//
//  Tracing.swift
//  Traces
//
//  Created by Paolo Moroni on 26/08/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import os.log

public protocol Tracing {
    func trace(_ system: OSLog, type: OSLogType, text: StaticString, _ args: CVarArg...)
}

public extension Tracing {

    @inlinable func trace(
        _ system: OSLog,
        type: OSLogType = .debug,
        text: StaticString = "",
        _ args: CVarArg...
    ) {
        _trace(system, type: type, text: text, args)
    }

    @usableFromInline internal func _trace(
        _ system: OSLog,
        type: OSLogType,
        text: StaticString,
        _ args: [CVarArg]
    ) {
        // The Swift overlay of os_log prevents from accepting an unbounded number of args
        // http://www.openradar.me/33203955

        let argsCount = args.count

        guard argsCount < 5 else {
            assertionFailure()
            return
        }

        switch args.count {
        case 5:
            let format = (text.utf8CodeUnitCount == 0 ? "%@ - %@ - %@ - %@ - %@" : text)
            os_log(format, log: system, type: type, args[0], args[1], args[2], args[3], args[4])
        case 4:
            let format = (text.utf8CodeUnitCount == 0 ? "%@ - %@ - %@ - %@" : text)
            os_log(format, log: system, type: type, args[0], args[1], args[2], args[3])
        case 3:
            let format = (text.utf8CodeUnitCount == 0 ? "%@ - %@ - %@" : text)
            os_log(format, log: system, type: type, args[0], args[1], args[2])
        case 2:
            let format = (text.utf8CodeUnitCount == 0 ? "%@ - %@" : text)
            os_log(format, log: system, type: type, args[0], args[1])
        case 1:
            let format = (text.utf8CodeUnitCount == 0 ? "%@" : text)
            os_log(format, log: system, type: type, args[0])
        case 0:
            let format = text
            os_log(format, log: system, type: type)
        default:
            assertionFailure()
        }
    }
}

