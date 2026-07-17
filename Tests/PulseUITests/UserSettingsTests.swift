// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(macOS)
import AppKit
import SwiftUI
import XCTest
@testable import PulseUI

final class UserSettingsTests: XCTestCase {
    @MainActor
    func testUnrelatedBackgroundDefaultsWriteDoesNotBlockWhileRendering() {
        let settings = UserSettings()
        let unrelatedKey = "pulse-unrelated-setting-\(UUID().uuidString)"
        defer { UserDefaults.standard.removeObject(forKey: unrelatedKey) }

        let host = NSHostingView(rootView: UserSettingsProbeView(settings: settings, generation: 0, onRender: {}))
        host.frame = NSRect(x: 0, y: 0, width: 300, height: 80)
        host.layoutSubtreeIfNeeded()

        let writerStarted = DispatchSemaphore(value: 0)
        let writerFinished = DispatchSemaphore(value: 0)
        let writer = DispatchQueue(label: "pulse-app-storage-write-probe")
        var didRender = false
        var didStartDuringRender = false
        var didFinishDuringRender = false

        host.rootView = UserSettingsProbeView(settings: settings, generation: 1) {
            guard !didRender else { return }
            didRender = true

            // SwiftUI holds its update lock here. A dotted AppStorage key makes this
            // unrelated write wait for the same lock, reproducing the deadlock.
            writer.async {
                writerStarted.signal()
                UserDefaults.standard.set(UUID().uuidString, forKey: unrelatedKey)
                writerFinished.signal()
            }

            didStartDuringRender = writerStarted.wait(timeout: .now() + .seconds(2)) == .success
            didFinishDuringRender = writerFinished.wait(timeout: .now() + .seconds(2)) == .success
        }
        host.layoutSubtreeIfNeeded()

        XCTAssertTrue(didRender)
        XCTAssertTrue(didStartDuringRender)
        XCTAssertTrue(didFinishDuringRender, "An unrelated UserDefaults write blocked while SwiftUI was rendering Pulse settings")

        if !didFinishDuringRender {
            XCTAssertEqual(writerFinished.wait(timeout: .now() + .seconds(2)), .success)
        }
    }
}

private struct UserSettingsProbeView: View {
    @ObservedObject var settings: UserSettings
    let generation: Int
    let onRender: () -> Void

    var body: some View {
        let _ = onRender()
        return Text("\(generation): \(settings.mode.rawValue)")
    }
}
#endif
