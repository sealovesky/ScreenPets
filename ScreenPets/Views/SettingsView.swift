import SwiftUI

/// 设置面板视图
struct SettingsView: View {
    @EnvironmentObject var petManager: PetManager
    @EnvironmentObject var settings: SettingsManager
    @StateObject private var launchAtLogin = LaunchAtLoginManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Text("🐾 \(NSLocalizedString("settings.title", comment: ""))")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $settings.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            Divider()

            // 宠物选择
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("settings.selectPet", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    ForEach(PetType.allCases) { petType in
                        PetSelectionButton(
                            petType: petType,
                            isSelected: settings.selectedPetType == petType
                        ) {
                            settings.selectedPetType = petType
                        }
                    }
                }
            }

            Divider()

            // 模式选择
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("settings.movementMode", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("", selection: $settings.petModeRaw) {
                    ForEach(PetMode.allCases) { mode in
                        Text(mode.localizedName).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Text(settings.petMode.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // 速度调节
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("settings.speed", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f", settings.petSpeed))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Slider(value: $settings.petSpeed, in: 1...10, step: 0.5)
            }

            // 大小调节
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("settings.size", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1fx", settings.petScale))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Slider(value: $settings.petScale, in: 0.5...2.0, step: 0.1)
            }

            Divider()

            // 开机自启动
            HStack {
                Text(NSLocalizedString("settings.launchAtLogin", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: $launchAtLogin.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            Divider()

            // 底部按钮
            HStack {
                Button(NSLocalizedString("settings.about", comment: "")) {
                    showAbout()
                }

                Spacer()

                Button(NSLocalizedString("settings.quit", comment: "")) {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 280)
    }

    private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "ScreenPets"
        let version = NSLocalizedString("about.version", comment: "")
        let desc = NSLocalizedString("about.description", comment: "")
        let pets = NSLocalizedString("about.pets", comment: "")
        alert.informativeText = "\(version)\n\n\(desc)\n\n\(pets)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: NSLocalizedString("about.ok", comment: ""))
        alert.runModal()
    }
}

/// 宠物选择按钮
struct PetSelectionButton: View {
    let petType: PetType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(petType.icon)
                    .font(.system(size: 28))

                Text(petType.localizedName)
                    .font(.caption)
            }
            .frame(width: 70, height: 60)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PetManager.shared)
        .environmentObject(SettingsManager.shared)
}
