import Foundation
import CoreGraphics

struct ChartSpec {
    let id: String
    let name: String
    let place: String
    let year: String
    let kind: String
    let scaleNote: String
    let kicker: String
    let notes: [(String, String)]
}

func pnt(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }

func smoothClosed(_ pts: [CGPoint], passes: Int = 2) -> [CGPoint] {
    var out = pts
    for _ in 0..<passes {
        var next: [CGPoint] = []
        let n = out.count
        for i in 0..<n {
            let a = out[(i + n - 1) % n], b = out[i], c = out[(i + 1) % n]
            next.append(pnt((Double(a.x) + Double(b.x) * 2 + Double(c.x)) / 4,
                            (Double(a.y) + Double(b.y) * 2 + Double(c.y)) / 4))
        }
        out = next
    }
    return out
}

func coastline(kind: String, box: CGRect, seed: UInt64) -> [CGPoint] {
    var rng = Dice(seed)
    let hw = Double(box.width) / 2
    let hh = Double(box.height) / 2
    var cx = Double(box.midX)
    var cy = Double(box.midY)
    var rx = hw * 0.58
    var ry = hh * 0.58
    var biteAngle = 1.3
    var biteWidth = 0.9
    var biteDepth = 0.40

    switch kind {
    case "island", "reef":
        rx = hw * 0.52; ry = hh * 0.50
        biteDepth = 0.10; biteWidth = 0.5
    case "bay", "sound":
        cx = Double(box.minX) + hw * 0.30; cy = Double(box.maxY) - hh * 0.10
        rx = hw * 1.20; ry = hh * 1.10
        biteAngle = -1.05; biteWidth = 0.95; biteDepth = 0.42
    case "estuary", "delta":
        cx = Double(box.minX) + hw * 0.20; cy = Double(box.maxY) - hh * 0.02
        rx = hw * 1.30; ry = hh * 1.20
        biteAngle = -0.95; biteWidth = 0.42; biteDepth = 0.72
    case "cape", "headland":
        cx = Double(box.minX) + hw * 0.10; cy = Double(box.maxY) - hh * 0.30
        rx = hw * 1.05; ry = hh * 1.00
        biteAngle = -0.35; biteWidth = 0.55; biteDepth = -0.34
    case "harbour":
        cx = Double(box.minX) + hw * 0.35; cy = Double(box.maxY) - hh * 0.05
        rx = hw * 1.25; ry = hh * 1.15
        biteAngle = -1.25; biteWidth = 0.60; biteDepth = 0.34
    case "loch", "fjord":
        cx = Double(box.midX); cy = Double(box.maxY) + hh * 0.10
        rx = hw * 1.35; ry = hh * 1.40
        biteAngle = -1.5708; biteWidth = 0.30; biteDepth = 0.88
    default:
        cx = Double(box.minX) + hw * 0.25; cy = Double(box.maxY) - hh * 0.15
        rx = hw * 1.15; ry = hh * 1.05
        biteAngle = -0.9; biteWidth = 0.8; biteDepth = 0.30
    }

    var pts: [CGPoint] = []
    let steps = 150
    for k in 0..<steps {
        let a = Double(k) / Double(steps) * 6.283
        var r = 1.0 + 0.05 * sin(a * 3 + 0.7) + 0.035 * sin(a * 7 + 2.2)
            + 0.022 * sin(a * 13 + 1.1) + 0.016 * sin(a * 21 + 0.3) + rng.signed() * 0.016
        let d = abs(atan2(sin(a - biteAngle), cos(a - biteAngle)))
        if d < biteWidth {
            let f = pow(1 - d / biteWidth, 1.4)
            r -= biteDepth * f
        }
        r = max(0.10, r)
        pts.append(pnt(cx + cos(a) * rx * r, cy + sin(a) * ry * r))
    }
    return smoothClosed(pts, passes: 2)
}

