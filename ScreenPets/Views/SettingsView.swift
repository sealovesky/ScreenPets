import SwiftUI

/// 设置面板视图
struct SettingsView: View {
    @EnvironmentObject var petManager: PetManager
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Text("🐾 ScreenPets")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $settings.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            Divider()

            // 宠物选择
            VStack(alignment: .leading, spacing: 8) {
                Text("选择宠物")
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
                Text("移动模式")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("", selection: $settings.petModeRaw) {
                    ForEach(PetMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Text(settings.petMode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // 速度调节
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("移动速度")
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
                    Text("宠物大小")
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

            // 底部按钮
            HStack {
                Button("关于") {
                    showAbout()
                }

                Spacer()

                Button("退出") {
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
        alert.informativeText = "版本 1.0\n\n让可爱的小宠物在你的屏幕上奔跑！\n\n🐉 飞龙 - 喷火的小龙\n🌈 彩虹猫 - Nyan Cat 风格\n👻 幽灵 - 可爱的小幽灵"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
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

                Text(petType.rawValue)
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
