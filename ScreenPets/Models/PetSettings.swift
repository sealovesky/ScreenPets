import SwiftUI
import Combine

/// 设置管理器 - 使用 @Published 以支持 Combine 订阅
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    @Published var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: "isEnabled") }
    }

    @Published var selectedPetTypeRaw: String {
        didSet { defaults.set(selectedPetTypeRaw, forKey: "selectedPetType") }
    }

    @Published var petModeRaw: String {
        didSet { defaults.set(petModeRaw, forKey: "petMode") }
    }

    @Published var petSpeed: Double {
        didSet { defaults.set(petSpeed, forKey: "petSpeed") }
    }

    @Published var petScale: Double {
        didSet { defaults.set(petScale, forKey: "petScale") }
    }

    var selectedPetType: PetType {
        get { PetType(rawValue: selectedPetTypeRaw) ?? .dragon }
        set { selectedPetTypeRaw = newValue.rawValue }
    }

    var petMode: PetMode {
        get { PetMode(rawValue: petModeRaw) ?? .crossScreen }
        set { petModeRaw = newValue.rawValue }
    }

    private init() {
        // 从 UserDefaults 加载初始值
        self.isEnabled = defaults.object(forKey: "isEnabled") as? Bool ?? true
        self.selectedPetTypeRaw = defaults.string(forKey: "selectedPetType") ?? PetType.dragon.rawValue
        self.petModeRaw = defaults.string(forKey: "petMode") ?? PetMode.crossScreen.rawValue
        self.petSpeed = defaults.object(forKey: "petSpeed") as? Double ?? 3.0
        self.petScale = defaults.object(forKey: "petScale") as? Double ?? 1.0
    }
}
