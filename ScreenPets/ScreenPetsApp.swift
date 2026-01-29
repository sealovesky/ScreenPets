import SwiftUI

@main
struct ScreenPetsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        MenuBarExtra {
            SettingsView()
                .environmentObject(PetManager.shared)
                .environmentObject(SettingsManager.shared)
        } label: {
            Image(systemName: "pawprint.fill")
        }
        .menuBarExtraStyle(.window)
    }
}

/// App 代理
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 触发 PetManager 初始化
        _ = PetManager.shared
    }
}
