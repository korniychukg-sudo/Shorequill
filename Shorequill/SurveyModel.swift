import SwiftUI

func unitCoast(kind: String, seed: UInt64, steps: Int = 150) -> [CGPoint] {
    var rng = Draw(seed)
    var cx = 0.5, cy = 0.5
    var rx = 0.29, ry = 0.29
    var biteAngle = 1.3, biteWidth = 0.9, biteDepth = 0.40

    switch kind {
    case "island", "reef":
        rx = 0.26; ry = 0.25; biteDepth = 0.10; biteWidth = 0.5
    case "bay", "sound":
        cx = 0.15; cy = 0.95; rx = 0.60; ry = 0.55
        biteAngle = -1.05; biteWidth = 0.95; biteDepth = 0.42
    case "estuary", "delta":
        cx = 0.10; cy = 0.99; rx = 0.65; ry = 0.60
        biteAngle = -0.95; biteWidth = 0.42; biteDepth = 0.72
    case "cape", "headland":
        cx = 0.05; cy = 0.85; rx = 0.52; ry = 0.50
        biteAngle = -0.35; biteWidth = 0.55; biteDepth = -0.34
    case "harbour":
        cx = 0.18; cy = 0.97; rx = 0.62; ry = 0.58
        biteAngle = -1.25; biteWidth = 0.60; biteDepth = 0.34
    case "loch", "fjord":
        cx = 0.50; cy = 1.05; rx = 0.68; ry = 0.70
        biteAngle = -1.5708; biteWidth = 0.30; biteDepth = 0.88
    default:
        cx = 0.12; cy = 0.92; rx = 0.58; ry = 0.52
        biteAngle = -0.9; biteWidth = 0.8; biteDepth = 0.30
    }

    var pts: [CGPoint] = []
    for k in 0..<steps {
        let a = Double(k) / Double(steps) * 6.283
        var r = 1.0 + 0.05 * sin(a * 3 + 0.7) + 0.035 * sin(a * 7 + 2.2)
            + 0.022 * sin(a * 13 + 1.1) + rng.signed() * 0.016
        let d = abs(atan2(sin(a - biteAngle), cos(a - biteAngle)))
        if d < biteWidth { r -= biteDepth * pow(1 - d / biteWidth, 1.4) }
        r = max(0.10, r)
        pts.append(CGPoint(x: cx + cos(a) * rx * r, y: cy + sin(a) * ry * r))
    }
    for _ in 0..<2 {
        var next: [CGPoint] = []
        let n = pts.count
        for i in 0..<n {
            let a = pts[(i + n - 1) % n], b = pts[i], c = pts[(i + 1) % n]
            next.append(CGPoint(x: (a.x + b.x * 2 + c.x) / 4, y: (a.y + b.y * 2 + c.y) / 4))
        }
        pts = next
    }
    return pts
}

func insideUnitPoly(_ p: CGPoint, _ poly: [CGPoint]) -> Bool {
    var inside = false
    var j = poly.count - 1
    for i in 0..<poly.count {
        let a = poly[i], b = poly[j]
        if (a.y > p.y) != (b.y > p.y) {
            let t = (p.y - a.y) / (b.y - a.y)
            if p.x < a.x + t * (b.x - a.x) { inside = !inside }
        }
        j = i
    }
    return inside
}

func nearestOn(_ p: CGPoint, _ path: [CGPoint]) -> (Double, Int) {
    var best = Double.greatestFiniteMagnitude
    var idx = 0
    for (i, q) in path.enumerated() {
        let dx = Double(p.x - q.x), dy = Double(p.y - q.y)
        let d = (dx * dx + dy * dy).squareRoot()
        if d < best { best = d; idx = i }
    }
    return (best, idx)
}

struct Landmark: Identifiable {
    let id: Int
    let name: String
    let kind: String
    let at: CGPoint
}

struct Ground {
    let id: String
    let name: String
    let place: String
    let year: String
    let kind: String
    let kicker: String
    let blurb: String
    let difficulty: Int

    var plate: String { "chart_" + id }
    var coast: [CGPoint] { unitCoast(kind: kind, seed: inkSeed(id)) }

