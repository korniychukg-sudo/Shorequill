import Foundation
import CoreGraphics

private func tube(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double,
                  _ r0: Double, _ r1: Double) -> [CGPoint] {
    let dx = x1 - x0, dy = y1 - y0
    let len = (dx * dx + dy * dy).squareRoot()
    let nx = dy / len, ny = -dx / len
    var top: [CGPoint] = []
    var bottom: [CGPoint] = []
    var t = 0.0
    while t <= 1.0001 {
        let r = r0 + (r1 - r0) * t
        let x = x0 + dx * t, y = y0 + dy * t
        top.append(pnt(x + nx * r, y + ny * r))
        bottom.append(pnt(x - nx * r, y - ny * r))
        t += 0.05
    }
    return top + bottom.reversed()
}

func makeIcon(dir: String) {
    let p = Sheet(1024, 1024)
    p.fillAll(Field.baizeDark)
    p.topDown()
    var rng = Dice(51301)

    if let g = CGGradient(colorsSpace: rgbSpace,
                          colors: [cg(Field.baize.lt(0.14)), cg(Field.baizeDark.dk(0.42))] as CFArray,
                          locations: [0, 1]) {
        p.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 250, y: 190), startRadius: 0,
                                 endCenter: CGPoint(x: 250, y: 190), endRadius: 1150,
                                 options: [.drawsAfterEndLocation])
    }
    for _ in 0..<3200 {
        p.disc(rng.d() * 1024, rng.d() * 1024, rng.r(0.6, 2.2),
               (rng.chance(0.5) ? Field.bone : Field.night).al(rng.r(0.02, 0.06)))
    }

    let shadow = [pnt(120, 1024), pnt(420, 640), pnt(1024, 420), pnt(1024, 1024)]
    p.clip(pathOf(shadow)) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.night.al(0.62)), cg(Field.night.al(0))] as CFArray,
                              locations: [0, 1]) {
            p.ctx.drawLinearGradient(g, start: CGPoint(x: 300, y: 950),
                                     end: CGPoint(x: 1024, y: 560), options: [])
        }
    }

    let axisX0 = -80.0, axisY0 = 520.0
    let axisX1 = 1120.0, axisY1 = 168.0

    func along(_ t: Double, _ off: Double) -> CGPoint {
        let dx = axisX1 - axisX0, dy = axisY1 - axisY0
        let len = (dx * dx + dy * dy).squareRoot()
        return pnt(axisX0 + dx * t + (dy / len) * off, axisY0 + dy * t + (-dx / len) * off)
    }

    let standardL = [pnt(250, 520), pnt(372, 500), pnt(414, 1024), pnt(268, 1024)]
    let standardR = [pnt(628, 428), pnt(750, 408), pnt(806, 1024), pnt(660, 1024)]
    for (i, standard) in [standardL, standardR].enumerated() {
        p.poly(standard, Field.brassDark.dk(0.24))
        p.clip(pathOf(standard)) {
            if let g = CGGradient(colorsSpace: rgbSpace,
                                  colors: [cg(Field.bone.lt(0.10)), cg(Field.brass.dk(0.04)),
                                           cg(Field.brass.dk(0.44)),
                                           cg(Field.brassDark.dk(0.80))] as CFArray,
                                  locations: [0, 0.12, 0.48, 1]) {
                p.ctx.drawLinearGradient(g, start: CGPoint(x: standard[0].x, y: 0),
                                         end: CGPoint(x: standard[2].x + 40, y: 0), options: [])
            }
            var r = Dice(bits(i * 97 + 11))
            for _ in 0..<420 {
                let gx = Double(standard[0].x) + r.r(-10, 140)
                let gy = r.r(410, 1024)
                pen(p, [pnt(gx, gy), pnt(gx + r.r(-3, 3), gy + r.r(14, 70))], weight: r.r(0.7, 2.2),
                    colour: (r.chance(0.5) ? Field.bone : Field.night).al(r.r(0.05, 0.22)),
                    wobble: 0.4, taper: true, seed: bits(Int(gy)))
            }
        }
        pen(p, [standard[0], standard[3]], weight: 8,
            colour: Field.bone.al(0.55), wobble: 0.2, taper: false, seed: bits(i * 13))
        pen(p, [standard[1], standard[2]], weight: 9,
            colour: Field.night.al(0.72), wobble: 0.2, taper: false, seed: bits(i * 17))
    }

    let plate = [pnt(150, 950), pnt(930, 890), pnt(960, 1024), pnt(120, 1024)]
    p.poly(plate, Field.brassDark.dk(0.30))
    p.clip(pathOf(plate)) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.brass.dk(0.10)), cg(Field.brassDark.dk(0.82))] as CFArray,
                              locations: [0, 1]) {
            p.ctx.drawLinearGradient(g, start: CGPoint(x: 150, y: 900),
                                     end: CGPoint(x: 940, y: 1024), options: [])
        }
        var r = Dice(6607)
        var x = 120.0
        while x < 970 {
            pen(p, [pnt(x, 880), pnt(x + r.r(-4, 4), 1024)], weight: r.r(1.0, 3.0),
                colour: (r.chance(0.5) ? Field.bone : Field.night).al(r.r(0.06, 0.26)),
                wobble: 0.4, taper: false, seed: bits(Int(x)))
            x += r.r(9, 22)
        }
    }
    pen(p, [pnt(150, 950), pnt(930, 890)], weight: 10,
        colour: Field.bone.al(0.55), wobble: 0.2, taper: false, seed: 401)
    pen(p, [pnt(120, 1024), pnt(960, 1024)], weight: 12,
        colour: Field.night.al(0.72), wobble: 0.2, taper: false, seed: 403)

    let arcCx = 530.0, arcCy = 940.0, arcR = 330.0
    var arcOuter: [CGPoint] = []
    var arcInner: [CGPoint] = []
    var a = Double.pi * 1.06
    while a <= Double.pi * 1.94 {
        arcOuter.append(pnt(arcCx + cos(a) * arcR, arcCy + sin(a) * arcR * 0.42))
        arcInner.append(pnt(arcCx + cos(a) * (arcR - 74), arcCy + sin(a) * (arcR - 74) * 0.42))
        a += 0.03
    }
    let arcBand = arcOuter + arcInner.reversed()
    p.poly(arcBand, Field.brassDark)
    p.clip(pathOf(arcBand)) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.bone.lt(0.10)), cg(Field.brass.dk(0.06)),
                                       cg(Field.brassDark.dk(0.70))] as CFArray,
                              locations: [0, 0.30, 1]) {
            p.ctx.drawLinearGradient(g, start: CGPoint(x: arcCx - arcR, y: arcCy - 130),
                                     end: CGPoint(x: arcCx + arcR, y: arcCy + 60), options: [])
        }
        var k = 0
        var ang = Double.pi * 1.06
        while ang <= Double.pi * 1.94 {
            let long = k % 5 == 0
            let r0 = arcR - (long ? 70.0 : 40.0)
            pen(p, [pnt(arcCx + cos(ang) * arcR, arcCy + sin(ang) * arcR * 0.42),
                    pnt(arcCx + cos(ang) * r0, arcCy + sin(ang) * r0 * 0.42)],
                weight: long ? 4.0 : 2.4, colour: Field.night.al(long ? 0.72 : 0.46),
                wobble: 0.2, taper: false, seed: bits(k * 7))
            ang += 0.045
            k += 1
        }
    }
    pen(p, arcOuter, weight: 7, colour: Field.bone.al(0.42), wobble: 0.2, taper: false, seed: 511)

    let body = tube(Double(along(0.02, 0).x), Double(along(0.02, 0).y),
                    Double(along(0.98, 0).x), Double(along(0.98, 0).y), 128, 100)
    let bodyPath = pathOf(body)
    p.poly(body, Field.brassDark)
    p.clip(bodyPath) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.bone.lt(0.55)), cg(Field.brass.lt(0.30)),
                                       cg(Field.brass),
                                       cg(Field.brass.dk(0.34)),
                                       cg(Field.brassDark.dk(0.66)),
                                       cg(Field.night.lt(0.04))] as CFArray,
                              locations: [0, 0.10, 0.34, 0.62, 0.86, 1]) {
            p.ctx.drawLinearGradient(g, start: along(0.5, 140), end: along(0.5, -150), options: [])
        }
        var r = Dice(7717)
        var t = 0.0
        while t <= 1.0 {
            let off = r.r(-124, 124)
            let a0 = along(t, off)
            pen(p, [a0, pnt(Double(a0.x) + r.r(30, 120), Double(a0.y) + r.r(4, 22))],
                weight: r.r(0.7, 2.4),
                colour: (r.chance(0.5) ? Field.bone : Field.night).al(r.r(0.04, 0.20)),
                wobble: 0.4, taper: true, seed: bits(Int(t * 10000)))
            t += 0.004
        }
        for band in [0.16, 0.40, 0.66, 0.88] {
            pen(p, [along(band, -130), along(band, 130)], weight: 14,
                colour: Field.night.al(0.55), wobble: 0.2, taper: false,
                seed: bits(Int(band * 100)))
            pen(p, [along(band + 0.012, -130), along(band + 0.012, 130)], weight: 7,
                colour: Field.bone.al(0.42), wobble: 0.2, taper: false,
                seed: bits(Int(band * 200)))
        }
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.night.al(0)), cg(Field.night.al(0.52))] as CFArray,
                              locations: [0, 1]) {
            p.ctx.drawLinearGradient(g, start: along(0.5, -20), end: along(0.5, -150), options: [])
        }
    }
    p.clip(bodyPath) {
        pen(p, [along(0.02, 88), along(0.98, 70)], weight: 26,
            colour: Field.bone.lt(0.42).al(0.55), wobble: 0.2, taper: true, seed: 815)
        pen(p, [along(0.06, 112), along(0.94, 90)], weight: 9,
            colour: Tone(r: 1, g: 0.996, b: 0.976).al(0.60), wobble: 0.2, taper: true, seed: 817)
    }
    let bodyHalf = body.count / 2
    pen(p, Array(body[0..<bodyHalf]), weight: 12,
        colour: Field.bone.al(0.78), wobble: 0.2, taper: false, seed: 811)
    pen(p, Array(body[bodyHalf...]), weight: 13,
        colour: Field.night.al(0.80), wobble: 0.2, taper: false, seed: 813)

    let shade = tube(Double(along(0.86, 0).x), Double(along(0.86, 0).y),
                     Double(along(1.06, 0).x), Double(along(1.06, 0).y), 112, 144)
    p.poly(shade, Field.brassDark.dk(0.18))
    p.clip(pathOf(shade)) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.brass.lt(0.26)), cg(Field.brassDark.dk(0.60))] as CFArray,
                              locations: [0, 1]) {
            p.ctx.drawLinearGradient(g, start: along(0.95, 144), end: along(0.95, -150), options: [])
        }
    }

    let eyepiece = tube(Double(along(-0.06, 0).x), Double(along(-0.06, 0).y),
                        Double(along(0.08, 0).x), Double(along(0.08, 0).y), 78, 104)
    p.poly(eyepiece, Field.night.dk(0.10))
    p.clip(pathOf(eyepiece)) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.graphite.lt(0.30)), cg(Field.night)] as CFArray,
                              locations: [0, 1]) {
            p.ctx.drawLinearGradient(g, start: along(0, 104), end: along(0, -116), options: [])
        }
    }

    let clampPts = [pnt(700, 448), pnt(836, 490), pnt(816, 590), pnt(682, 544)]
    p.poly(clampPts, Field.brassDark.dk(0.28))
    p.clip(pathOf(clampPts)) {
        if let g = CGGradient(colorsSpace: rgbSpace,
                              colors: [cg(Field.brass.lt(0.30)), cg(Field.brassDark.dk(0.52))] as CFArray,
                              locations: [0, 1]) {
            p.ctx.drawLinearGradient(g, start: CGPoint(x: 682, y: 448),
                                     end: CGPoint(x: 836, y: 590), options: [])
        }
    }
    pen(p, [pnt(700, 448), pnt(836, 490)], weight: 7,
        colour: Field.bone.al(0.48), wobble: 0.2, taper: false, seed: 907)

    if let g = CGGradient(colorsSpace: rgbSpace,
                          colors: [cg(Field.night.al(0)), cg(Field.night.al(0.54))] as CFArray,
                          locations: [0.48, 1]) {
        p.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 400, y: 380), startRadius: 0,
                                 endCenter: CGPoint(x: 400, y: 380), endRadius: 920,
                                 options: [.drawsAfterEndLocation])
    }

    p.writePNG(dir, "AppIcon-1024")
}
