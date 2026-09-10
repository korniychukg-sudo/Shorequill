import SwiftUI

struct DeskHue {
    var wall: Color
    var window: Color
    var lightPool: Double
    var lamp: Double
    var label: String
}

enum DeskLight {
    static let keys: [(Int, DeskHue)] = [
        (0, DeskHue(wall: Color(red: 0.098, green: 0.129, blue: 0.114),
                    window: Color(red: 0.129, green: 0.157, blue: 0.196),
                    lightPool: 0.06, lamp: 1.0, label: "Late, and the lamp is lit")),
        (6, DeskHue(wall: Color(red: 0.176, green: 0.216, blue: 0.196),
                    window: Color(red: 0.478, green: 0.451, blue: 0.435),
                    lightPool: 0.24, lamp: 0.7, label: "Early, the office cold")),
        (9, DeskHue(wall: Color(red: 0.239, green: 0.302, blue: 0.263),
                    window: Color(red: 0.792, green: 0.812, blue: 0.808),
                    lightPool: 0.70, lamp: 0.15, label: "Morning, the best light for inking")),
        (13, DeskHue(wall: Color(red: 0.271, green: 0.341, blue: 0.290),
                     window: Color(red: 0.898, green: 0.902, blue: 0.878),
                     lightPool: 0.92, lamp: 0, label: "Midday, flat and even")),
        (17, DeskHue(wall: Color(red: 0.259, green: 0.294, blue: 0.243),
                     window: Color(red: 0.878, green: 0.769, blue: 0.612),
                     lightPool: 0.62, lamp: 0.1, label: "Afternoon, long shadows on the board")),
        (20, DeskHue(wall: Color(red: 0.161, green: 0.196, blue: 0.176),
                     window: Color(red: 0.529, green: 0.435, blue: 0.404),
                     lightPool: 0.20, lamp: 0.75, label: "Dusk, and the lamp brought in")),
        (24, DeskHue(wall: Color(red: 0.098, green: 0.129, blue: 0.114),
                     window: Color(red: 0.129, green: 0.157, blue: 0.196),
                     lightPool: 0.06, lamp: 1.0, label: "Late, and the lamp is lit")),
    ]

    static func mix(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let ua = UIColor(a), ub = UIColor(b)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ua.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ub.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let f = CGFloat(max(0, min(1, t)))
        return Color(red: Double(r1 + (r2 - r1) * f), green: Double(g1 + (g2 - g1) * f),
                     blue: Double(b1 + (b2 - b1) * f))
    }

    static func hue(for hour: Double) -> DeskHue {
        var lower = keys[0], upper = keys[keys.count - 1]
        for i in 0..<(keys.count - 1) {
            if hour >= Double(keys[i].0) && hour <= Double(keys[i + 1].0) {
                lower = keys[i]; upper = keys[i + 1]
                break
            }
        }
        let span = max(0.001, Double(upper.0 - lower.0))
        let t = max(0, min(1, (hour - Double(lower.0)) / span))
        return DeskHue(wall: mix(lower.1.wall, upper.1.wall, t),
                       window: mix(lower.1.window, upper.1.window, t),
                       lightPool: lower.1.lightPool + (upper.1.lightPool - lower.1.lightPool) * t,
                       lamp: lower.1.lamp + (upper.1.lamp - lower.1.lamp) * t,
                       label: t < 0.5 ? lower.1.label : upper.1.label)
    }

    static var nowHour: Double {
        let c = Calendar.current.dateComponents([.hour, .minute], from: Date())
        return Double(c.hour ?? 12) + Double(c.minute ?? 0) / 60
    }
}

struct OfficeScene: View {
    let ground: Ground
    var height: CGFloat = 220

    var body: some View {
        let hue = DeskLight.hue(for: DeskLight.nowHour)
        TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
            Canvas { ctx, size in
                draw(&ctx, size, hue: hue, time: timeline.date.timeIntervalSinceReferenceDate)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(Ink.hairlineLight, lineWidth: 1))
    }