    var stations: [CGPoint] {
        var rng = Draw(inkSeed(id) &+ 77)
        let coastLine = coast
        var out: [CGPoint] = []
        var tries = 0
        while out.count < 2 && tries < 400 {
            tries += 1
            let q = CGPoint(x: rng.range(0.08, 0.92), y: rng.range(0.08, 0.92))
            guard insideUnitPoly(q, coastLine) else { continue }
            if let first = out.first {
                let dx = Double(q.x - first.x), dy = Double(q.y - first.y)
                guard (dx * dx + dy * dy).squareRoot() > 0.28 else { continue }
            }
            out.append(q)
        }
        while out.count < 2 { out.append(CGPoint(x: 0.2 + Double(out.count) * 0.4, y: 0.8)) }
        return out
    }

    var landmarks: [Landmark] {
        var rng = Draw(inkSeed(id) &+ 131)
        let coastLine = coast
        let kinds = ["spire", "mill", "beacon", "peak", "tower"]
        let names = ["St Brendan's spire", "The windmill", "White beacon", "Ben Corrie",
                     "The old tower"]
        var out: [Landmark] = []
        var tries = 0
        while out.count < 4 && tries < 600 {
            tries += 1
            let q = CGPoint(x: rng.range(0.06, 0.94), y: rng.range(0.06, 0.94))
            guard insideUnitPoly(q, coastLine) else { continue }
            var clash = false
            for l in out {
                let dx = Double(q.x - l.at.x), dy = Double(q.y - l.at.y)
                if (dx * dx + dy * dy).squareRoot() < 0.18 { clash = true }
            }
            guard !clash else { continue }
            let slot = out.count % kinds.count
            out.append(Landmark(id: out.count, name: names[slot], kind: kinds[slot], at: q))
        }
        while out.count < 4 {
            let slot = out.count % kinds.count
            out.append(Landmark(id: out.count, name: names[slot], kind: kinds[slot],
                                at: CGPoint(x: 0.3 + Double(out.count) * 0.12, y: 0.75)))
        }
        return out
    }

    var hills: [(CGPoint, Double)] {
        var rng = Draw(inkSeed(id) &+ 211)
        let coastLine = coast
        var out: [(CGPoint, Double)] = []
        var tries = 0
        while out.count < 2 && tries < 400 {
            tries += 1
            let q = CGPoint(x: rng.range(0.1, 0.9), y: rng.range(0.1, 0.9))
            guard insideUnitPoly(q, coastLine) else { continue }
            let (d, _) = nearestOn(q, coastLine)
            guard d > 0.10 else { continue }
            if let first = out.first {
                let dx = Double(q.x - first.0.x), dy = Double(q.y - first.0.y)
                guard (dx * dx + dy * dy).squareRoot() > 0.22 else { continue }
            }
            out.append((q, rng.range(0.07, 0.12)))
        }
        while out.count < 2 {
            out.append((CGPoint(x: 0.25 + Double(out.count) * 0.2, y: 0.8), 0.09))
        }
        return out
    }

    var soundingMarks: [CGPoint] {
        var rng = Draw(inkSeed(id) &+ 307)
        let coastLine = coast
        var out: [CGPoint] = []
        var tries = 0
        while out.count < 6 && tries < 700 {
            tries += 1
            let q = CGPoint(x: rng.range(0.06, 0.94), y: rng.range(0.06, 0.94))
            guard !insideUnitPoly(q, coastLine) else { continue }
            var clash = false
            for s in out {
                let dx = Double(q.x - s.x), dy = Double(q.y - s.y)
                if (dx * dx + dy * dy).squareRoot() < 0.16 { clash = true }
            }
            guard !clash else { continue }
            out.append(q)
        }
        while out.count < 6 { out.append(CGPoint(x: 0.6, y: 0.2 + Double(out.count) * 0.1)) }
        return out
    }

    func depth(at p: CGPoint) -> Int {
        let (d, _) = nearestOn(p, coast)
        return max(1, Int(2 + d * 46))
    }

    var coastSegment: [CGPoint] {
        let line = coast
        var best = 0
        var bestScore = -1.0
        for i in 0..<line.count {
            var score = 0.0
            for k in 0..<40 {
                let q = line[(i + k) % line.count]
                if q.x > 0.08 && q.x < 0.92 && q.y > 0.08 && q.y < 0.92 { score += 1 }
            }
            if score > bestScore { bestScore = score; best = i }
        }
        var out: [CGPoint] = []
        for k in 0..<40 { out.append(line[(best + k) % line.count]) }
        return out
    }
}

