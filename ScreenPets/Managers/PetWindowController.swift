import SwiftUI
import AppKit

/// 宠物状态包装器 - 用于 SwiftUI 观察
class PetState: ObservableObject {
    @Published var pet: (any Pet)?

    func update(_ pet: any Pet) {
        self.pet = pet
    }
}

/// 宠物绘制视图 - 使用 SwiftUI Canvas
struct PetCanvasView: View {
    @ObservedObject var petState: PetState
    let screenOffset: CGPoint

    var body: some View {
        Canvas { context, size in
            guard let pet = petState.pet else { return }

            let localX = pet.position.x - screenOffset.x
            let localY = pet.position.y - screenOffset.y

            let petSize: CGFloat = 100 * SettingsManager.shared.petScale
            let petRect = CGRect(x: localX, y: localY, width: petSize, height: petSize)
            let screenRect = CGRect(origin: .zero, size: size)

            guard petRect.intersects(screenRect) else { return }

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
    let petState: PetState
    let screenOffset: CGPoint

    init(screen: NSScreen, screenOffset: CGPoint, sharedPetState: PetState) {
        self.screenOffset = screenOffset
        self.petState = sharedPetState

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

        let canvasView = PetCanvasView(petState: sharedPetState, screenOffset: screenOffset)
        let hostingView = NSHostingView(rootView: canvasView)
        hostingView.frame = NSRect(origin: .zero, size: screen.frame.size)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor

        window.contentView = hostingView
        self.window = window
    }

    func show() {
        window.orderFrontRegardless()
    }

    func close() {
        window.close()
    }
}

/// 宠物窗口控制器 - 管理所有屏幕的窗口
class ImprovedPetWindowController {
    private var screenWindows: [ScreenWindow] = []
    private let petState = PetState()

    init() {
        setupWindows()
    }

    private func setupWindows() {
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return }

        var globalMinX = CGFloat.infinity
        var globalMaxY = -CGFloat.infinity

        for screen in screens {
            globalMinX = min(globalMinX, screen.frame.minX)
            globalMaxY = max(globalMaxY, screen.frame.maxY)
        }

        for screen in screens {
            let offsetX = screen.frame.minX - globalMinX
            let offsetY = globalMaxY - screen.frame.maxY
            let screenOffset = CGPoint(x: offsetX, y: offsetY)

            let screenWindow = ScreenWindow(screen: screen, screenOffset: screenOffset, sharedPetState: petState)
            screenWindows.append(screenWindow)
        }
    }

    func showWindows() {
        for window in screenWindows {
            window.show()
        }
    }

    func closeWindows() {
        for window in screenWindows {
            window.close()
        }
        screenWindows.removeAll()
    }

    func updateWindows() {
        closeWindows()
        setupWindows()
        showWindows()
    }

    func redraw(pet: any Pet) {
        petState.update(pet)
    }
}
