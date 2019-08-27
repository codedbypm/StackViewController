//
//  Trace.swift
//  Traces
//
//  Created by Paolo Moroni on 26/08/2019.
//  Copyright © 2019 codedby.pm. All rights reserved.
//

import os.log

extension OSLog {

    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the event of the view life cycle
    public static let viewLifeCycle = OSLog(
        subsystem: subsystem,
        category: "viewLifeCycle"
    )

    /// Logs the view conyroller containment events
    public static let viewControllerContainment = OSLog(
        subsystem: subsystem,
        category: "viewControllerContainment"
    )

    /// Logs trait collection related events
    public static let traitCollection = OSLog(
        subsystem: subsystem,
        category: "traitCollectionCategory"
    )
}
