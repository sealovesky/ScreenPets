import SwiftUI

/// 幽灵宠物 - 飘来飘去，偶尔变透明
struct GhostPet: Pet {
    let id = "ghost"
    let name = "幽灵"
    let icon = "👻"
    let size = CGSize(width: 60, height: 70)

    var position: CGPoint = .zero
    var direction: CGVector = CGVector(dx: 1, dy: 0)
    var animationPhase: Double = 0

    mutating func update(deltaTime: Double, bounds: CGRect, mode: PetMode) {
        let speed = SettingsManager.shared.petSpeed

        // 更新动画相位
        animationPhase += deltaTime * 5

        // 幽灵有轻微的上下浮动
        let floatOffset = sin(animationPhase) * 0.5

        // 更新位置
        position.x += speed * direction.dx
        position.y += speed * direction.dy + floatOffset

        // 边界检测
        handleBoundary(bounds: bounds, mode: mode)

        // 确保 Y 位置不会因浮动超出边界
        if position.y < bounds.minY {
            position.y = bounds.minY
        } else if position.y + size.height > bounds.maxY {
            position.y = bounds.maxY - size.height
        }
    }

    func draw(context: GraphicsContext) {
        var ctx = context  // 创建可变副本
        let scale = SettingsManager.shared.petScale
        let d = direction.dx >= 0 ? 1.0 : -1.0

        // 透明度波动（偶尔变透明）
        let baseOpacity = 0.85
        let opacityWave = sin(animationPhase * 0.3) * 0.15
        let opacity = baseOpacity + opacityWave

        ctx.scaleBy(x: scale, y: scale)

        let centerX: Double = 30
        let topY: Double = 5

        // 身体主体（圆润的幽灵形状）
        var bodyPath = Path()

        // 头部圆弧
        bodyPath.addArc(
            center: CGPoint(x: centerX, y: topY + 25),
            radius: 25,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )

        // 右侧
        bodyPath.addLine(to: CGPoint(x: centerX + 25, y: topY + 55))

        // 底部波浪
        let wavePhase = animationPhase * 2
        bodyPath.addQuadCurve(
            to: CGPoint(x: centerX + 15, y: topY + 50 + sin(wavePhase) * 5),
            control: CGPoint(x: centerX + 20, y: topY + 60 + sin(wavePhase) * 3)
        )
        bodyPath.addQuadCurve(
            to: CGPoint(x: centerX + 5, y: topY + 55 + sin(wavePhase + 1) * 5),
            control: CGPoint(x: centerX + 10, y: topY + 45 + sin(wavePhase + 0.5) * 3)
        )
        bodyPath.addQuadCurve(
            to: CGPoint(x: centerX - 5, y: topY + 50 + sin(wavePhase + 2) * 5),
            control: CGPoint(x: centerX, y: topY + 60 + sin(wavePhase + 1.5) * 3)
        )
        bodyPath.addQuadCurve(
            to: CGPoint(x: centerX - 15, y: topY + 55 + sin(wavePhase + 3) * 5),
            control: CGPoint(x: centerX - 10, y: topY + 45 + sin(wavePhase + 2.5) * 3)
        )
        bodyPath.addQuadCurve(
            to: CGPoint(x: centerX - 25, y: topY + 50),
            control: CGPoint(x: centerX - 20, y: topY + 60 + sin(wavePhase + 3) * 3)
        )

        // 左侧
        bodyPath.addLine(to: CGPoint(x: centerX - 25, y: topY + 25))
        bodyPath.closeSubpath()

        // 绘制身体（带渐变）
        let gradient = Gradient(colors: [
            Color.white.opacity(opacity),
            Color(white: 0.9).opacity(opacity * 0.9)
        ])

        ctx.fill(
            bodyPath,
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: centerX, y: topY),
                endPoint: CGPoint(x: centerX, y: topY + 60)
            )
        )

        // 眼睛
        let eyeOffsetX = d >= 0 ? 3.0 : -3.0

        // 左眼
        ctx.fill(
            Ellipse().path(in: CGRect(x: centerX - 12 + eyeOffsetX, y: topY + 18, width: 10, height: 14)),
            with: .color(.black.opacity(opacity))
        )
        // 左眼高光
        ctx.fill(
            Circle().path(in: CGRect(x: centerX - 10 + eyeOffsetX, y: topY + 20, width: 4, height: 4)),
            with: .color(.white.opacity(opacity * 0.8))
        )

        // 右眼
        ctx.fill(
            Ellipse().path(in: CGRect(x: centerX + 2 + eyeOffsetX, y: topY + 18, width: 10, height: 14)),
            with: .color(.black.opacity(opacity))
        )
        // 右眼高光
        ctx.fill(
            Circle().path(in: CGRect(x: centerX + 4 + eyeOffsetX, y: topY + 20, width: 4, height: 4)),
            with: .color(.white.opacity(opacity * 0.8))
        )

        // 嘴巴（可爱的 O 形）
        let mouthOpen = (sin(animationPhase * 0.8) + 1) / 2 * 4 + 2
        ctx.fill(
            Ellipse().path(in: CGRect(x: centerX - 4 + eyeOffsetX, y: topY + 35, width: 8, height: mouthOpen)),
            with: .color(.black.opacity(opacity * 0.6))
        )

        // 腮红
        ctx.fill(
            Ellipse().path(in: CGRect(x: centerX - 20, y: topY + 30, width: 8, height: 5)),
            with: .color(Color.pink.opacity(opacity * 0.4))
        )
        ctx.fill(
            Ellipse().path(in: CGRect(x: centerX + 12, y: topY + 30, width: 8, height: 5)),
            with: .color(Color.pink.opacity(opacity * 0.4))
        )

        // 发光效果（周围的小光点）
        let sparklePhase = animationPhase * 1.5
        let sparklePositions: [(Double, Double, Double)] = [
            (-30, 10, 0),
            (30, 15, 1),
            (-25, 45, 2),
            (28, 50, 3),
            (0, -5, 4),
        ]

        for (sx, sy, offset) in sparklePositions {
            let sparkleOpacity = (sin(sparklePhase + offset) + 1) / 2 * 0.6
            let sparkleSize = 3 + sin(sparklePhase + offset) * 1

            ctx.fill(
                Circle().path(in: CGRect(
                    x: centerX + sx - sparkleSize / 2,
                    y: topY + sy - sparkleSize / 2,
                    width: sparkleSize,
                    height: sparkleSize
                )),
                with: .color(.white.opacity(sparkleOpacity))
            )
        }
    }
}