    private func draw(_ ctx: inout GraphicsContext, _ size: CGSize, hue: DeskHue, time: Double) {
        let w = size.width, h = size.height
        var wall = Path()
        wall.addRect(CGRect(origin: .zero, size: size))
        ctx.fill(wall, with: .color(hue.wall))

        var window = Path()
        window.addRect(CGRect(x: w * 0.06, y: h * 0.06, width: w * 0.30, height: h * 0.46))
        ctx.fill(window, with: .color(hue.window))
        var bars = Path()
        bars.move(to: CGPoint(x: w * 0.21, y: h * 0.06))
        bars.addLine(to: CGPoint(x: w * 0.21, y: h * 0.52))
        bars.move(to: CGPoint(x: w * 0.06, y: h * 0.28))
        bars.addLine(to: CGPoint(x: w * 0.36, y: h * 0.28))
        ctx.stroke(bars, with: .color(Ink.baizeDeep), lineWidth: 4)
        ctx.stroke(window, with: .color(Ink.baizeDeep), lineWidth: 5)

        var pool = Path()
        pool.move(to: CGPoint(x: w * 0.08, y: h * 0.52))
        pool.addLine(to: CGPoint(x: w * 0.36, y: h * 0.52))
        pool.addLine(to: CGPoint(x: w * 0.72, y: h))
        pool.addLine(to: CGPoint(x: w * 0.16, y: h))
        pool.closeSubpath()
        ctx.fill(pool, with: .linearGradient(
            Gradient(colors: [Color.white.opacity(0.24 * hue.lightPool), Color.clear]),
            startPoint: CGPoint(x: w * 0.2, y: h * 0.5), endPoint: CGPoint(x: w * 0.5, y: h)))

        var desk = Path()
        desk.addRect(CGRect(x: 0, y: h * 0.58, width: w, height: h * 0.42))
        ctx.fill(desk, with: .color(Ink.baize))
        var rng = Draw(5501)
        for _ in 0..<420 {
            let x = CGFloat(rng.unit()) * w
            let y = h * 0.58 + CGFloat(rng.unit()) * h * 0.42
            var fleck = Path()
            fleck.addEllipse(in: CGRect(x: x, y: y, width: 1.6, height: 1.6))
            ctx.fill(fleck, with: .color(Color.black.opacity(rng.range(0.05, 0.20))))
        }

        var board = Path()
        board.move(to: CGPoint(x: w * 0.18, y: h * 0.66))
        board.addLine(to: CGPoint(x: w * 0.86, y: h * 0.62))
        board.addLine(to: CGPoint(x: w * 0.92, y: h * 0.98))
        board.addLine(to: CGPoint(x: w * 0.22, y: h * 1.02))
        board.closeSubpath()
        ctx.fill(board, with: .color(Ink.paper))
        ctx.stroke(board, with: .color(Ink.paperSunk), lineWidth: 2)

        let coast = ground.coast
        var line = Path()
        var started = false
        for p in coast {
            let x = w * (0.20 + p.x * 0.68)
            let y = h * (0.66 + p.y * 0.32)
            let pt = CGPoint(x: x, y: y)
            if !started { line.move(to: pt); started = true } else { line.addLine(to: pt) }
        }
        line.closeSubpath()
        ctx.stroke(line, with: .color(Ink.line.opacity(0.75)), lineWidth: 1.6)

        for (c, r) in ground.hills {
            for ring in 0..<2 {
                let inner = 0.42 + Double(ring) * 0.30
                let outer = inner + 0.26
                for k in 0..<(12 + ring * 6) {
                    let a = Double(k) / Double(12 + ring * 6) * 2 * Double.pi
                    let x0 = w * (0.20 + (c.x + CGFloat(cos(a)) * CGFloat(r * inner)) * 0.68)
                    let y0 = h * (0.66 + (c.y + CGFloat(sin(a)) * CGFloat(r * inner)) * 0.32)
                    let x1 = w * (0.20 + (c.x + CGFloat(cos(a)) * CGFloat(r * outer)) * 0.68)
                    let y1 = h * (0.66 + (c.y + CGFloat(sin(a)) * CGFloat(r * outer)) * 0.32)
                    var stroke = Path()
                    stroke.move(to: CGPoint(x: x0, y: y0))
                    stroke.addLine(to: CGPoint(x: x1, y: y1))
                    ctx.stroke(stroke, with: .color(Ink.line.opacity(0.34)), lineWidth: 0.9)
                }
            }
        }

        var rule = Path()
        rule.move(to: CGPoint(x: w * 0.30, y: h * 0.90))
        rule.addLine(to: CGPoint(x: w * 0.82, y: h * 0.76))
        ctx.stroke(rule, with: .color(Ink.brass), lineWidth: 9)
        ctx.stroke(rule, with: .color(Ink.brassDark.opacity(0.7)), lineWidth: 2)

        var pen = Path()
        pen.move(to: CGPoint(x: w * 0.66, y: h * 0.96))
        pen.addLine(to: CGPoint(x: w * 0.86, y: h * 0.86))
        ctx.stroke(pen, with: .color(Ink.sepia), lineWidth: 5)
        var nib = Path()
        nib.addEllipse(in: CGRect(x: w * 0.855, y: h * 0.845, width: 7, height: 7))
        ctx.fill(nib, with: .color(Ink.line))

        if hue.lamp > 0.05 {
            var glow = Path()
            glow.addEllipse(in: CGRect(x: w * 0.72, y: h * 0.30, width: w * 0.5, height: h * 0.7))
            ctx.fill(glow, with: .radialGradient(
                Gradient(colors: [Color(red: 0.98, green: 0.88, blue: 0.66).opacity(0.30 * hue.lamp),
                                  Color.clear]),
                center: CGPoint(x: w * 0.92, y: h * 0.5), startRadius: 0, endRadius: w * 0.4))
            var shade = Path()
            shade.move(to: CGPoint(x: w * 0.84, y: h * 0.40))
            shade.addLine(to: CGPoint(x: w * 1.02, y: h * 0.40))
            shade.addLine(to: CGPoint(x: w * 0.98, y: h * 0.30))
            shade.addLine(to: CGPoint(x: w * 0.88, y: h * 0.30))
            shade.closeSubpath()
            ctx.fill(shade, with: .color(Ink.oxblood.opacity(0.85)))
        }

        let drift = time.truncatingRemainder(dividingBy: 24) / 24
        var motes = Draw(7717)
        for _ in 0..<26 {
            let mx = motes.unit()
            let my = motes.unit()
            let yy = (my + drift * (0.4 + motes.unit())).truncatingRemainder(dividingBy: 1)
            let px = w * CGFloat(0.08 + mx * 0.5) + CGFloat(yy) * w * 0.08
            let py = h * CGFloat(0.5 + yy * 0.48)
            var dot = Path()
            dot.addEllipse(in: CGRect(x: px, y: py, width: 2, height: 2))
            ctx.fill(dot, with: .color(Color.white.opacity(0.34 * hue.lightPool)))
        }
    }
}
