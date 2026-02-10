//
//  ProviderMode.swift
//  Claude Provider Switcher
//
//  Created by Michal Macinka on 10.02.2026.
//

import Foundation

enum ProviderMode: String, CaseIterable, Identifiable {
    case subscription
    case openrouter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .subscription:
            return "Subscription"
        case .openrouter:
            return "OpenRouter"
        }
    }

    var iconName: String {
        switch self {
        case .subscription:
            return "person.fill"
        case .openrouter:
            return "network"
        }
    }
}