func insidePoly(_ p: CGPoint, _ poly: [CGPoint]) -> Bool {
    var inside = false
    var j = poly.count - 1
    for i in 0..<poly.count {
        let a = poly[i], b = poly[j]
        if (a.y > p.y) != (b.y > p.y) {
            let t = Double(p.y - a.y) / Double(b.y - a.y)
            if Double(p.x) < Double(a.x) + t * Double(b.x - a.x) { inside = !inside }
        }
        j = i
    }
    return inside
}

func distanceToPoly(_ p: CGPoint, _ poly: [CGPoint]) -> Double {
    var best = Double.greatestFiniteMagnitude
    for q in poly {
        let dx = Double(p.x - q.x), dy = Double(p.y - q.y)
        best = min(best, (dx * dx + dy * dy).squareRoot())
    }
    return best
}

func offsetPoly(_ poly: [CGPoint], by amount: Double, centre: CGPoint) -> [CGPoint] {
    poly.map { q in
        var dx = Double(q.x - centre.x), dy = Double(q.y - centre.y)
        let len = (dx * dx + dy * dy).squareRoot()
        guard len > 0.001 else { return q }
        dx /= len; dy /= len
        return pnt(Double(q.x) + dx * amount, Double(q.y) + dy * amount)
    }
}

func drawHachures(_ p: Sheet, centre: CGPoint, radius: Double, land: [CGPoint], seed: UInt64) {
    var rng = Dice(seed)
    var foot: [CGPoint] = []
    var a0 = 0.0
    while a0 < 6.283 {
        let wob = 1.0 + 0.10 * sin(a0 * 3 + 1.2) + rng.signed() * 0.05
        foot.append(pnt(Double(centre.x) + cos(a0) * radius * wob,
                        Double(centre.y) + sin(a0) * radius * wob * 0.82))
        a0 += 0.16
    }
    var ring = 0.34
    var layer = 0
    while ring <= 0.94 {
        let count = Int(10 + ring * 26)
        for k in 0..<count {
            let a = Double(k) / Double(count) * 6.283 + Double(layer) * 0.08 + rng.r(-0.03, 0.03)
            let wob = 1.0 + 0.10 * sin(a * 3 + 1.2)
            let r0 = radius * ring * wob
            let r1 = radius * (ring + 0.15) * wob
            let start = pnt(Double(centre.x) + cos(a) * r0, Double(centre.y) + sin(a) * r0 * 0.82)
            let end = pnt(Double(centre.x) + cos(a) * r1, Double(centre.y) + sin(a) * r1 * 0.82)
            guard insidePoly(end, land) else { continue }
            let steep = 0.35 + 0.5 * pow(sin(a * 2 + 0.7), 2)
            pen(p, [start, end], weight: 0.7 + steep * 1.1,
                colour: Field.ink.al(0.45 + steep * 0.35), wobble: 0.4, taper: true,
                seed: seed &+ bits(k &+ layer * 100))
        }
        ring += 0.20
        layer += 1
    }
    for i in 0..<foot.count where insidePoly(foot[i], land) {
        pen(p, [foot[i], foot[(i + 1) % foot.count]], weight: 0.8,
            colour: Field.inkPale.al(0.55), wobble: 0.4, taper: false, seed: seed &+ bits(i))
    }
}

func drawRiver(_ p: Sheet, from a: CGPoint, to b: CGPoint, seed: UInt64) {
    var rng = Dice(seed)
    var pts: [CGPoint] = []
    var t = 0.0
    while t <= 1.0 {
        let x = Double(a.x) + (Double(b.x) - Double(a.x)) * t
        let y = Double(a.y) + (Double(b.y) - Double(a.y)) * t
        let sway = sin(t * 9 + rng.d() * 0.2) * 22 * (1 - t * 0.4)
        pts.append(pnt(x + sway, y + sway * 0.4))
        t += 0.06
    }
    for k in 0..<pts.count - 1 {
        let width = 0.9 + Double(k) / Double(pts.count) * 3.4
        pen(p, [pts[k], pts[k + 1]], weight: width, colour: Field.ink.al(0.85),
            wobble: 0.4, taper: false, seed: seed &+ bits(k))
    }
}

