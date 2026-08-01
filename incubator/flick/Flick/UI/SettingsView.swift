import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    /// Live provider health, fed from the repository (name → reason string,
    /// nil = healthy). Experimental providers surface their honest state
    /// here instead of pretending.
    let providerStatus: [String: String?]
    var fetchProviderStatus: (() async -> [String: String?])? = nil
    let onRequestFullDiskAccess: () -> Void
    /// True when this window was reopened by the Full Disk Access assistant
    /// right after the grant landed — the one moment the unlock is worth
    /// celebrating rather than just stating.
    var celebrateUnlock: Bool = false

    @State private var liveStatus: [String: String?]? = nil
    @State private var celebrating = false

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
                    systemMirrorUnlocked
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    systemMirrorLocked
                        .transition(.opacity.combined(with: .move(edge: .top)))
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
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        self.liveStatus = status
                    }
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        .task {
            guard celebrateUnlock else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { celebrating = true }
            try? await Task.sleep(nanoseconds: 3_200_000_000)
            withAnimation(.easeOut(duration: 0.8)) { celebrating = false }
        }
    }

    // MARK: - System Mirror, unlocked

    @ViewBuilder
    private var systemMirrorUnlocked: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle("System Mirror (experimental)", isOn: $settings.systemMirrorEnabled)

            HStack(spacing: 6) {
                Image(systemName: "lock.open.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text(celebrating ? "Unlocked — System Mirror is live" : "Full Disk Access granted")
                    .font(.caption)
                    .fontWeight(celebrating ? .semibold : .regular)
                    .foregroundStyle(.green)
                    .contentTransition(.opacity)
            }
            .scaleEffect(celebrating ? 1.06 : 1, anchor: .leading)

            Text("Reads macOS's private notification store, read-only, to redraw other apps' banners. May stop working on any macOS update — flick stays fully useful without it.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(celebrating ? 10 : 0)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(celebrating ? 0.12 : 0))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.green.opacity(celebrating ? 0.35 : 0), lineWidth: 1)
                )
        )
    }

    // MARK: - System Mirror, locked

    /// Deliberately *not* a disabled switch with a button underneath: a
    /// switch that silently refuses to move reads as a bug, and a button
    /// below it reads as unrelated. Until Full Disk Access exists there is
    /// exactly one thing to do here, so the section shows exactly that —
    /// what the feature buys, the two steps to it, and one button.
    @ViewBuilder
    private var systemMirrorLocked: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.85), Color.accentColor.opacity(0.45)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 34, height: 34)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("System Mirror")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Locked · experimental")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text("Unlock it and flick redraws **every other app's** banners in its own quiet style — Messages, Mail, Calendar, the lot. macOS keeps that store behind Full Disk Access, so it has to be granted once.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                unlockStep(1, "Grant flick Full Disk Access", isCurrent: true)
                unlockStep(2, "flick switches System Mirror on for you", isCurrent: false)
            }

            Button(action: onRequestFullDiskAccess) {
                Label("Unlock System Mirror…", systemImage: "lock.open.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if let reason = currentStatus["system-mirror"].flatMap({ $0 }) {
                Text(reason)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.accentColor.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.accentColor.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func unlockStep(_ number: Int, _ text: String, isCurrent: Bool) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCurrent ? Color.accentColor : Color.secondary.opacity(0.22))
                    .frame(width: 17, height: 17)
                Text("\(number)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(isCurrent ? Color.white : Color.secondary)
            }
            Text(text)
                .font(.caption)
                .foregroundStyle(isCurrent ? .primary : .secondary)
        }
    }
}