func bearing(from a: CGPoint, to b: CGPoint) -> Double {
    let dx = Double(b.x - a.x)
    let dy = Double(a.y - b.y)
    var deg = atan2(dx, dy) * 180 / Double.pi
    if deg < 0 { deg += 360 }
    return deg
}

func angleDiff(_ a: Double, _ b: Double) -> Double {
    var d = abs(a - b).truncatingRemainder(dividingBy: 360)
    if d > 180 { d = 360 - d }
    return d
}

struct RayFix {
    let landmark: Int
    let point: CGPoint
    let cocked: Double
}

func intersectRays(from stations: [CGPoint], bearings: [Double]) -> CGPoint? {
    guard stations.count == 2, bearings.count == 2 else { return nil }
    let a = stations[0], b = stations[1]
    let ra = bearings[0] * Double.pi / 180, rb = bearings[1] * Double.pi / 180
    let dxa = sin(ra), dya = -cos(ra)
    let dxb = sin(rb), dyb = -cos(rb)
    let det = dxa * (-dyb) - dya * (-dxb)
    guard abs(det) > 0.0001 else { return nil }
    let ex = Double(b.x - a.x), ey = Double(b.y - a.y)
    let t = (ex * (-dyb) - ey * (-dxb)) / det
    return CGPoint(x: Double(a.x) + dxa * t, y: Double(a.y) + dya * t)
}

struct SurveyResult {
    var fix: Double
    var ink: Double
    var hachure: Double
    var lettering: Double
    var soundings: Double
    var marks: Int

    var overall: Double {
        fix * 0.28 + ink * 0.26 + hachure * 0.16 + lettering * 0.14 + soundings * 0.16
    }

    var grade: String {
        switch overall {
        case 0.90...: return "A"
        case 0.78..<0.90: return "B"
        case 0.62..<0.78: return "C"
        case 0.44..<0.62: return "D"
        default: return "E"
        }
    }

    var points: Int { Int((overall * 105).rounded()) + marks * 4 }
}

func chartTint(_ grade: String) -> Color {
    switch grade {
    case "A": return Ink.moss
    case "B": return Ink.verdigris
    case "C": return Ink.brass
    case "D": return Ink.oxblood
    default: return Ink.linePale
    }
}

func traceScore(drawn: [CGPoint], target: [CGPoint]) -> (Double, Double, Double) {
    guard drawn.count > 6 else { return (0, 1, 0) }
    var total = 0.0
    var worst = 0.0
    var covered = Set<Int>()
    for p in drawn {
        let (d, idx) = nearestOn(p, target)
        total += d
        worst = max(worst, d)
        covered.insert(idx / 2)
    }
    let mean = total / Double(drawn.count)
    let coverage = Double(covered.count) / Double(max(1, target.count / 2))
    let accuracy = max(0, 1 - mean / 0.045)
    let reach = max(0, min(1, coverage * 1.15))
    return (max(0, min(1, accuracy * 0.62 + reach * 0.38)), mean, coverage)
}

func hachureScore(strokes: [[CGPoint]], hill: CGPoint, radius: Double) -> Double {
    guard !strokes.isEmpty else { return 0 }
    var total = 0.0
    for stroke in strokes {
        guard let a = stroke.first, let b = stroke.last else { continue }
        let dx = Double(b.x - a.x), dy = Double(b.y - a.y)
        let len = (dx * dx + dy * dy).squareRoot()
        guard len > 0.004 else { continue }
        let rx = Double(a.x - hill.x), ry = Double(a.y - hill.y)
        let rlen = (rx * rx + ry * ry).squareRoot()
        guard rlen > 0.001 else { continue }
        let dot = (dx / len) * (rx / rlen) + (dy / len) * (ry / rlen)
        let lengthFit = max(0, 1 - abs(len - radius * 0.42) / (radius * 0.7))
        total += max(0, dot) * 0.72 + lengthFit * 0.28
    }
    return max(0, min(1, total / Double(strokes.count)))
}
