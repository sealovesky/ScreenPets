import SwiftUI

/// 彩虹猫宠物 - Nyan Cat 风格
struct NyanCatPet: Pet {
    let id = "nyancat"
    let name = "彩虹猫"
    let icon = "🌈"
    let size = CGSize(width: 150, height: 40)

    var position: CGPoint = .zero
    var direction: CGVector = CGVector(dx: 1, dy: 0)
    var animationPhase: Double = 0

    // 彩虹颜色
    private let rainbowColors: [Color] = [
        Color(red: 1, green: 0, blue: 0),      // 红
        Color(red: 1, green: 0.5, blue: 0),    // 橙
        Color(red: 1, green: 1, blue: 0),      // 黄
        Color(red: 0, green: 1, blue: 0),      // 绿
        Color(red: 0, green: 0.5, blue: 1),    // 蓝
        Color(red: 0.5, green: 0, blue: 1),    // 紫
    ]

    mutating func update(deltaTime: Double, bounds: CGRect, mode: PetMode) {
        let speed = SettingsManager.shared.petSpeed

        // 更新动画相位
        animationPhase += deltaTime * 8

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

        ctx.scaleBy(x: scale, y: scale)

        let catX: Double = d >= 0 ? 80 : 30
        let catY: Double = 12

        // 绘制彩虹尾巴
        let rainbowStartX = d >= 0 ? 0 : catX + 40
        let rainbowEndX = d >= 0 ? catX - 5 : 150

        for (index, color) in rainbowColors.enumerated() {
            let yOffset = Double(index) * 5 + 5
            let waveOffset = sin(animationPhase + Double(index) * 0.5) * 2

            var rainbowPath = Path()
            if d >= 0 {
                rainbowPath.move(to: CGPoint(x: rainbowStartX, y: yOffset + waveOffset))
                rainbowPath.addLine(to: CGPoint(x: rainbowEndX, y: yOffset + waveOffset))
            } else {
                rainbowPath.move(to: CGPoint(x: rainbowStartX, y: yOffset + waveOffset))
                rainbowPath.addLine(to: CGPoint(x: rainbowEndX, y: yOffset + waveOffset))
            }
            ctx.stroke(rainbowPath, with: .color(color.opacity(0.9)), lineWidth: 4)
        }

        // 猫身体（草莓蛋糕色）
        let bodyRect = CGRect(x: catX, y: catY, width: 35, height: 22)
        ctx.fill(
            RoundedRectangle(cornerRadius: 4).path(in: bodyRect),
            with: .color(Color(red: 1, green: 0.7, blue: 0.8))
        )

        // 猫身体上的点点（草莓）
        let dotPositions: [(Double, Double)] = [(8, 6), (18, 4), (28, 8), (12, 14), (22, 16)]
        for (dx, dy) in dotPositions {
            ctx.fill(
                Circle().path(in: CGRect(x: catX + dx, y: catY + dy, width: 3, height: 3)),
                with: .color(Color(red: 1, green: 0.3, blue: 0.5))
            )
        }

        // 猫头
        let headX = d >= 0 ? catX + 28 : catX - 5
        ctx.fill(
            Ellipse().path(in: CGRect(x: headX, y: catY - 2, width: 18, height: 16)),
            with: .color(Color(red: 0.6, green: 0.6, blue: 0.6))
        )

        // 猫耳朵
        let earOffset = d >= 0 ? 0.0 : 10.0
        var ear1 = Path()
        ear1.move(to: CGPoint(x: headX + 2 + earOffset, y: catY))
        ear1.addLine(to: CGPoint(x: headX + earOffset, y: catY - 8))
        ear1.addLine(to: CGPoint(x: headX + 6 + earOffset, y: catY))
        ctx.fill(ear1, with: .color(Color(red: 0.6, green: 0.6, blue: 0.6)))

        var ear2 = Path()
        ear2.move(to: CGPoint(x: headX + 10 - earOffset, y: catY))
        ear2.addLine(to: CGPoint(x: headX + 14 - earOffset, y: catY - 8))
        ear2.addLine(to: CGPoint(x: headX + 16 - earOffset, y: catY))
        ctx.fill(ear2, with: .color(Color(red: 0.6, green: 0.6, blue: 0.6)))

        // 猫眼睛
        let eyeY = catY + 4
        let blinkPhase = sin(animationPhase * 0.5)
        let eyeHeight = blinkPhase > 0.9 ? 1.0 : 4.0

        ctx.fill(
            Ellipse().path(in: CGRect(x: headX + 4, y: eyeY, width: 4, height: eyeHeight)),
            with: .color(.black)
        )
        ctx.fill(
            Ellipse().path(in: CGRect(x: headX + 10, y: eyeY, width: 4, height: eyeHeight)),
            with: .color(.black)
        )

        // 猫嘴巴
        ctx.fill(
            Ellipse().path(in: CGRect(x: headX + 6, y: catY + 9, width: 6, height: 4)),
            with: .color(Color(red: 1, green: 0.5, blue: 0.6))
        )

        // 腿（跑动动画）
        let legPhase = sin(animationPhase * 2)
        let legY = catY + 20

        // 前腿
        let frontLegX = d >= 0 ? catX + 25 : catX + 5
        ctx.fill(
            RoundedRectangle(cornerRadius: 1).path(in: CGRect(x: frontLegX, y: legY + legPhase * 3, width: 4, height: 8)),
            with: .color(Color(red: 0.6, green: 0.6, blue: 0.6))
        )
        ctx.fill(
            RoundedRectangle(cornerRadius: 1).path(in: CGRect(x: frontLegX + 6, y: legY - legPhase * 3, width: 4, height: 8)),
            with: .color(Color(red: 0.6, green: 0.6, blue: 0.6))
        )

        // 后腿
        let backLegX = d >= 0 ? catX + 5 : catX + 25
        ctx.fill(
            RoundedRectangle(cornerRadius: 1).path(in: CGRect(x: backLegX, y: legY - legPhase * 3, width: 4, height: 8)),
            with: .color(Color(red: 0.6, green: 0.6, blue: 0.6))
        )
        ctx.fill(
            RoundedRectangle(cornerRadius: 1).path(in: CGRect(x: backLegX + 6, y: legY + legPhase * 3, width: 4, height: 8)),
            with: .color(Color(red: 0.6, green: 0.6, blue: 0.6))
        )

        // 星星特效
        let starPositions: [(Double, Double)] = [
            (d >= 0 ? -10 : 140, 10 + sin(animationPhase) * 5),
            (d >= 0 ? -20 : 155, 25 + cos(animationPhase * 1.3) * 5),
            (d >= 0 ? -5 : 145, 35 + sin(animationPhase * 0.8) * 5),
        ]

        for (sx, sy) in starPositions {
            drawStar(context: &ctx, at: CGPoint(x: sx, y: sy), size: 6, phase: animationPhase)
        }
    }

    private func drawStar(context: inout GraphicsContext, at point: CGPoint, size: Double, phase: Double) {
        let opacity = (sin(phase * 2) + 1) / 2 * 0.5 + 0.5

        var star = Path()
        for i in 0..<5 {
            let angle = Double(i) * .pi * 2 / 5 - .pi / 2
            let x = point.x + cos(angle) * size
            let y = point.y + sin(angle) * size
            if i == 0 {
                star.move(to: CGPoint(x: x, y: y))
            } else {
                star.addLine(to: CGPoint(x: x, y: y))
            }

            let innerAngle = angle + .pi / 5
            let innerX = point.x + cos(innerAngle) * size * 0.4
            let innerY = point.y + sin(innerAngle) * size * 0.4
            star.addLine(to: CGPoint(x: innerX, y: innerY))
        }
        star.closeSubpath()

        context.fill(star, with: .color(.yellow.opacity(opacity)))
    }
}
