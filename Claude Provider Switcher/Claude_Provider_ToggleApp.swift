//
//  Claude_Provider_ToggleApp.swift
//  Claude Provider Switcher
//
//  Created by Michal Macinka on 10.02.2026.
//

import SwiftUI

@Observable
class AppState {
    var currentMode: ProviderMode

    init() {
        self.currentMode = ProviderManager.detectMode()
    }

    func refresh() {
        currentMode = ProviderManager.detectMode()
    }
}

@main
struct Claude_Provider_ToggleApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            ContentView(appState: appState)
        } label: {
            Image(systemName: appState.currentMode.iconName)
        }
        .menuBarExtraStyle(.window)
    }
}
