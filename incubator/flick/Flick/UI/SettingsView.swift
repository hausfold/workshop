import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    /// Live provider health, fed from the repository (name → reason string,
    /// nil = healthy). Experimental providers surface their honest state
    /// here instead of pretending.
    let providerStatus: [String: String?]
    var fetchProviderStatus: (() async -> [String: String?])? = nil
    let onRequestFullDiskAccess: () -> Void

    @State private var liveStatus: [String: String?]? = nil

    private var currentStatus: [String: String?] {
        liveStatus ?? providerStatus
    }

    private var hasFullDiskAccess: Bool {
        currentStatus["system-mirror"].flatMap { $0 } == nil
    }

    var body: some View {
        Form {
            Section("General") {
                Toggle("Start at login", isOn: $settings.launchAtLogin)
                Toggle("Keep history on disk", isOn: $settings.persistHistory)
            }

            Section("Providers") {
                LabeledContent("Socket (flick CLI)", value: currentStatus["socket"].flatMap { $0 } ?? "ready")

                if hasFullDiskAccess {
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("System Mirror (experimental)", isOn: $settings.systemMirrorEnabled)
                        Text("Reads macOS's private notification store, read-only, to redraw other apps' banners. May stop working on any macOS update — flick stays fully useful without it.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label("Full Disk Access granted", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield")
                                .font(.title3)
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("System Mirror (experimental)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Permission required")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }

                        Text("System Mirror reads macOS's private notification store to mirror banners from other apps. Full Disk Access is required before enabling.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let reason = currentStatus["system-mirror"].flatMap({ $0 }) {
                            Text(reason)
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }

                        Button(action: onRequestFullDiskAccess) {
                            Label("Grant Full Disk Access…", systemImage: "lock.shield.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .padding(.top, 2)
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(8)
                }
            }

            Section("Apple's banners") {
                Text("flick can't turn other apps' native banners off for you — that dial is Apple's. These jump straight to it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Button("Notification Settings…") {
                        SystemIntegration.openNotificationSettings()
                    }
                    Button("Focus Settings…") {
                        SystemIntegration.openFocusSettings()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 440)
        .task {
            guard let fetchProviderStatus else { return }
            while !Task.isCancelled {
                let status = await fetchProviderStatus()
                await MainActor.run {
                    self.liveStatus = status
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}
