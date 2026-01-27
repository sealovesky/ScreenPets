import SwiftUI
import AppKit

/// 宠物绘制视图 - 使用 SwiftUI Canvas
struct PetCanvasView: View {
    let pet: (any Pet)?
    let screenOffset: CGPoint    // 这个屏幕在全局 Canvas 坐标系中的偏移

    var body: some View {
        Canvas { context, size in
            guard let pet = pet else { return }

            // 计算宠物在这个屏幕中的本地位置
            // pet.position 是全局 Canvas 坐标（所有屏幕联合区域，左上角原点）
            // screenOffset 是这个屏幕左上角在全局坐标系中的位置
            let localX = pet.position.x - screenOffset.x
            let localY = pet.position.y - screenOffset.y

            // 检查宠物是否在这个屏幕范围内
            let petSize: CGFloat = 100 * SettingsManager.shared.petScale
            let petRect = CGRect(x: localX, y: localY, width: petSize, height: petSize)
            let screenRect = CGRect(origin: .zero, size: size)

            // 如果宠物不在这个屏幕上，不绘制
            guard petRect.intersects(screenRect) else { return }

            // 移动到宠物位置并绘制
            var ctx = context
            ctx.translateBy(x: localX, y: localY)
            pet.draw(context: ctx)
        }
        .background(Color.clear)
    }
}

/// 单个屏幕的窗口控制器
class ScreenWindow {
    let window: NSWindow
    let hostingView: NSHostingView<PetCanvasView>
    let screenOffset: CGPoint  // 这个屏幕左上角在全局 Canvas 坐标系中的位置

    init(screen: NSScreen, screenOffset: CGPoint) {
        self.screenOffset = screenOffset

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.ignoresMouseEvents = true
        window.hasShadow = false
        window.isReleasedWhenClosed = false

        let canvasView = PetCanvasView(pet: nil, screenOffset: screenOffset)
        let hostingView = NSHostingView(rootView: canvasView)
        hostingView.frame = NSRect(origin: .zero, size: screen.frame.size)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor

        window.contentView = hostingView

        self.window = window
        self.hostingView = hostingView
    }

    func show() {
        window.orderFrontRegardless()
    }

    func close() {
        window.close()
    }

    func updatePet(_ pet: any Pet) {
        let canvasView = PetCanvasView(pet: pet, screenOffset: screenOffset)
        hostingView.rootView = canvasView
    }
}

/// 宠物窗口控制器 - 管理所有屏幕的窗口
class ImprovedPetWindowController {
    private var screenWindows: [ScreenWindow] = []

    init() {
        setupWindows()
    }

    private func setupWindows() {
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return }

        // 计算全局边界（macOS 坐标系）
        var globalMinX = CGFloat.infinity
        var globalMaxY = -CGFloat.infinity

        for screen in screens {
            globalMinX = min(globalMinX, screen.frame.minX)
            globalMaxY = max(globalMaxY, screen.frame.maxY)
        }

        print("🪟 全局边界: minX=\(globalMinX), maxY=\(globalMaxY)")
        print("🪟 屏幕数量: \(screens.count)")

        for (i, screen) in screens.enumerated() {
            // 计算这个屏幕在全局 Canvas 坐标系中的偏移
            // Canvas 坐标系：原点在左上角，Y 向下
            // macOS 坐标系：原点在左下角，Y 向上
            //
            // screenOffset.x = 屏幕左边缘相对于全局左边缘的距离
            // screenOffset.y = 屏幕顶边缘相对于全局顶边缘的距离（Canvas 坐标系）
            let offsetX = screen.frame.minX - globalMinX
            let offsetY = globalMaxY - screen.frame.maxY  // Y 轴翻转
            let screenOffset = CGPoint(x: offsetX, y: offsetY)

            print("🪟 屏幕 \(i): frame=\(screen.frame), offset=\(screenOffset)")

            let screenWindow = ScreenWindow(screen: screen, screenOffset: screenOffset)
            screenWindows.append(screenWindow)
        }

        print("🪟 创建了 \(screenWindows.count) 个窗口")
    }

    func showWindows() {
        print("🪟 显示 \(screenWindows.count) 个窗口")
        for window in screenWindows {
            window.show()
        }
    }

    func closeWindows() {
        print("🪟 关闭所有窗口")
        for window in screenWindows {
            window.close()
        }
        screenWindows.removeAll()
    }

    func updateWindows() {
        // 屏幕配置变化时，重新创建所有窗口
        closeWindows()
        setupWindows()
        showWindows()
    }

    func redraw(pet: any Pet) {
        for window in screenWindows {
            window.updatePet(pet)
        }
    }
}
