import SwiftUI

/// 飞龙宠物 - 从 Hammerspoon 移植
struct DragonPet: Pet {
    let id = "dragon"
    let name = "飞龙"
    let icon = "🐉"
    let size = CGSize(width: 120, height: 30)

    var position: CGPoint = .zero
    var direction: CGVector = CGVector(dx: 1, dy: 0)
    var animationPhase: Double = 0

    mutating func update(deltaTime: Double, bounds: CGRect, mode: PetMode) {
        let speed = SettingsManager.shared.petSpeed

        // 更新动画相位
        animationPhase += deltaTime * 10

        // 更新位置
        position.x += speed * direction.dx
        position.y += speed * direction.dy

        // 边界检测
        handleBoundary(bounds: bounds, mode: mode)
    }

    func draw(context: GraphicsContext) {
        var ctx = context  // 创建可变副本
        let scale = SettingsManager.shared.petScale
        let d = direction.dx >= 0 ? 1.0 : -1.0
        let baseX: Double = 25
        let cy: Double = 15

        // 波浪动画
        let wave1 = sin(animationPhase) * 4
        let wave2 = sin(animationPhase + 1) * 4
        let wave3 = sin(animationPhase + 2) * 4
        let wave4 = sin(animationPhase + 3) * 4

        ctx.scaleBy(x: scale, y: scale)

        if d >= 0 {
            // 向右飞 - 尾巴在左，头在右

            // 尾巴火焰
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: baseX, y: cy + wave1))
            tailPath.addLine(to: CGPoint(x: baseX - 12, y: cy - 6 + wave1))
            tailPath.addLine(to: CGPoint(x: baseX - 20, y: cy + 4 + wave1))
            ctx.stroke(tailPath, with: .color(Color(red: 0.8, green: 0.2, blue: 0, opacity: 0.9)), lineWidth: 2)

            // 身体
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: baseX, y: cy + wave1))
            bodyPath.addLine(to: CGPoint(x: baseX + 12, y: cy - 6 + wave2))
            bodyPath.addLine(to: CGPoint(x: baseX + 24, y: cy + 4 + wave3))
            bodyPath.addLine(to: CGPoint(x: baseX + 36, y: cy - 6 + wave4))
            bodyPath.addLine(to: CGPoint(x: baseX + 48, y: cy + wave1))
            ctx.stroke(bodyPath, with: .color(Color(red: 1, green: 0.3, blue: 0, opacity: 0.9)), lineWidth: 4)

            // 头部
            ctx.fill(
                Circle().path(in: CGRect(x: baseX + 48, y: cy - 8, width: 16, height: 16)),
                with: .color(Color(red: 1, green: 0.2, blue: 0, opacity: 0.9))
            )

            // 眼睛
            ctx.fill(
                Circle().path(in: CGRect(x: baseX + 58, y: cy - 4, width: 4, height: 4)),
                with: .color(.yellow)
            )

            // 龙角
            var horn1 = Path()
            horn1.move(to: CGPoint(x: baseX + 52, y: cy - 4))
            horn1.addLine(to: CGPoint(x: baseX + 50, y: cy - 12))
            ctx.stroke(horn1, with: .color(Color(red: 1, green: 0.5, blue: 0, opacity: 0.9)), lineWidth: 2)

            var horn2 = Path()
            horn2.move(to: CGPoint(x: baseX + 56, y: cy - 6))
            horn2.addLine(to: CGPoint(x: baseX + 55, y: cy - 13))
            ctx.stroke(horn2, with: .color(Color(red: 1, green: 0.5, blue: 0, opacity: 0.9)), lineWidth: 2)

            // 火焰喷射
            var firePath = Path()
            firePath.move(to: CGPoint(x: baseX + 64, y: cy))
            firePath.addLine(to: CGPoint(x: baseX + 74 + wave2, y: cy - 2))
            firePath.addLine(to: CGPoint(x: baseX + 70 + wave3, y: cy + 2))
            firePath.addLine(to: CGPoint(x: baseX + 82 + wave4, y: cy))
            ctx.stroke(firePath, with: .color(Color(red: 1, green: 0.8, blue: 0, opacity: 0.8)), lineWidth: 3)

        } else {
            // 向左飞 - 头在左，尾巴在右

            // 尾巴火焰
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: baseX + 60, y: cy + wave1))
            tailPath.addLine(to: CGPoint(x: baseX + 72, y: cy - 6 + wave1))
            tailPath.addLine(to: CGPoint(x: baseX + 80, y: cy + 4 + wave1))
            ctx.stroke(tailPath, with: .color(Color(red: 0.8, green: 0.2, blue: 0, opacity: 0.9)), lineWidth: 2)

            // 身体
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: baseX + 60, y: cy + wave1))
            bodyPath.addLine(to: CGPoint(x: baseX + 48, y: cy - 6 + wave2))
            bodyPath.addLine(to: CGPoint(x: baseX + 36, y: cy + 4 + wave3))
            bodyPath.addLine(to: CGPoint(x: baseX + 24, y: cy - 6 + wave4))
            bodyPath.addLine(to: CGPoint(x: baseX + 12, y: cy + wave1))
            ctx.stroke(bodyPath, with: .color(Color(red: 1, green: 0.3, blue: 0, opacity: 0.9)), lineWidth: 4)

            // 头部
            ctx.fill(
                Circle().path(in: CGRect(x: baseX - 4, y: cy - 8, width: 16, height: 16)),
                with: .color(Color(red: 1, green: 0.2, blue: 0, opacity: 0.9))
            )

            // 眼睛
            ctx.fill(
                Circle().path(in: CGRect(x: baseX - 2, y: cy - 4, width: 4, height: 4)),
                with: .color(.yellow)
            )

            // 龙角
            var horn1 = Path()
            horn1.move(to: CGPoint(x: baseX + 8, y: cy - 4))
            horn1.addLine(to: CGPoint(x: baseX + 10, y: cy - 12))
            ctx.stroke(horn1, with: .color(Color(red: 1, green: 0.5, blue: 0, opacity: 0.9)), lineWidth: 2)

            var horn2 = Path()
            horn2.move(to: CGPoint(x: baseX + 4, y: cy - 6))
            horn2.addLine(to: CGPoint(x: baseX + 5, y: cy - 13))
            ctx.stroke(horn2, with: .color(Color(red: 1, green: 0.5, blue: 0, opacity: 0.9)), lineWidth: 2)

            // 火焰喷射
            var firePath = Path()
            firePath.move(to: CGPoint(x: baseX - 4, y: cy))
            firePath.addLine(to: CGPoint(x: baseX - 14 - wave2, y: cy - 2))
            firePath.addLine(to: CGPoint(x: baseX - 10 - wave3, y: cy + 2))
            firePath.addLine(to: CGPoint(x: baseX - 22 - wave4, y: cy))
            ctx.stroke(firePath, with: .color(Color(red: 1, green: 0.8, blue: 0, opacity: 0.8)), lineWidth: 3)
        }
    }
}
