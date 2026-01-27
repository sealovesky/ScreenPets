import ServiceManagement
import SwiftUI

/// 开机自启动管理器
class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()

    @Published var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                updateLaunchAtLogin()
            }
        }
    }

    private init() {
        // 读取当前状态
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    private func updateLaunchAtLogin() {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(isEnabled ? "enable" : "disable") launch at login: \(error)")
            // 恢复状态
            DispatchQueue.main.async {
                self.isEnabled = SMAppService.mainApp.status == .enabled
            }
        }
    }

    /// 刷新状态（用于从系统偏好设置更改后同步）
    func refreshStatus() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
