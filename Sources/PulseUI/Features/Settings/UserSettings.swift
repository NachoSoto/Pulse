// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse
import Combine

/// Allows you to control Pulse appearance and other settings programmatically.
public final class UserSettings: ObservableObject {
    public static let shared = UserSettings()

    // Keep AppStorage keys dot-free so SwiftUI can observe each setting individually.
    /// The console default mode.
    @AppStorage("com_github_kean_pulse_console_mode")
    public var mode: ConsoleMode = .network

    /// The line limit for messages in the console. By default, `3`.
    @AppStorage("com_github_kean_pulse_console_cell_line_limit")
    public var lineLimit: Int = 3

    /// Enables link detection in the response viewier. By default, `false`.
    @AppStorage("com_github_kean_pulse_link_detection")
    public var isLinkDetectionEnabled = false

    /// The default sharing output type. By default, ``ShareStoreOutput/store``.
    @AppStorage("com_github_kean_pulse_sharing_output")
    public var sharingOutput: ShareStoreOutput = .store

    /// HTTP headers to display in a Console. By default, empty.
    public var displayHeaders: [String] {
        get {
            let data = rawDisplayHeaders.data(using: .utf8) ?? Data()
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            rawDisplayHeaders = String(data: data, encoding: .utf8) ?? "[]"
        }
    }

    @AppStorage("com_github_kean_pulse_display_headers")
    var rawDisplayHeaders: String = "[]"

    /// If `true`, the network inspector will show the current request by default.
    /// If `false`, show the original request.
    @AppStorage("com_github_kean_pulse_show_current_request")
    public var isShowingCurrentRequest = true
}
