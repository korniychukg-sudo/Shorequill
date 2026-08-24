import Foundation
import CoreGraphics

func makeIcon(dir: String) {
    let p = Sheet(1024, 1024)
    p.fillAll(Field.baizeDark)
    p.topDown()
    var rng = Dice(70207)

    if let g = CGGradient(colorsSpace: rgbSpace,
                          colors: [cg(Field.baize.lt(0.10)), cg(Field.baizeDark.dk(0.30))] as CFArray,
                          locations: [0, 1]) {
        p.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 300, y: 250), startRadius: 0,
                                 endCenter: CGPoint(x: 300, y: 250), endRadius: 1180,
                                 options: [.drawsAfterEndLocation])
    }
    for _ in 0..<4000 {
        p.disc(rng.d() * 1024, rng.d() * 1024, rng.r(0.5, 2.0),
               (rng.chance(0.5) ? Field.baize.lt(0.16) : Field.night).al(rng.r(0.03, 0.10)))
    }

    let sheet: [CGPoint] = [pnt(-40, 210), pnt(880, 96), pnt(1010, 900), pnt(96, 1050)]
    for k in 0..<6 {
        let f = Double(k) * 8.0
        p.poly(sheet.map { pnt(Double($0.x) + 22 + f, Double($0.y) + 30 + f) }, Field.night.al(0.10))
    }
    p.poly(sheet, Field.cartridge)
    p.clip(pathOf(sheet)) {
        var rs = Dice(4409)
        for _ in 0..<900 {
            let x = rs.d() * 1024, y = rs.d() * 1024
            pen(p, [pnt(x, y), pnt(x + rs.r(-16, 16), y + rs.r(-6, 6))], weight: rs.r(0.5, 1.6),
                colour: (rs.chance(0.5) ? Field.sepia : Field.bone).al(rs.r(0.05, 0.18)),
                wobble: 0.5, taper: true, seed: bits(Int(x)))
        }
        var coast: [CGPoint] = []
        var t = 0.0
        while t <= 1.0 {
            coast.append(pnt(40 + t * 1000, 620 + sin(t * 5.4) * 150 + cos(t * 11) * 40))
            t += 0.02
        }
        for i in 0..<coast.count - 1 {
            pen(p, [coast[i], coast[i + 1]], weight: 3.0, colour: Field.ink.al(0.72),
                wobble: 0.6, taper: false, seed: bits(i))
        }
        for i in stride(from: 0, to: coast.count - 1, by: 3) {
            pen(p, [coast[i], pnt(Double(coast[i].x) + 6, Double(coast[i].y) + 16)],
                weight: 1.4, colour: Field.inkSoft.al(0.5), wobble: 0.3, taper: true,
                seed: bits(i &+ 900))
        }
        for k in 0..<26 {
            let sx = 60.0 + Double(k % 7) * 150
            let sy = 800.0 + Double(k / 7) * 60
            caption(p, "\(rng.i(3, 18))", at: sx, sy, size: 24, colour: Field.inkSoft.al(0.6),
                    face: "Georgia-Italic", align: .centre)
        }
        for k in 0..<3 {
            pen(p, [pnt(120, 300 + Double(k) * 40), pnt(980, 120 + Double(k) * 130)],
                weight: 1.4, colour: Field.carmine.al(0.34), wobble: 0.3, taper: false,
                seed: bits(k &+ 40))
        }
    }
    penContour(p, sheet, weight: 3.0, colour: Field.sepia.dk(0.2), seed: 5501)

    let ax0 = 30.0, ay0 = 700.0
    let ax1 = 1090.0, ay1 = 250.0
    let dx = ax1 - ax0, dy = ay1 - ay0
    let len = (dx * dx + dy * dy).squareRoot()
    let nx = -dy / len, ny = dx / len
    let halfW = 80.0
    let thick = 40.0

    let top: [CGPoint] = [pnt(ax0 + nx * halfW, ay0 + ny * halfW),
                          pnt(ax1 + nx * halfW, ay1 + ny * halfW),
                          pnt(ax1 - nx * halfW, ay1 - ny * halfW),
                          pnt(ax0 - nx * halfW, ay0 - ny * halfW)]

    let sideLow: [CGPoint] = [top[3], top[2],
                              pnt(Double(top[2].x) + 14, Double(top[2].y) + thick),
                              pnt(Double(top[3].x) + 14, Double(top[3].y) + thick)]
    p.poly(sideLow, Field.brassDark.dk(0.34))
    penContour(p, sideLow, weight: 2.6, colour: Field.night.al(0.8), seed: 6601)

    p.poly(top, Field.brass)
    p.clip(pathOf(top)) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.brass.lt(0.48)), cg(Field.brass),
                                       cg(Field.brassDark.dk(0.22))] as CFArray,
                              locations: [0, 0.42, 1]) {
            p.ctx.drawLinearGradient(g, start: CGPoint(x: ax0 + nx * halfW, y: ay0 + ny * halfW),
                                     end: CGPoint(x: ax0 - nx * halfW, y: ay0 - ny * halfW),
                                     options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
        var rb = Dice(7717)
        for _ in 0..<700 {
            let t = rb.d()
            let s = rb.r(-halfW, halfW)
            let x = ax0 + dx * t + nx * s
            let y = ay0 + dy * t + ny * s
            pen(p, [pnt(x, y), pnt(x + dx / len * rb.r(8, 40), y + dy / len * rb.r(8, 40))],
                weight: rb.r(0.6, 2.0),
                colour: (rb.chance(0.5) ? Field.brass.lt(0.30) : Field.brassDark.dk(0.2)).al(rb.r(0.10, 0.34)),
                wobble: 0.3, taper: true, seed: bits(Int(x)))
        }
        var t = 0.02
        var k = 0
        while t < 1.0 {
            let long = k % 5 == 0
            let x = ax0 + dx * t
            let y = ay0 + dy * t
            pen(p, [pnt(x - nx * halfW * 0.98, y - ny * halfW * 0.98),
                    pnt(x - nx * halfW * (long ? 0.55 : 0.74), y - ny * halfW * (long ? 0.55 : 0.74))],
                weight: long ? 3.0 : 1.8, colour: Field.night.al(0.62), wobble: 0.2, taper: false,
                seed: bits(k))
            t += 0.022
            k += 1
        }
    }

    for (i, tv) in [0.13, 0.86].enumerated() {
        let bx = ax0 + dx * tv
        let by = ay0 + dy * tv
        let vaneH = 250.0
        let vane: [CGPoint] = [pnt(bx + nx * 30, by + ny * 30),
                               pnt(bx - nx * 30, by - ny * 30),
                               pnt(bx - nx * 30 + 14, by - ny * 30 - vaneH),
                               pnt(bx + nx * 30 + 14, by + ny * 30 - vaneH)]
        p.poly(vane, Field.brassDark)
        p.clip(pathOf(vane)) {
            if let g = CGGradient(colorsSpace: rgbSpace,
                                  colors: [cg(Field.brass.lt(0.34)), cg(Field.brassDark.dk(0.30))] as CFArray,
                                  locations: [0, 1]) {
                p.ctx.drawLinearGradient(g, start: CGPoint(x: bx - 30, y: by - vaneH),
                                         end: CGPoint(x: bx + 40, y: by), options: [])
            }
        }
        penContour(p, vane, weight: 3.0, colour: Field.night.al(0.85), seed: bits(i * 31))
        pen(p, [pnt(bx + 6, by - vaneH * 0.14), pnt(bx + 12, by - vaneH * 0.92)],
            weight: 4.0, colour: Field.night.al(0.7), wobble: 0.2, taper: false, seed: bits(i * 37))
        pen(p, [pnt(bx + nx * 30, by + ny * 30), pnt(bx + nx * 30 + 14, by + ny * 30 - vaneH)],
            weight: 5.0, colour: Field.bone.lt(0.2).al(0.60), wobble: 0.2, taper: false,
            seed: bits(i * 41))
    }

    var litRuns: [[Int]] = []
    var current: [Int] = []
    for i in 0..<top.count {
        let p0 = top[i], p1 = top[(i + 1) % top.count]
        let ang = atan2(Double(p1.y - p0.y), Double(p1.x - p0.x))
        if cos(ang - .pi / 2 - 2.30) > 0 { current.append(i) }
        else if !current.isEmpty { litRuns.append(current); current = [] }
    }
    if !current.isEmpty { litRuns.append(current) }
    for run in litRuns {
        var pts: [CGPoint] = [top[run[0]]]
        for i in run { pts.append(top[(i + 1) % top.count]) }
        pen(p, pts, weight: 7.0, colour: Field.bone.lt(0.32).al(0.78), wobble: 0.2,
            taper: false, seed: bits(run[0] * 71))
    }
    for i in 0..<top.count where !litRuns.flatMap({ $0 }).contains(i) {
        pen(p, [top[i], top[(i + 1) % top.count]], weight: 6.0, colour: Field.night.al(0.85),
            wobble: 0.2, taper: false, seed: bits(i * 73))
    }

    if let g = CGGradient(colorsSpace: rgbSpace,
                          colors: [cg(Field.bone.al(0.10)), cg(Field.night.al(0)),
                                   cg(Field.night.al(0.50))] as CFArray,
                          locations: [0, 0.40, 1]) {
        p.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 340, y: 300), startRadius: 0,
                                 endCenter: CGPoint(x: 340, y: 300), endRadius: 980,
                                 options: [.drawsAfterEndLocation])
    }

    p.writePNG(dir, "AppIcon-1024")
}