func drawTown(_ p: Sheet, at c: CGPoint, size: Double, name: String, seed: UInt64) {
    var rng = Dice(seed)
    for _ in 0..<Int(size * 1.4) {
        let bx = Double(c.x) + rng.r(-size * 3, size * 3)
        let by = Double(c.y) + rng.r(-size * 2, size * 2)
        let bw = rng.r(4, 9), bh = rng.r(3, 7)
        p.rect(bx, by, bw, bh, Field.ink.al(0.85))
    }
    pen(p, [pnt(Double(c.x), Double(c.y) - size * 3.2), pnt(Double(c.x), Double(c.y) - size * 0.6)],
        weight: 1.8, colour: Field.ink, wobble: 0.3, taper: false, seed: seed &+ 3)
    pen(p, [pnt(Double(c.x) - size * 0.8, Double(c.y) - size * 2.4),
            pnt(Double(c.x) + size * 0.8, Double(c.y) - size * 2.4)],
        weight: 1.6, colour: Field.ink, wobble: 0.3, taper: false, seed: seed &+ 5)
    caption(p, name, at: Double(c.x) + size * 4, Double(c.y) + 5, size: 21, colour: Field.ink,
            face: "Georgia-Italic", align: .left)
}

func compassRose(_ p: Sheet, at c: CGPoint, radius: Double, seed: UInt64) {
    let cx = Double(c.x), cy = Double(c.y)
    p.ring(cx, cy, radius, 1.6, Field.ink.al(0.8))
    p.ring(cx, cy, radius * 0.86, 1.0, Field.ink.al(0.6))
    for k in 0..<32 {
        let a = Double(k) / 32 * 6.283 - 1.5708
        let long = k % 4 == 0
        pen(p, [pnt(cx + cos(a) * radius * (long ? 0.72 : 0.80), cy + sin(a) * radius * (long ? 0.72 : 0.80)),
                pnt(cx + cos(a) * radius * 0.86, cy + sin(a) * radius * 0.86)],
            weight: long ? 1.6 : 0.9, colour: Field.ink.al(0.8), wobble: 0.2, taper: false,
            seed: seed &+ bits(k))
    }
    for k in 0..<8 {
        let a = Double(k) / 8 * 6.283 - 1.5708
        let long = k % 2 == 0
        let r = radius * (long ? 0.70 : 0.46)
        let w = radius * 0.10
        let tip = pnt(cx + cos(a) * r, cy + sin(a) * r)
        let leftP = pnt(cx + cos(a + 1.5708) * w, cy + sin(a + 1.5708) * w)
        let rightP = pnt(cx + cos(a - 1.5708) * w, cy + sin(a - 1.5708) * w)
        p.poly([tip, leftP, pnt(cx, cy)], Field.ink.al(0.9))
        p.poly([tip, rightP, pnt(cx, cy)], Field.paperWarm.al(0.9))
        penContour(p, [tip, leftP, pnt(cx, cy), rightP], weight: 1.0, colour: Field.ink.al(0.8),
                   seed: seed &+ bits(k &+ 40))
    }
    let north = pnt(cx, cy - radius * 0.70)
    p.poly([north, pnt(cx - radius * 0.09, cy - radius * 0.42),
            pnt(cx, cy - radius * 0.52), pnt(cx + radius * 0.09, cy - radius * 0.42)],
           Field.oxblood)
    caption(p, "N", at: cx, cy - radius * 1.02, size: 20, colour: Field.ink,
            face: "Georgia-Bold", align: .centre)
    caption(p, "E", at: cx + radius * 1.06, cy + 7, size: 18, colour: Field.inkSoft,
            face: "Georgia", align: .centre)
    caption(p, "S", at: cx, cy + radius * 1.14, size: 18, colour: Field.inkSoft,
            face: "Georgia", align: .centre)
    caption(p, "W", at: cx - radius * 1.06, cy + 7, size: 18, colour: Field.inkSoft,
            face: "Georgia", align: .centre)
}

