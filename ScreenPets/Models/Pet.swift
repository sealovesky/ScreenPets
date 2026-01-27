import SwiftUI

/// 宠物移动模式
enum PetMode: String, CaseIterable, Identifiable {
    case secondaryOnly = "副屏"
    case crossScreen = "跨屏"
    case freeRoam = "自由飞"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .secondaryOnly: return "只在副屏活动"
        case .crossScreen: return "在主屏和副屏之间移动"
        case .freeRoam: return "全屏自由移动"
        }
    }
}

/// 宠物协议 - 所有宠物必须实现
protocol Pet: Identifiable {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var size: CGSize { get }

    /// 当前位置
    var position: CGPoint { get set }

    /// 移动方向
    var direction: CGVector { get set }

    /// 动画状态
    var animationPhase: Double { get set }

    /// 更新宠物状态
    mutating func update(deltaTime: Double, bounds: CGRect, mode: PetMode)

    /// 绘制宠物
    func draw(context: GraphicsContext)
}

/// 宠物基础实现
extension Pet {
    /// 计算缩放后的实际尺寸
    var scaledSize: CGSize {
        let scale = SettingsManager.shared.petScale
        return CGSize(width: size.width * scale, height: size.height * scale)
    }

    /// 默认边界检测和反弹逻辑
    mutating func handleBoundary(bounds: CGRect, mode: PetMode) {
        let actualSize = scaledSize

        // 水平边界
        if direction.dx > 0 && position.x + actualSize.width > bounds.maxX {
            direction.dx = -abs(direction.dx)
            position.x = bounds.maxX - actualSize.width  // 确保不越界
            if mode == .freeRoam {
                direction.dy = Double.random(in: -1...1)
            }
        } else if direction.dx < 0 && position.x < bounds.minX {
            direction.dx = abs(direction.dx)
            position.x = bounds.minX  // 确保不越界
            if mode == .freeRoam {
                direction.dy = Double.random(in: -1...1)
            }
        }

        // 垂直边界（仅自由模式）
        if mode == .freeRoam {
            if position.y < bounds.minY {
                position.y = bounds.minY
                direction.dy = abs(direction.dy)
            } else if position.y + actualSize.height > bounds.maxY {
                position.y = bounds.maxY - actualSize.height
                direction.dy = -abs(direction.dy)
            }
        }
    }
}

/// 宠物类型枚举
enum PetType: String, CaseIterable, Identifiable {
    case dragon = "飞龙"
    case nyanCat = "彩虹猫"
    case ghost = "幽灵"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dragon: return "🐉"
        case .nyanCat: return "🌈"
        case .ghost: return "👻"
        }
    }

    func createPet() -> any Pet {
        switch self {
        case .dragon: return DragonPet()
        case .nyanCat: return NyanCatPet()
        case .ghost: return GhostPet()
        }
    }
}
