//
//  ContentView.swift
//  Claude Provider Switcher
//
//  Created by Michal Macinka on 10.02.2026.
//

import SwiftUI

struct ContentView: View {
    var appState: AppState

    @State private var selectedMode: ProviderMode = .subscription
    @State private var apiKey: String = ""
    @State private var statusMessage: String = ""
    @State private var isError: Bool = false
    @State private var savedApiKey: String = ""

    private var activeMode: ProviderMode {
        appState.currentMode
    }

    var body: some View {
        VStack(spacing: 0) {
            // Active mode indicator
            activeModeBar
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 12)

            Divider()

            // Mode cards
            VStack(spacing: 8) {
                Text("SELECT MODE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    modeCard(for: .subscription)
                    modeCard(for: .openrouter)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // OpenRouter API Key Section
            if selectedMode == .openrouter {
                VStack(alignment: .leading, spacing: 6) {
                    SecureField("OpenRouter API Key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)

                    Text("Stored in the provider configuration file.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    if !apiKey.isEmpty {
                        Button("Clear Saved Key") {
                            clearKey()
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }

            // Status banner
            if !statusMessage.isEmpty {
                statusBanner
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
            }

            Spacer().frame(height: 12)

            Divider()

            // Action buttons
            HStack(spacing: 8) {
                Button(action: applyConfiguration) {
                    Text("Activate")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(selectedMode == activeMode && (selectedMode == .subscription || !apiKey.isEmpty && apiKey == savedApiKey))

                Button(action: { ProviderManager.openInFinder() }) {
                    Image(systemName: "folder")
                }
                .controlSize(.large)
                .help("Open provider file in Finder")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            HStack {
                Text("v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?")")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
        .onAppear {
            loadConfiguration()
        }
        .onChange(of: selectedMode) { _, newMode in
            if newMode == .openrouter && apiKey.isEmpty {
                apiKey = savedApiKey
            }
        }
    }

    // MARK: - Active Mode Bar

    private var activeModeBar: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.green)
                .frame(width: 7, height: 7)

            Image(systemName: activeMode.iconName)
                .font(.system(size: 11, weight: .medium))

            Text(activeMode.displayName)
                .font(.system(size: 12, weight: .semibold))

            Spacer()

            Text("Active")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.1))
                .strokeBorder(Color.green.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Mode Card

    private func modeCard(for mode: ProviderMode) -> some View {
        let isSelected = selectedMode == mode
        let isActive = activeMode == mode

        return Button {
            selectedMode = mode
        } label: {
            VStack(spacing: 6) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? .white : .primary)

                Text(mode.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)

                if isActive {
                    Text("Current")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .green)
                } else {
                    Text(" ")
                        .font(.system(size: 9))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isActive && !isSelected ? Color.green.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .font(.system(size: 12))

            Text(statusMessage)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(isError ? .red : .green)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isError ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        )
    }

    // MARK: - Actions

    private func loadConfiguration() {
        selectedMode = ProviderManager.detectMode()
        savedApiKey = ProviderManager.loadApiKey() ?? ""
        if selectedMode == .openrouter {
            apiKey = savedApiKey
        }
    }

    private func applyConfiguration() {
        statusMessage = ""
        isError = false

        if selectedMode == .openrouter && apiKey.isEmpty {
            statusMessage = "OpenRouter API key is missing."
            isError = true
            return
        }

        do {
            try ProviderManager.writeProviderFile(mode: selectedMode, apiKey: selectedMode == .openrouter ? apiKey : nil)
            appState.refresh()
            savedApiKey = selectedMode == .openrouter ? apiKey : ""
            statusMessage = "Activated. Open a new terminal or reload your shell (source ~/.zshrc)."
            isError = false
        } catch {
            statusMessage = "Failed to write provider file: \(error.localizedDescription)"
            isError = true
        }
    }

    private func clearKey() {
        apiKey = ""
        statusMessage = "API key cleared."
        isError = false
    }
}

#Preview {
    ContentView(appState: AppState())
}
