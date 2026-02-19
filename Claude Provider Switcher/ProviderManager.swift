//
//  ProviderManager.swift
//  Claude Provider Switcher
//
//  Created by Michal Macinka on 10.02.2026.
//

import Foundation
import AppKit

enum ProviderManager {
    static let filePath = NSString(string: "~/.config/claude-code/provider.zsh").expandingTildeInPath

    static func detectMode() -> ProviderMode {
        guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return .subscription
        }

        return content.contains("openrouter.ai/api") ? .openrouter : .subscription
    }

    static func loadApiKey() -> String? {
        guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return nil
        }

        for line in content.components(separatedBy: "\n") {
            let prefix = "export OPENROUTER_API_KEY=\""
            if line.hasPrefix(prefix) {
                return String(line.dropFirst(prefix.count).dropLast())
            }
        }

        return nil
    }

    static func writeProviderFile(mode: ProviderMode, apiKey: String? = nil) throws {
        let directoryPath = (filePath as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)

        let content: String
        switch mode {
        case .subscription:
            content = """
            # Claude Code: subscription mode (no API env)
            unset OPENROUTER_API_KEY
            unset ANTHROPIC_AUTH_TOKEN
            unset ANTHROPIC_BASE_URL
            unset ANTHROPIC_CUSTOM_HEADERS
            unset ANTHROPIC_API_KEY
            """
        case .openrouter:
            let key = apiKey ?? ""
            content = """
            # Claude Code: OpenRouter mode
            export OPENROUTER_API_KEY="\(key)"
            export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
            export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
            export ANTHROPIC_API_KEY=""
            """
        }

        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
    }

    static func openInFinder() {
        let fileURL = URL(fileURLWithPath: filePath)

        if FileManager.default.fileExists(atPath: filePath) {
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } else {
            let directoryURL = fileURL.deletingLastPathComponent()
            NSWorkspace.shared.open(directoryURL)
        }
    }
}
