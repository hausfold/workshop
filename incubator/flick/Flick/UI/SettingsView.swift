import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    /// Live provider health, fed from the repository (name → reason string,
    /// nil = healthy). Experimental providers surface their honest state
    /// here instead of pretending.
    let providerStatus: [String: String?]

    var body: some View {
        Form {
            Section("General") {
                Toggle("Start at login", isOn: $settings.launchAtLogin)
                Toggle("Keep history on disk", isOn: $settings.persistHistory)
            }

            Section("Providers") {
                LabeledContent("Socket (flick CLI)", value: providerStatus["socket"].flatMap { $0 } ?? "ready")
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("System Mirror (experimental)", isOn: $settings.systemMirrorEnabled)
                    Text("Reads macOS's private notification store, read-only, to redraw other apps' banners. Needs Full Disk Access and may stop working on any macOS update — flick stays fully useful without it.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let reason = providerStatus["system-mirror"].flatMap({ $0 }) {
                        Text(reason)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
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
    }
}
