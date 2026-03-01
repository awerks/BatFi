//
//  Server.swift
//
//
//  Created by Adam on 02/05/2023.
//

import AsyncXPCConnection
import EmbeddedPropertyList
import Foundation
import os
import Shared

public final class Server {
    private let logger = Logger(subsystem: Constant.helperBundleIdentifier, category: "Server")

    public init() {}

    public func start() throws {
        let data = try EmbeddedPropertyListReader.info.readInternal()
        let plist = try PropertyListDecoder().decode(HelperPropertyList.self, from: data)
        logger.notice("Server version: \(plist.version, privacy: .public), build: \(plist.build, privacy: .public)")

        let entitlement = plist.authorizedClients.first!
        var requirement: SecRequirement!
        var unmanagedError: Unmanaged<CFError>!

        let status = SecRequirementCreateWithStringAndErrors(
            entitlement as CFString,
            [],
            &unmanagedError,
            &requirement
        )

        if status != errSecSuccess {
            let error = unmanagedError.takeRetainedValue()
            logger.fault("Code signing requirement text, `\(entitlement)`, is not valid: \(error).")
        }

        let listener = NSXPCListener(machServiceName: Constant.helperBundleIdentifier)
        listener.setConnectionCodeSigningRequirement(entitlement)
        let delegate = ListenerDelegate()
        listener.delegate = delegate
        listener.resume()

        logger.notice("Server launched!")
        RunLoop.main.run()
        logger.error("RunLoop exited.")
    }
}
