//
//  AnalyticsClient.swift
//
//
//  Created by Adam Różyński on 28/03/2024.
//

import Clients
import Dependencies

extension Clients.AnalyticsClient: DependencyKey {
    public static let liveValue: Self = .init()
}
