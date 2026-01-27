import SwiftUI
import Combine

/// 宠物管理器 - 管理宠物生命周期和动画
class PetManager: ObservableObject {
    static let shared = PetManager()

    @Published var currentPet: (any Pet)?

    private var windowController: ImprovedPetWindowController?
    private var displayLink: CVDisplayLink?
    private var lastUpdateTime: Double = 0
    private var cancellables = Set<AnyCancellable>()
    private var isInitialized = false

    private init() {
        print("🐾 PetManager init 开始")
        // 延迟初始化，避免在 init 中访问其他单例
        DispatchQueue.main.async { [weak self] in
            self?.delayedInit()
        }
    }

    private func delayedInit() {
        guard !isInitialized else { return }
        isInitialized = true

        print("🐾 PetManager delayedInit 开始")
        setupObservers()
        startIfEnabled()
        print("🐾 PetManager delayedInit 完成")
    }

    private func setupObservers() {
        print("🐾 设置观察者")

        // 监听设置变化
        SettingsManager.shared.$isEnabled
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                print("🐾 isEnabled 变化: \(enabled)")
                if enabled {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
            .store(in: &cancellables)

        SettingsManager.shared.$selectedPetTypeRaw
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🐾 宠物类型变化")
                self?.changePet()
            }
            .store(in: &cancellables)

        SettingsManager.shared.$petModeRaw
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🐾 移动模式变化")
                self?.resetPetPosition()
            }
            .store(in: &cancellables)

        // 监听屏幕变化
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🐾 屏幕配置变化")
                self?.handleScreenChange()
            }
            .store(in: &cancellables)
    }

    private func startIfEnabled() {
        print("🐾 startIfEnabled: isEnabled = \(SettingsManager.shared.isEnabled)")
        if SettingsManager.shared.isEnabled {
            start()
        }
    }

    func start() {
        guard windowController == nil else {
            print("🐾 windowController 已存在，跳过启动")
            return
        }

        print("🐾 开始启动宠物...")

        // 创建宠物
        let petType = SettingsManager.shared.selectedPetType
        currentPet = petType.createPet()
        print("🐾 创建宠物: \(petType.rawValue)")

        // 先创建窗口（避免 resetPetPosition 递归调用 start）
        windowController = ImprovedPetWindowController()

        // 然后初始化位置
        initializePetPosition()
        print("🐾 宠物位置: \(currentPet?.position ?? .zero)")

        // 显示窗口
        windowController?.showWindows()

        // 启动动画循环
        startDisplayLink()
        print("🐾 动画循环已启动")
    }

    func stop() {
        stopDisplayLink()
        windowController?.closeWindows()
        windowController = nil
        currentPet = nil
    }

    func changePet() {
        print("🐾 changePet 被调用")
        // 如果当前是启用状态但窗口不存在，先启动
        if SettingsManager.shared.isEnabled && windowController == nil {
            print("🐾 窗口不存在，重新启动")
            start()
            return
        }

        let petType = SettingsManager.shared.selectedPetType
        currentPet = petType.createPet()
        resetPetPosition()
        print("🐾 宠物已更换为: \(petType.rawValue)")
    }

    /// 初始化宠物位置（仅在 start 内部调用，不触发重新启动）
    private func initializePetPosition() {
        guard var pet = currentPet else {
            print("🐾 没有当前宠物")
            return
        }

        let bounds = calculateBounds()
        pet.position = CGPoint(x: bounds.minX, y: bounds.minY)
        pet.direction = CGVector(dx: 1, dy: SettingsManager.shared.petMode == .freeRoam ? Double.random(in: -1...1) : 0)
        currentPet = pet
        print("🐾 宠物位置已初始化: \(pet.position)")
    }

    func resetPetPosition() {
        print("🐾 resetPetPosition 被调用")
        // 如果当前是启用状态但窗口不存在，先启动
        if SettingsManager.shared.isEnabled && windowController == nil {
            print("🐾 窗口不存在，重新启动")
            start()
            return
        }

        initializePetPosition()
    }

    private func handleScreenChange() {
        windowController?.updateWindows()
        resetPetPosition()
    }

    // MARK: - Display Link

    private func startDisplayLink() {
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)

        guard let displayLink = link else { return }

        let callback: CVDisplayLinkOutputCallback = { _, _, _, _, _, userInfo -> CVReturn in
            let manager = Unmanaged<PetManager>.fromOpaque(userInfo!).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.update()
            }
            return kCVReturnSuccess
        }

        let userInfo = Unmanaged.passUnretained(self).toOpaque()
        CVDisplayLinkSetOutputCallback(displayLink, callback, userInfo)
        CVDisplayLinkStart(displayLink)

        self.displayLink = displayLink
        self.lastUpdateTime = CACurrentMediaTime()
    }

    private func stopDisplayLink() {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
        displayLink = nil
    }

    // MARK: - Update Loop

    private func update() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        guard var pet = currentPet else { return }

        let bounds = calculateBounds()
        let mode = SettingsManager.shared.petMode

        pet.update(deltaTime: deltaTime, bounds: bounds, mode: mode)
        currentPet = pet

        // 触发重绘
        windowController?.redraw(pet: pet)
    }

    // MARK: - Bounds Calculation

    /// 计算宠物活动边界（使用 Canvas 坐标系：左上角原点，Y向下）
    func calculateBounds() -> CGRect {
        let screens = NSScreen.screens
        guard !screens.isEmpty else {
            return CGRect(x: 0, y: 0, width: 1920, height: 100)
        }

        let mode = SettingsManager.shared.petMode
        let petHeight: CGFloat = 100

        // 计算全局边界（macOS 坐标系）
        var globalMinX = CGFloat.infinity
        var globalMaxX = -CGFloat.infinity
        var globalMinY = CGFloat.infinity
        var globalMaxY = -CGFloat.infinity

        for screen in screens {
            globalMinX = min(globalMinX, screen.frame.minX)
            globalMaxX = max(globalMaxX, screen.frame.maxX)
            globalMinY = min(globalMinY, screen.frame.minY)
            globalMaxY = max(globalMaxY, screen.frame.maxY)
        }

        let totalWidth = globalMaxX - globalMinX
        let totalHeight = globalMaxY - globalMinY

        switch mode {
        case .secondaryOnly:
            // 只在副屏移动
            // 副屏 = 非主屏幕
            let secondaryScreens = screens.filter { $0 != NSScreen.main }
            if secondaryScreens.isEmpty {
                // 没有副屏时，使用主屏
                return CGRect(x: 0, y: 0, width: totalWidth, height: petHeight)
            }

            // 计算副屏区域（Canvas 坐标系）
            var secMinX = CGFloat.infinity
            var secMaxX = -CGFloat.infinity

            for screen in secondaryScreens {
                secMinX = min(secMinX, screen.frame.minX)
                secMaxX = max(secMaxX, screen.frame.maxX)
            }

            // 转换为 Canvas 坐标系
            let canvasX = secMinX - globalMinX
            let canvasWidth = secMaxX - secMinX

            return CGRect(x: canvasX, y: 0, width: canvasWidth, height: petHeight)

        case .crossScreen:
            // 在所有屏幕顶部移动
            return CGRect(x: 0, y: 0, width: totalWidth, height: petHeight)

        case .freeRoam:
            // 整个窗口区域
            return CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
        }
    }
}
