import SwiftUI

struct BoardGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            let w = s.width, h = s.height
            var board = Path()
            board.move(to: CGPoint(x: w * 0.12, y: h * 0.34))
            board.addLine(to: CGPoint(x: w * 0.78, y: h * 0.20))
            board.addLine(to: CGPoint(x: w * 0.88, y: h * 0.56))
            board.addLine(to: CGPoint(x: w * 0.22, y: h * 0.70))
            board.closeSubpath()
            ctx.stroke(board, with: .color(color), lineWidth: max(1.2, w * 0.06))
            var leg = Path()
            leg.move(to: CGPoint(x: w * 0.5, y: h * 0.62))
            leg.addLine(to: CGPoint(x: w * 0.34, y: h * 0.94))
            leg.move(to: CGPoint(x: w * 0.5, y: h * 0.62))
            leg.addLine(to: CGPoint(x: w * 0.68, y: h * 0.94))
            leg.move(to: CGPoint(x: w * 0.5, y: h * 0.62))
            leg.addLine(to: CGPoint(x: w * 0.54, y: h * 0.92))
            ctx.stroke(leg, with: .color(color), lineWidth: max(1.0, w * 0.045))
        }
        .frame(width: size, height: size)
    }
}

struct RoseGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            let w = s.width, h = s.height
            var star = Path()
            star.move(to: CGPoint(x: w * 0.5, y: h * 0.06))
            star.addLine(to: CGPoint(x: w * 0.58, y: h * 0.42))
            star.addLine(to: CGPoint(x: w * 0.94, y: h * 0.5))
            star.addLine(to: CGPoint(x: w * 0.58, y: h * 0.58))
            star.addLine(to: CGPoint(x: w * 0.5, y: h * 0.94))
            star.addLine(to: CGPoint(x: w * 0.42, y: h * 0.58))
            star.addLine(to: CGPoint(x: w * 0.06, y: h * 0.5))
            star.addLine(to: CGPoint(x: w * 0.42, y: h * 0.42))
            star.closeSubpath()
            ctx.stroke(star, with: .color(color), lineWidth: max(1.1, w * 0.055))
            var north = Path()
            north.move(to: CGPoint(x: w * 0.5, y: h * 0.06))
            north.addLine(to: CGPoint(x: w * 0.58, y: h * 0.42))
            north.addLine(to: CGPoint(x: w * 0.42, y: h * 0.42))
            north.closeSubpath()
            ctx.fill(north, with: .color(color))
        }
        .frame(width: size, height: size)
    }
}

struct ChartGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            let w = s.width, h = s.height
            var sheet = Path()
            sheet.addRect(CGRect(x: w * 0.16, y: h * 0.14, width: w * 0.68, height: h * 0.72))
            ctx.stroke(sheet, with: .color(color), lineWidth: max(1.2, w * 0.06))
            var coast = Path()
            coast.move(to: CGPoint(x: w * 0.18, y: h * 0.62))
            coast.addCurve(to: CGPoint(x: w * 0.82, y: h * 0.44),
                           control1: CGPoint(x: w * 0.38, y: h * 0.40),
                           control2: CGPoint(x: w * 0.56, y: h * 0.76))
            ctx.stroke(coast, with: .color(color), lineWidth: max(1.1, w * 0.05))
            for k in 0..<3 {
                var dot = Path()
                dot.addEllipse(in: CGRect(x: w * (0.28 + Double(k) * 0.18), y: h * 0.72,
                                          width: w * 0.05, height: w * 0.05))
                ctx.fill(dot, with: .color(color.opacity(0.7)))
            }
        }
        .frame(width: size, height: size)
    }
}

struct PenGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            let w = s.width, h = s.height
            var body = Path()
            body.move(to: CGPoint(x: w * 0.16, y: h * 0.84))
            body.addLine(to: CGPoint(x: w * 0.66, y: h * 0.20))
            body.addLine(to: CGPoint(x: w * 0.80, y: h * 0.30))
            body.addLine(to: CGPoint(x: w * 0.30, y: h * 0.94))
            body.closeSubpath()
            ctx.stroke(body, with: .color(color), lineWidth: max(1.2, w * 0.06))
            var nib = Path()
            nib.move(to: CGPoint(x: w * 0.66, y: h * 0.20))
            nib.addLine(to: CGPoint(x: w * 0.74, y: h * 0.06))
            nib.addLine(to: CGPoint(x: w * 0.86, y: h * 0.18))
            nib.addLine(to: CGPoint(x: w * 0.80, y: h * 0.30))
            nib.closeSubpath()
            ctx.fill(nib, with: .color(color))
        }
        .frame(width: size, height: size)
    }
}

struct FolioGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            let w = s.width, h = s.height
            for k in 0..<3 {
                var sheet = Path()
                let off = CGFloat(k) * w * 0.07
                sheet.addRect(CGRect(x: w * 0.14 + off, y: h * 0.16 + off,
                                     width: w * 0.62, height: h * 0.60))
                ctx.stroke(sheet, with: .color(color.opacity(k == 2 ? 1 : 0.5)),
                           lineWidth: max(1.0, w * 0.05))
            }
        }
        .frame(width: size, height: size)
    }
}

struct CrossGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            var p = Path()
            p.move(to: CGPoint(x: s.width * 0.24, y: s.height * 0.24))
            p.addLine(to: CGPoint(x: s.width * 0.76, y: s.height * 0.76))
            p.move(to: CGPoint(x: s.width * 0.76, y: s.height * 0.24))
            p.addLine(to: CGPoint(x: s.width * 0.24, y: s.height * 0.76))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: max(1.4, s.width * 0.10),
                                                                  lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}

struct TickGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            var p = Path()
            p.move(to: CGPoint(x: s.width * 0.20, y: s.height * 0.54))
            p.addLine(to: CGPoint(x: s.width * 0.42, y: s.height * 0.76))
            p.addLine(to: CGPoint(x: s.width * 0.80, y: s.height * 0.26))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: max(1.5, s.width * 0.11),
                                                                  lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

struct AngleGlyph: View {
    var size: CGFloat
    var color: Color
    var facing: Double = 0
    var body: some View {
        Canvas { ctx, s in
            var p = Path()
            p.move(to: CGPoint(x: s.width * 0.36, y: s.height * 0.16))
            p.addLine(to: CGPoint(x: s.width * 0.72, y: s.height * 0.5))
            p.addLine(to: CGPoint(x: s.width * 0.36, y: s.height * 0.84))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: max(1.4, s.width * 0.10),
                                                                  lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
        .rotationEffect(.radians(facing))
    }
}

struct HillGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, s in
            let w = s.width, h = s.height
            var hill = Path()
            hill.move(to: CGPoint(x: w * 0.08, y: h * 0.78))
            hill.addQuadCurve(to: CGPoint(x: w * 0.92, y: h * 0.78),
                              control: CGPoint(x: w * 0.5, y: h * 0.14))
            ctx.stroke(hill, with: .color(color), lineWidth: max(1.2, w * 0.055))
            for k in 0..<7 {
                let t = Double(k) / 6
                let x = w * CGFloat(0.14 + t * 0.72)
                let y = h * CGFloat(0.78 - sin(t * Double.pi) * 0.42)
                var stroke = Path()
                stroke.move(to: CGPoint(x: x, y: y + 3))
                stroke.addLine(to: CGPoint(x: x, y: y + h * 0.16))
                ctx.stroke(stroke, with: .color(color.opacity(0.7)), lineWidth: max(1.0, w * 0.04))
            }
        }
        .frame(width: size, height: size)
    }
}