func scaleBar(_ p: Sheet, at c: CGPoint, width: Double, label: String, seed: UInt64) {
    let x = Double(c.x), y = Double(c.y)
    let h = 11.0
    let cells = 6
    for k in 0..<cells {
        let cw = width / Double(cells)
        let cx0 = x + Double(k) * cw
        if k % 2 == 0 { p.rect(cx0, y, cw, h, Field.ink.al(0.85)) }
        penContour(p, [pnt(cx0, y), pnt(cx0 + cw, y), pnt(cx0 + cw, y + h), pnt(cx0, y + h)],
                   weight: 1.0, colour: Field.ink, seed: seed &+ bits(k))
        caption(p, "\(k)", at: cx0, y - 6, size: 15, colour: Field.inkSoft, face: "Georgia",
                align: .centre)
    }
    caption(p, "\(cells)", at: x + width, y - 6, size: 15, colour: Field.inkSoft,
            face: "Georgia", align: .centre)
    caption(p, label, at: x + width / 2, y + h + 22, size: 17, colour: Field.inkSoft,
            face: "Georgia-Italic", align: .centre)
}

func makeChartPlate(_ spec: ChartSpec, dir: String) {
    let p = Sheet(1350, 1700)
    let seed = hashOf(spec.id)
    layPaper(p, seed: seed, tone: Field.cartridge)
    p.topDown()
    p.light = 2.30
    var rng = Dice(seed &+ 11)

    let frame = CGRect(x: 92, y: 92, width: 1166, height: 1120)
    let inner = frame.insetBy(dx: 26, dy: 26)

    let land = coastline(kind: spec.kind, box: inner.insetBy(dx: 40, dy: 40), seed: seed &+ 3)
    var landCx = 0.0, landCy = 0.0
    for q in land { landCx += Double(q.x); landCy += Double(q.y) }
    landCx /= Double(land.count); landCy /= Double(land.count)
    let centre = pnt(landCx, landCy)

    p.clipRect(inner) {
        p.ctx.setFillColor(cg(Field.seaBlue.al(0.16)))
        p.ctx.fill(inner)
        for k in 1...4 {
            let off = Double(k) * 26
            let contour = offsetPoly(land, by: off, centre: centre)
            var dashed: [CGPoint] = []
            for (i, q) in contour.enumerated() where i % 2 == 0 { dashed.append(q) }
            for i in 0..<(dashed.count - 1) where i % 3 != 2 {
                pen(p, [dashed[i], dashed[i + 1]], weight: 0.8,
                    colour: Field.seaDeep.al(0.55), wobble: 0.5, taper: false,
                    seed: seed &+ bits(i &+ k * 90))
            }
        }

        p.clip(pathOf(land)) {
            p.ctx.setFillColor(cg(Field.cartridge.al(0.98)))
            p.ctx.addPath(pathOf(land))
            p.ctx.fillPath()
            p.ctx.setFillColor(cg(Field.sand.al(0.20)))
            p.ctx.addPath(pathOf(land))
            p.ctx.fillPath()
        }

        for _ in 0..<180 {
            let sx = Double(inner.minX) + rng.d() * Double(inner.width)
            let sy = Double(inner.minY) + rng.d() * Double(inner.height)
            let q = pnt(sx, sy)
            guard !insidePoly(q, land) else { continue }
            let d = distanceToPoly(q, land)
            let depth = Int(1 + d / 26 + rng.r(0, 3))
            caption(p, "\(depth)", at: sx, sy, size: 15, colour: Field.inkSoft.al(0.85),
                    face: "Georgia-Italic", align: .centre)
        }

        for _ in 0..<rng.i(2, 4) {
            let bx = Double(inner.minX) + rng.d() * Double(inner.width)
            let by = Double(inner.minY) + rng.d() * Double(inner.height)
            let q = pnt(bx, by)
            guard !insidePoly(q, land), distanceToPoly(q, land) > 40 else { continue }
            let bank = blob(cx: bx, cy: by, rx: rng.r(50, 120), ry: rng.r(30, 80), rough: 0.22,
                            steps: 20, seed: seed &+ bits(Int(bx)))
            stipple(p, pathOf(bank), density: 0.0022, sizeMin: 0.5, sizeMax: 1.6,
                    colour: Field.sepia.al(0.6), seed: seed &+ bits(Int(by)))
            for i in 0..<bank.count where i % 2 == 0 {
                pen(p, [bank[i], bank[(i + 1) % bank.count]], weight: 0.7,
                    colour: Field.inkPale.al(0.7), wobble: 0.4, taper: false,
                    seed: seed &+ bits(i))
            }
            caption(p, "Sands", at: bx, by + 4, size: 17, colour: Field.inkSoft,
                    face: "Georgia-Italic", align: .centre)
        }

        for _ in 0..<rng.i(3, 7) {
            let rx = Double(inner.minX) + rng.d() * Double(inner.width)
            let ry = Double(inner.minY) + rng.d() * Double(inner.height)
            let q = pnt(rx, ry)
            guard !insidePoly(q, land), distanceToPoly(q, land) > 16 else { continue }
            for k in 0..<3 {
                let a = Double(k) / 3 * 3.14
                pen(p, [pnt(rx - cos(a) * 6, ry - sin(a) * 6), pnt(rx + cos(a) * 6, ry + sin(a) * 6)],
                    weight: 1.4, colour: Field.ink, wobble: 0.3, taper: false,
                    seed: seed &+ bits(k))
            }
            for k in 0..<4 {
                let a = Double(k) / 4 * 6.283 + 0.4
                p.disc(rx + cos(a) * 13, ry + sin(a) * 13, 1.4, Field.ink)
            }
        }

        var hills: [(CGPoint, Double)] = []
        for _ in 0..<rng.i(7, 12) {
            let hx = Double(inner.minX) + rng.d() * Double(inner.width)
            let hy = Double(inner.minY) + rng.d() * Double(inner.height)
            let q = pnt(hx, hy)
            guard insidePoly(q, land), distanceToPoly(q, land) > 30 else { continue }
            hills.append((q, rng.r(30, 72)))
        }
        for (c, r) in hills {
            drawHachures(p, centre: c, radius: r, land: land, seed: seed &+ bits(Int(c.x)))
        }

        for i in 0..<land.count {
            let a = land[i], b = land[(i + 1) % land.count]
            pen(p, [a, b], weight: 2.2, colour: Field.ink, wobble: 0.5, taper: false,
                seed: seed &+ bits(i))
        }
        for i in 0..<land.count where i % 3 == 0 {
            let q = land[i]
            var dx = Double(q.x - centre.x), dy = Double(q.y - centre.y)
            let len = (dx * dx + dy * dy).squareRoot()
            guard len > 0 else { continue }
            dx /= len; dy /= len
            pen(p, [q, pnt(Double(q.x) + dx * 7, Double(q.y) + dy * 7)], weight: 0.9,
                colour: Field.inkSoft.al(0.6), wobble: 0.3, taper: true, seed: seed &+ bits(i &+ 7))
        }

        for _ in 0..<rng.i(1, 3) {
            var inlandPoint = centre
            var tries = 0
            while tries < 20 {
                let q = pnt(Double(inner.minX) + rng.d() * Double(inner.width),
                            Double(inner.minY) + rng.d() * Double(inner.height))
                if insidePoly(q, land) && distanceToPoly(q, land) > 60 { inlandPoint = q; break }
                tries += 1
            }
            let mouth = land[rng.i(0, land.count - 1)]
            drawRiver(p, from: inlandPoint, to: mouth, seed: seed &+ bits(tries))
        }

        var townPoints: [CGPoint] = []
        var townPlaced = 0
        var attempts = 0
        let townNames = ["Redwick", "Stonehaven", "Barmouth", "Kilbrae", "Netherby", "Portloe",
                         "Ashmere", "Cairnhead", "Sandquay", "Marlow"]
        while townPlaced < rng.i(2, 3) && attempts < 40 {
            attempts += 1
            let q = pnt(Double(inner.minX) + rng.d() * Double(inner.width),
                        Double(inner.minY) + rng.d() * Double(inner.height))
            guard insidePoly(q, land), distanceToPoly(q, land) > 26,
                  distanceToPoly(q, land) < 150 else { continue }
            var tooClose = false
            for t in townPoints {
                let ddx = Double(t.x - q.x), ddy = Double(t.y - q.y)
                if (ddx * ddx + ddy * ddy).squareRoot() < 240 { tooClose = true }
            }
            guard !tooClose else { continue }
            townPoints.append(q)
            drawTown(p, at: q, size: rng.r(5, 8), name: townNames[rng.i(0, townNames.count - 1)],
                     seed: seed &+ bits(attempts))
            townPlaced += 1
        }

        if townPoints.count > 1 {
            for i in 0..<(townPoints.count - 1) {
                let a = townPoints[i], b = townPoints[i + 1]
                var road: [CGPoint] = []
                var t = 0.0
                while t <= 1.0 {
                    road.append(pnt(Double(a.x) + (Double(b.x) - Double(a.x)) * t
                                    + sin(t * 5) * 18,
                                    Double(a.y) + (Double(b.y) - Double(a.y)) * t
                                    + cos(t * 4) * 14))
                    t += 0.08
                }
                for k in 0..<road.count - 1 where k % 3 != 2 {
                    pen(p, [road[k], road[k + 1]], weight: 1.0, colour: Field.inkSoft.al(0.8),
                        wobble: 0.3, taper: false, seed: seed &+ bits(k &+ i * 40))
                    pen(p, [pnt(Double(road[k].x), Double(road[k].y) + 4),
                            pnt(Double(road[k + 1].x), Double(road[k + 1].y) + 4)],
                        weight: 1.0, colour: Field.inkSoft.al(0.8), wobble: 0.3, taper: false,
                        seed: seed &+ bits(k &+ i * 40 &+ 7))
                }
            }
        }

        for _ in 0..<rng.i(14, 24) {
            let q = pnt(Double(inner.minX) + rng.d() * Double(inner.width),
                        Double(inner.minY) + rng.d() * Double(inner.height))
            guard insidePoly(q, land) else { continue }
            let x = Double(q.x), y = Double(q.y)
            if rng.chance(0.5) {
                pen(p, [pnt(x - 7, y), pnt(x + 7, y)], weight: 1.0, colour: Field.marsh.dk(0.1),
                    wobble: 0.4, taper: false, seed: seed &+ bits(Int(x)))
                pen(p, [pnt(x - 4, y - 5), pnt(x - 4, y)], weight: 0.9, colour: Field.marsh.dk(0.1),
                    wobble: 0.4, taper: true, seed: seed &+ bits(Int(y)))
                pen(p, [pnt(x + 3, y - 6), pnt(x + 3, y)], weight: 0.9, colour: Field.marsh.dk(0.1),
                    wobble: 0.4, taper: true, seed: seed &+ bits(Int(y) &+ 3))
            } else {
                for k in 0..<3 {
                    let a = 1.2 + Double(k) * 0.5
                    pen(p, [pnt(x, y), pnt(x + cos(a) * 9, y - sin(a) * 11)], weight: 0.9,
                        colour: Field.moss.dk(0.1), wobble: 0.4, taper: true,
                        seed: seed &+ bits(k &+ Int(x)))
                }
            }
        }

        compassRose(p, at: pnt(Double(inner.maxX) - 130, Double(inner.minY) + 140),
                    radius: 86, seed: seed &+ 71)
    }

    var tick = Double(inner.minX)
    var ti = 0
    while tick <= Double(inner.maxX) {
        pen(p, [pnt(tick, Double(frame.minY)), pnt(tick, Double(inner.minY))],
            weight: ti % 5 == 0 ? 1.6 : 0.9, colour: Field.ink, wobble: 0.2, taper: false,
            seed: seed &+ bits(ti))
        pen(p, [pnt(tick, Double(inner.maxY)), pnt(tick, Double(frame.maxY))],
            weight: ti % 5 == 0 ? 1.6 : 0.9, colour: Field.ink, wobble: 0.2, taper: false,
            seed: seed &+ bits(ti &+ 500))
        tick += Double(inner.width) / 24
        ti += 1
    }
    tick = Double(inner.minY)
    ti = 0
    while tick <= Double(inner.maxY) {
        pen(p, [pnt(Double(frame.minX), tick), pnt(Double(inner.minX), tick)],
            weight: ti % 5 == 0 ? 1.6 : 0.9, colour: Field.ink, wobble: 0.2, taper: false,
            seed: seed &+ bits(ti &+ 900))
        pen(p, [pnt(Double(inner.maxX), tick), pnt(Double(frame.maxX), tick)],
            weight: ti % 5 == 0 ? 1.6 : 0.9, colour: Field.ink, wobble: 0.2, taper: false,
            seed: seed &+ bits(ti &+ 1300))
        tick += Double(inner.height) / 22
        ti += 1
    }

    penContour(p, [pnt(Double(frame.minX), Double(frame.minY)), pnt(Double(frame.maxX), Double(frame.minY)),
                   pnt(Double(frame.maxX), Double(frame.maxY)), pnt(Double(frame.minX), Double(frame.maxY))],
               weight: 2.6, colour: Field.ink, seed: seed &+ 81)
    penContour(p, [pnt(Double(inner.minX), Double(inner.minY)), pnt(Double(inner.maxX), Double(inner.minY)),
                   pnt(Double(inner.maxX), Double(inner.maxY)), pnt(Double(inner.minX), Double(inner.maxY))],
               weight: 1.4, colour: Field.ink, seed: seed &+ 83)

    let cartX = Double(inner.minX) + 40
    let cartY = Double(inner.maxY) - 220
    p.rect(cartX, cartY, 470, 176, Field.paperWarm.al(0.86))
    penContour(p, [pnt(cartX, cartY), pnt(cartX + 470, cartY), pnt(cartX + 470, cartY + 176),
                   pnt(cartX, cartY + 176)], weight: 2.0, colour: Field.ink, seed: seed &+ 91)
    penContour(p, [pnt(cartX + 8, cartY + 8), pnt(cartX + 462, cartY + 8),
                   pnt(cartX + 462, cartY + 168), pnt(cartX + 8, cartY + 168)],
               weight: 0.9, colour: Field.inkSoft, seed: seed &+ 93)
    caption(p, spec.name, at: cartX + 235, cartY + 52, size: 34, colour: Field.ink,
            face: "Georgia-Bold", align: .centre)
    caption(p, spec.place, at: cartX + 235, cartY + 82, size: 20, colour: Field.inkSoft,
            face: "Georgia-Italic", align: .centre)
    caption(p, "Surveyed " + spec.year, at: cartX + 235, cartY + 108, size: 17,
            colour: Field.inkPale, face: "Georgia", align: .centre)
    scaleBar(p, at: pnt(cartX + 90, cartY + 126), width: 260, label: spec.scaleNote,
             seed: seed &+ 95)

    caption(p, spec.kicker.uppercased(), at: 92, 74, size: 19, colour: Field.oxblood,
            face: "Georgia-Bold", align: .left, tracking: 3.2)
    caption(p, spec.name, at: 92, 1300, size: 50, colour: Field.ink, face: "Georgia-Bold", align: .left)
    caption(p, spec.place + "  ·  " + spec.year, at: 92, 1338, size: 24, colour: Field.inkPale,
            face: "Georgia-Italic", align: .left)

    var y = 1394.0
    for note in spec.notes {
        caption(p, note.0.uppercased(), at: 92, y, size: 18, colour: Field.sepia,
                face: "Georgia-Bold", align: .left, tracking: 2.4)
        y += 30
        for line in wrapText(note.1, width: 1160, size: 23) {
            caption(p, line, at: 92, y, size: 23, colour: Field.inkSoft, face: "Georgia", align: .left)
            y += 30
        }
        y += 14
    }

    plateFrame(p, inset: 40, seed: seed &+ 97)
    p.write(dir, "chart_" + spec.id, quality: 0.88)
}
