import SwiftUI

enum SurveyStage {
    case brief
    case bearings
    case plot
    case ink
    case hachure
    case letter
    case sound
    case done
}

struct SurveyView: View {
    let ground: Ground
    let order: Order?
    let onClose: () -> Void

    @EnvironmentObject var store: InkStore

    @State private var stage: SurveyStage = .brief
    @State private var stationIndex = 0
    @State private var heading: Double = 40
    @State private var marks: [[Double]] = [[], []]
    @State private var targetIndex = 0
    @State private var fixes: [CGPoint] = []
    @State private var fixError: Double = 0

    @State private var coastStroke: [CGPoint] = []
    @State private var inkScore: Double = 0
    @State private var inkMean: Double = 0

    @State private var hillIndex = 0
    @State private var hachureStrokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var hachureScores: [Double] = []

    @State private var nameCurve: [CGPoint] = []
    @State private var letterScore: Double = 0

    @State private var soundingsDone: [Bool] = Array(repeating: false, count: 6)
    @State private var soundingError: Double = 0

    @State private var result: SurveyResult?
    @State private var improved = false
    @State private var showLeave = false

    private var landmarks: [Landmark] { ground.landmarks }
    private var stations: [CGPoint] { ground.stations }
    private var coast: [CGPoint] { ground.coast }
    private var segment: [CGPoint] { ground.coastSegment }
    private var hills: [(CGPoint, Double)] { ground.hills }
    private var marksNeeded: Int { landmarks.count }

    var body: some View {
        ZStack {
            DeskLayer(name: "bg_baize", fallback: Ink.baize).ignoresSafeArea()
            Color.black.opacity(0.20).ignoresSafeArea()
            VStack(spacing: 0) {
                header
                GeometryReader { geo in
                    stageBody(geo.size)
                }
                .frame(maxHeight: .infinity)
                controls
            }
        }
        .overlay(finishOverlay)
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ground.name).font(Rule.title(17)).foregroundColor(Ink.paper)
                    Text(stageTitle).font(Rule.italic(12)).foregroundColor(Ink.paper.opacity(0.7))
                }
                Spacer()
                Button(action: { Tap.light(); showLeave = true }) {
                    CrossGlyph(size: 16, color: Ink.paper)
                        .padding(9).background(Circle().fill(Color.white.opacity(0.14)))
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 5) {
                ForEach(0..<6, id: \.self) { i in
                    Capsule()
                        .fill(i < stageNumber ? Ink.brass
                              : (i == stageNumber ? Ink.paper.opacity(0.7) : Color.white.opacity(0.15)))
                        .frame(height: 3)
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 8)
        .background(Color.black.opacity(0.34).ignoresSafeArea(edges: .top))
        .alert(isPresented: $showLeave) {
            Alert(title: Text("Leave the ground?"),
                  message: Text("The field book is not written up and nothing will go into the portfolio."),
                  primaryButton: .destructive(Text("Leave")) { onClose() },
                  secondaryButton: .cancel(Text("Stay")))
        }
    }

    private var stageTitle: String {
        switch stage {
        case .brief: return "The commission"
        case .bearings: return "Station \(stationIndex + 1) of 2"
        case .plot: return "Plotting the fixes"
        case .ink: return "Inking the coast"
        case .hachure: return "Hachuring hill \(hillIndex + 1) of \(hills.count)"
        case .letter: return "Lettering"
        case .sound: return "Soundings"
        case .done: return "Sheet finished"
        }
    }

    private var stageNumber: Int {
        switch stage {
        case .brief: return 0
        case .bearings: return 0
        case .plot: return 1
        case .ink: return 2
        case .hachure: return 3
        case .letter: return 4
        case .sound: return 5
        case .done: return 6
        }
    }

    private func stageBody(_ size: CGSize) -> some View {
        ZStack {
            if stage == .bearings {
                panorama(size)
            } else {
                sheetCanvas(size)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func panorama(_ size: CGSize) -> some View {
        Canvas { ctx, s in
            drawPanorama(&ctx, s)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    heading -= Double(value.translation.width) * 0.16
                    while heading < 0 { heading += 360 }
                    while heading >= 360 { heading -= 360 }
                }
        )
    }

    private func drawPanorama(_ ctx: inout GraphicsContext, _ size: CGSize) {
        let w = size.width, h = size.height
        let span = 70.0
        var sky = Path()
        sky.addRect(CGRect(origin: .zero, size: size))
        ctx.fill(sky, with: .linearGradient(
            Gradient(colors: [Ink.seaBlue.opacity(0.55), Ink.paperWarm.opacity(0.9)]),
            startPoint: .zero, endPoint: CGPoint(x: 0, y: h * 0.7)))

        let horizonY = h * 0.62
        var ground = Path()
        ground.move(to: CGPoint(x: 0, y: h))
        var x = 0.0
        while x <= Double(w) {
            let b = heading + (x / Double(w) - 0.5) * span
            let rad = b * Double.pi / 180
            let hgt = 26 * sin(rad * 2.1) + 18 * sin(rad * 3.7 + 1.1) + 12 * sin(rad * 5.3 + 0.4)
            ground.addLine(to: CGPoint(x: x, y: horizonY - hgt))
            x += 4
        }
        ground.addLine(to: CGPoint(x: w, y: h))
        ground.closeSubpath()
        ctx.fill(ground, with: .linearGradient(
            Gradient(colors: [Ink.moss.opacity(0.55), Ink.moss.opacity(0.30)]),
            startPoint: CGPoint(x: 0, y: horizonY), endPoint: CGPoint(x: 0, y: h)))
        ctx.stroke(ground, with: .color(Ink.lineSoft), lineWidth: 1.6)
        var rngTurf = Draw(UInt64(abs(Int(heading * 3)) % 5000) &+ 991)
        for _ in 0..<220 {
            let gx = CGFloat(rngTurf.unit()) * w
            let gy = horizonY + CGFloat(rngTurf.unit()) * (h - horizonY)
            let scale = (gy - horizonY) / max(1, h - horizonY)
            var blade = Path()
            blade.move(to: CGPoint(x: gx, y: gy))
            blade.addLine(to: CGPoint(x: gx + CGFloat(rngTurf.range(-3, 3)),
                                      y: gy - 3 - scale * 9))
            ctx.stroke(blade, with: .color(Ink.line.opacity(0.10 + Double(scale) * 0.16)),
                       lineWidth: 0.7 + scale * 0.9)
        }
        for k in 0..<3 {
            var hedge = Path()
            let hy = horizonY + CGFloat(6 + k * 16)
            hedge.move(to: CGPoint(x: 0, y: hy))
            var hx = 0.0
            while hx <= Double(w) {
                let b = heading + (hx / Double(w) - 0.5) * span
                hedge.addLine(to: CGPoint(x: hx, y: hy + CGFloat(sin(b * 0.09 + Double(k)) * 5)))
                hx += 8
            }
            ctx.stroke(hedge, with: .color(Ink.lineSoft.opacity(0.28 - Double(k) * 0.06)),
                       lineWidth: 1.2)
        }

        var seaLine = Path()
        seaLine.move(to: CGPoint(x: 0, y: horizonY))
        seaLine.addLine(to: CGPoint(x: w, y: horizonY))
        ctx.stroke(seaLine, with: .color(Ink.seaDeep.opacity(0.5)), lineWidth: 1)

        for lm in landmarks {
            let trueB = bearing(from: stations[stationIndex], to: lm.at)
            var rel = trueB - heading
            while rel > 180 { rel -= 360 }
            while rel < -180 { rel += 360 }
            guard abs(rel) < span / 2 else { continue }
            let px = w * CGFloat(0.5 + rel / span)
            let rad = trueB * Double.pi / 180
            let hgt = 26 * sin(rad * 2.1) + 18 * sin(rad * 3.7 + 1.1) + 12 * sin(rad * 5.3 + 0.4)
            let baseY = horizonY - CGFloat(hgt)
            drawLandmark(&ctx, kind: lm.kind, at: CGPoint(x: px, y: baseY),
                         marked: marks[stationIndex].count > lm.id)
            ctx.draw(Text(lm.name).font(Rule.italic(12)).foregroundColor(Ink.lineSoft),
                     at: CGPoint(x: px, y: baseY + 16))
        }

        var wire = Path()
        wire.move(to: CGPoint(x: w / 2, y: 0))
        wire.addLine(to: CGPoint(x: w / 2, y: h))
        ctx.stroke(wire, with: .color(Ink.oxblood.opacity(0.85)), lineWidth: 1.4)
        var wireCross = Path()
        wireCross.move(to: CGPoint(x: w / 2 - 22, y: horizonY))
        wireCross.addLine(to: CGPoint(x: w / 2 + 22, y: horizonY))
        ctx.stroke(wireCross, with: .color(Ink.oxblood.opacity(0.85)), lineWidth: 1.2)

        var tape = Path()
        tape.addRect(CGRect(x: 0, y: 0, width: w, height: 44))
        ctx.fill(tape, with: .color(Ink.paperWarm.opacity(0.92)))
        var d = floor((heading - span / 2) / 5) * 5
        while d <= heading + span / 2 {
            var rel = d - heading
            while rel > 180 { rel -= 360 }
            while rel < -180 { rel += 360 }
            let px = w * CGFloat(0.5 + rel / span)
            let major = Int(d.rounded()) % 10 == 0
            var tick = Path()
            tick.move(to: CGPoint(x: px, y: major ? 20 : 28))
            tick.addLine(to: CGPoint(x: px, y: 42))
            ctx.stroke(tick, with: .color(Ink.line), lineWidth: major ? 1.6 : 0.8)
            if major {
                var deg = Int(d.rounded()) % 360
                if deg < 0 { deg += 360 }
                ctx.draw(Text("\(deg)").font(Rule.figure(11)).foregroundColor(Ink.lineSoft),
                         at: CGPoint(x: px, y: 12))
            }
            d += 5
        }
        var mark = Path()
        mark.move(to: CGPoint(x: w / 2, y: 44))
        mark.addLine(to: CGPoint(x: w / 2 - 7, y: 30))
        mark.addLine(to: CGPoint(x: w / 2 + 7, y: 30))
        mark.closeSubpath()
        ctx.fill(mark, with: .color(Ink.oxblood))
    }

    private func drawLandmark(_ ctx: inout GraphicsContext, kind: String, at p: CGPoint,
                              marked: Bool) {
        let tint = marked ? Ink.linePale : Ink.line
        switch kind {
        case "spire":
            var body = Path()
            body.addRect(CGRect(x: p.x - 9, y: p.y - 26, width: 18, height: 26))
            ctx.fill(body, with: .color(tint))
            var spire = Path()
            spire.move(to: CGPoint(x: p.x - 9, y: p.y - 26))
            spire.addLine(to: CGPoint(x: p.x, y: p.y - 62))
            spire.addLine(to: CGPoint(x: p.x + 9, y: p.y - 26))
            spire.closeSubpath()
            ctx.fill(spire, with: .color(tint))
        case "mill":
            var tower = Path()
            tower.move(to: CGPoint(x: p.x - 12, y: p.y))
            tower.addLine(to: CGPoint(x: p.x - 7, y: p.y - 34))
            tower.addLine(to: CGPoint(x: p.x + 7, y: p.y - 34))
            tower.addLine(to: CGPoint(x: p.x + 12, y: p.y))
            tower.closeSubpath()
            ctx.fill(tower, with: .color(tint))
            for k in 0..<4 {
                let a = Double(k) / 4 * 2 * Double.pi + 0.4
                var sail = Path()
                sail.move(to: CGPoint(x: p.x, y: p.y - 38))
                sail.addLine(to: CGPoint(x: p.x + CGFloat(cos(a)) * 22,
                                         y: p.y - 38 + CGFloat(sin(a)) * 22))
                ctx.stroke(sail, with: .color(tint), lineWidth: 2)
            }
        case "beacon":
            var pole = Path()
            pole.move(to: CGPoint(x: p.x, y: p.y))
            pole.addLine(to: CGPoint(x: p.x, y: p.y - 46))
            ctx.stroke(pole, with: .color(tint), lineWidth: 3)
            var top = Path()
            top.move(to: CGPoint(x: p.x - 12, y: p.y - 46))
            top.addLine(to: CGPoint(x: p.x + 12, y: p.y - 46))
            top.addLine(to: CGPoint(x: p.x, y: p.y - 66))
            top.closeSubpath()
            ctx.fill(top, with: .color(tint))
        case "peak":
            var peak = Path()
            peak.move(to: CGPoint(x: p.x - 44, y: p.y))
            peak.addLine(to: CGPoint(x: p.x - 6, y: p.y - 54))
            peak.addLine(to: CGPoint(x: p.x + 12, y: p.y - 30))
            peak.addLine(to: CGPoint(x: p.x + 46, y: p.y))
            peak.closeSubpath()
            ctx.fill(peak, with: .color(tint.opacity(0.8)))
        default:
            var tower = Path()
            tower.addRect(CGRect(x: p.x - 11, y: p.y - 44, width: 22, height: 44))
            ctx.fill(tower, with: .color(tint))
            for k in 0..<3 {
                var crenel = Path()
                crenel.addRect(CGRect(x: p.x - 11 + CGFloat(k) * 8, y: p.y - 52, width: 5, height: 8))
                ctx.fill(crenel, with: .color(tint))
            }
        }
    }

    private func sheetCanvas(_ size: CGSize) -> some View {
        let side = min(size.width - 24, size.height - 24)
        let rect = CGRect(x: (size.width - side) / 2, y: (size.height - side) / 2,
                          width: side, height: side)
        return Canvas { ctx, _ in
            drawSheet(&ctx, rect)
        }
        .contentShape(Rectangle())
        .gesture(sheetGesture(rect))
    }

    private func place(_ p: CGPoint, _ rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + p.x * rect.width, y: rect.minY + p.y * rect.height)
    }

    private func unplace(_ p: CGPoint, _ rect: CGRect) -> CGPoint {
        CGPoint(x: (p.x - rect.minX) / max(1, rect.width),
                y: (p.y - rect.minY) / max(1, rect.height))
    }

    private func sheetGesture(_ rect: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let u = unplace(value.location, rect)
                switch stage {
                case .ink:
                    coastStroke.append(u)
                case .hachure:
                    currentStroke.append(u)
                case .letter:
                    nameCurve.append(u)
                case .sound:
                    for (i, mark) in ground.soundingMarks.enumerated() where !soundingsDone[i] {
                        let dx = Double(u.x - mark.x), dy = Double(u.y - mark.y)
                        if (dx * dx + dy * dy).squareRoot() < 0.055 {
                            soundingsDone[i] = true
                            soundingError += (dx * dx + dy * dy).squareRoot()
                            Tap.light()
                        }
                    }
                default:
                    break
                }
            }
            .onEnded { _ in
                switch stage {
                case .ink:
                    let (score, mean, _) = traceScore(drawn: coastStroke, target: segment)
                    inkScore = score
                    inkMean = mean
                    Tap.firm()
                case .hachure:
                    if currentStroke.count > 3 {
                        hachureStrokes.append(currentStroke)
                        Tap.soft()
                    }
                    currentStroke = []
                case .letter:
                    letterScore = judgeLettering()
                    Tap.firm()
                default:
                    break
                }
            }
    }

    private func judgeLettering() -> Double {
        guard nameCurve.count > 6 else { return 0 }
        var crossings = 0
        var offsets: [Double] = []
        for p in nameCurve {
            if insideUnitPoly(p, coast) { crossings += 1 }
            let (d, _) = nearestOn(p, segment)
            offsets.append(d)
        }
        let mean = offsets.reduce(0, +) / Double(offsets.count)
        var variance = 0.0
        for o in offsets { variance += (o - mean) * (o - mean) }
        let evenness = max(0, 1 - (variance / Double(offsets.count)).squareRoot() / 0.05)
        let distance = max(0, 1 - abs(mean - 0.075) / 0.09)
        let clear = max(0, 1 - Double(crossings) / Double(nameCurve.count) * 2.4)
        let dx = Double(nameCurve[nameCurve.count - 1].x - nameCurve[0].x)
        let dy = Double(nameCurve[nameCurve.count - 1].y - nameCurve[0].y)
        let length = (dx * dx + dy * dy).squareRoot()
        let reach = max(0, min(1, length / 0.35))
        return max(0, min(1, distance * 0.32 + evenness * 0.28 + clear * 0.2 + reach * 0.2))
    }

    private func drawSheet(_ ctx: inout GraphicsContext, _ rect: CGRect) {
        var paper = Path()
        paper.addRect(rect.insetBy(dx: -8, dy: -8))
        ctx.fill(paper, with: .color(Ink.paper))
        ctx.stroke(paper, with: .color(Ink.paperSunk), lineWidth: 3)

        var grid = Path()
        var g = 0.1
        while g < 1.0 {
            grid.move(to: place(CGPoint(x: g, y: 0), rect))
            grid.addLine(to: place(CGPoint(x: g, y: 1), rect))
            grid.move(to: place(CGPoint(x: 0, y: g), rect))
            grid.addLine(to: place(CGPoint(x: 1, y: g), rect))
            g += 0.1
        }
        ctx.stroke(grid, with: .color(Ink.pencil.opacity(0.18)), lineWidth: 0.6)

        if stage != .plot {
            var pencil = Path()
            let pts = segment.map { place($0, rect) }
            pencil.move(to: pts[0])
            for p in pts.dropFirst() { pencil.addLine(to: p) }
            ctx.stroke(pencil, with: .color(Ink.pencil.opacity(0.55)),
                       style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
        }

        for (i, s) in stations.enumerated() {
            let p = place(s, rect)
            var mark = Path()
            mark.move(to: CGPoint(x: p.x - 8, y: p.y))
            mark.addLine(to: CGPoint(x: p.x + 8, y: p.y))
            mark.move(to: CGPoint(x: p.x, y: p.y - 8))
            mark.addLine(to: CGPoint(x: p.x, y: p.y + 8))
            ctx.stroke(mark, with: .color(Ink.oxblood), lineWidth: 2)
            var ring = Path()
            ring.addEllipse(in: CGRect(x: p.x - 12, y: p.y - 12, width: 24, height: 24))
            ctx.stroke(ring, with: .color(Ink.oxblood.opacity(0.8)), lineWidth: 1.2)
            ctx.draw(Text(i == 0 ? "A" : "B").font(Rule.title(13)).foregroundColor(Ink.oxblood),
                     at: CGPoint(x: p.x + 20, y: p.y - 14))
        }

        if stage == .plot || stage == .ink || stage == .hachure || stage == .letter
            || stage == .sound || stage == .done {
            for (si, station) in stations.enumerated() {
                guard marks.indices.contains(si) else { continue }
                for b in marks[si] {
                    let rad = b * Double.pi / 180
                    let from = place(station, rect)
                    let to = CGPoint(x: from.x + CGFloat(sin(rad)) * rect.width * 1.4,
                                     y: from.y - CGFloat(cos(rad)) * rect.width * 1.4)
                    var ray = Path()
                    ray.move(to: from)
                    ray.addLine(to: to)
                    ctx.stroke(ray, with: .color(Ink.pencil.opacity(0.45)), lineWidth: 0.8)
                }
            }
            for (i, f) in fixes.enumerated() {
                let p = place(f, rect)
                var dot = Path()
                dot.addEllipse(in: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8))
                ctx.fill(dot, with: .color(Ink.line))
                if landmarks.indices.contains(i) {
                    let truth = place(landmarks[i].at, rect)
                    var err = Path()
                    err.move(to: p)
                    err.addLine(to: truth)
                    ctx.stroke(err, with: .color(Ink.carmine.opacity(0.6)),
                               style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    ctx.draw(Text(landmarks[i].name).font(Rule.italic(11))
                                .foregroundColor(Ink.lineSoft),
                             at: CGPoint(x: p.x, y: p.y - 14))
                }
            }
        }

        if !coastStroke.isEmpty {
            let pts = coastStroke.map { place($0, rect) }
            var line = Path()
            line.move(to: pts[0])
            for p in pts.dropFirst() { line.addLine(to: p) }
            ctx.stroke(line, with: .color(Ink.line),
                       style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
        }

        if stage == .hachure || stage == .letter || stage == .sound || stage == .done {
            for (i, hill) in hills.enumerated() {
                let c = place(hill.0, rect)
                var ring = Path()
                ring.addEllipse(in: CGRect(x: c.x - CGFloat(hill.1) * rect.width,
                                           y: c.y - CGFloat(hill.1) * rect.height,
                                           width: CGFloat(hill.1) * 2 * rect.width,
                                           height: CGFloat(hill.1) * 2 * rect.height))
                ctx.stroke(ring, with: .color(i == hillIndex && stage == .hachure
                                              ? Ink.oxblood.opacity(0.6)
                                              : Ink.pencil.opacity(0.35)),
                           style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
        }

        for stroke in hachureStrokes + [currentStroke] {
            guard stroke.count > 1 else { continue }
            let pts = stroke.map { place($0, rect) }
            var line = Path()
            line.move(to: pts[0])
            for p in pts.dropFirst() { line.addLine(to: p) }
            ctx.stroke(line, with: .color(Ink.line.opacity(0.85)),
                       style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
        }

        if !nameCurve.isEmpty {
            let pts = nameCurve.map { place($0, rect) }
            var guideLine = Path()
            guideLine.move(to: pts[0])
            for p in pts.dropFirst() { guideLine.addLine(to: p) }
            ctx.stroke(guideLine, with: .color(Ink.pencil.opacity(0.4)), lineWidth: 0.8)
            let word = Array(ground.name.uppercased())
            for (i, ch) in word.enumerated() {
                let t = Double(i) / Double(max(1, word.count - 1))
                let idx = min(pts.count - 1, Int(t * Double(pts.count - 1)))
                let p = pts[idx]
                var angle = 0.0
                if idx + 1 < pts.count {
                    angle = atan2(Double(pts[idx + 1].y - p.y), Double(pts[idx + 1].x - p.x))
                }
                ctx.drawLayer { layer in
                    layer.translateBy(x: p.x, y: p.y)
                    layer.rotate(by: .radians(angle))
                    layer.draw(Text(String(ch)).font(Rule.italic(15)).foregroundColor(Ink.line),
                               at: .zero)
                }
            }
        }

        if stage == .sound || stage == .done {
            for (i, mark) in ground.soundingMarks.enumerated() {
                let p = place(mark, rect)
                if soundingsDone[i] {
                    ctx.draw(Text("\(ground.depth(at: mark))").font(Rule.italic(14))
                                .foregroundColor(Ink.line),
                             at: p)
                } else {
                    var cross = Path()
                    cross.move(to: CGPoint(x: p.x - 5, y: p.y))
                    cross.addLine(to: CGPoint(x: p.x + 5, y: p.y))
                    cross.move(to: CGPoint(x: p.x, y: p.y - 5))
                    cross.addLine(to: CGPoint(x: p.x, y: p.y + 5))
                    ctx.stroke(cross, with: .color(Ink.carmine.opacity(0.7)), lineWidth: 1.4)
                }
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch stage {
            case .brief:
                stageText("The ground", ground.blurb)
                HStack(spacing: 10) {
                    FigureChip(value: "\(marksNeeded * 2)", label: "angles")
                    FigureChip(value: "\(hills.count)", label: "hills")
                    FigureChip(value: "\(ground.soundingMarks.count)", label: "soundings")
                }
                WideDrawButton(title: "Go to station A", tint: Ink.oxblood) {
                    stage = .bearings
                    stationIndex = 0
                    targetIndex = 0
                    heading = bearing(from: stations[0], to: landmarks[0].at) - 24
                }
            case .bearings:
                stageText("Bring \(landmarks[min(targetIndex, landmarks.count - 1)].name) onto the wire",
                          "Pan the horizon with your finger until the object sits on the red wire, then take the angle.")
                HStack(spacing: 10) {
                    FigureChip(value: String(format: "%.1f", heading), label: "reading")
                    FigureChip(value: "\(marks[stationIndex].count)/\(marksNeeded)", label: "taken")
                }
                WideDrawButton(title: "Take the angle", tint: Ink.oxblood) { takeMark() }
            case .plot:
                stageText("The fixes are plotted",
                          fixError < 0.02 ? "Tight intersections. The framework will hold."
                          : "The rays cross wide. Every detail hung on this will be out by the same amount.")
                HStack(spacing: 10) {
                    FigureChip(value: String(format: "%.0f", fixError * 1000), label: "error")
                    FigureChip(value: "\(fixes.count)", label: "points fixed")
                }
                WideDrawButton(title: "Ink the coast", tint: Ink.oxblood) { stage = .ink }
            case .ink:
                stageText("Ink the coastline",
                          "Draw one steady line along the pencil. A ruling pen does not stop and start.")
                HStack(spacing: 10) {
                    FigureChip(value: "\(Int(inkScore * 100))", label: "line")
                    FigureChip(value: String(format: "%.0f", inkMean * 1000), label: "drift")
                }
                HStack(spacing: 10) {
                    SmallDrawButton(title: "Wipe it") { coastStroke = []; inkScore = 0 }
                    WideDrawButton(title: "Hachure the hills", tint: Ink.oxblood,
                                   enabled: inkScore > 0) { stage = .hachure }
                }
            case .hachure:
                stageText("Hachures down the slope",
                          "Short strokes running straight down the fall of the ground, out from the summit. Eight will do for this hill.")
                HStack(spacing: 10) {
                    FigureChip(value: "\(hachureStrokes.count)", label: "strokes")
                    FigureChip(value: "\(hillIndex + 1)/\(hills.count)", label: "hill")
                }
                WideDrawButton(title: hillIndex + 1 < hills.count ? "Next hill" : "Letter the sheet",
                               tint: Ink.oxblood, enabled: hachureStrokes.count >= 6) { nextHill() }
            case .letter:
                stageText("Write the name",
                          "Drag a curve that follows the coast without touching it. The letters will run along whatever you draw.")
                HStack(spacing: 10) {
                    FigureChip(value: "\(Int(letterScore * 100))", label: "placing")
                }
                HStack(spacing: 10) {
                    SmallDrawButton(title: "Again") { nameCurve = []; letterScore = 0 }
                    WideDrawButton(title: "Put in the soundings", tint: Ink.oxblood,
                                   enabled: letterScore > 0) { stage = .sound }
                }
            case .sound:
                stageText("Prick the soundings",
                          "Touch each surveyed position and the figure is written beside it.")
                FigureChip(value: "\(soundingsDone.filter { $0 }.count)/\(soundingsDone.count)",
                           label: "entered")
                WideDrawButton(title: "Finish the sheet", tint: Ink.oxblood,
                               enabled: soundingsDone.allSatisfy { $0 }) { finish() }
            case .done:
                stageText("Finished", "The sheet is in the portfolio.")
            }
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DeskLayer(name: "bg_card", fallback: Ink.paperWarm)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func takeMark() {
        guard targetIndex < landmarks.count else { return }
        marks[stationIndex].append(heading)
        Tap.firm()
        targetIndex += 1
        if targetIndex >= landmarks.count {
            if stationIndex == 0 {
                stationIndex = 1
                targetIndex = 0
                heading = bearing(from: stations[1], to: landmarks[0].at) - 30
            } else {
                computeFixes()
                stage = .plot
            }
        } else {
            heading += Double.random(in: -1 ... 1) * 0 + 0
        }
    }

    private func computeFixes() {
        var out: [CGPoint] = []
        var errors: [Double] = []
        for i in 0..<landmarks.count {
            guard marks[0].indices.contains(i), marks[1].indices.contains(i) else { continue }
            if let p = intersectRays(from: stations, bearings: [marks[0][i], marks[1][i]]) {
                out.append(p)
                let dx = Double(p.x - landmarks[i].at.x), dy = Double(p.y - landmarks[i].at.y)
                errors.append((dx * dx + dy * dy).squareRoot())
            }
        }
        fixes = out
        fixError = errors.isEmpty ? 0.3 : errors.reduce(0, +) / Double(errors.count)
    }

    private func nextHill() {
        hachureScores.append(hachureScore(strokes: hachureStrokes,
                                          hill: hills[hillIndex].0, radius: hills[hillIndex].1))
        if hillIndex + 1 < hills.count {
            hillIndex += 1
            hachureStrokes = []
        } else {
            stage = .letter
        }
    }

    private func finish() {
        let fixScore = max(0, min(1, 1 - fixError / 0.09))
        let hachureAverage = hachureScores.isEmpty ? 0
            : hachureScores.reduce(0, +) / Double(hachureScores.count)
        let soundScore = max(0, min(1, 1 - soundingError / 0.22))
        let res = SurveyResult(fix: fixScore, ink: inkScore, hachure: hachureAverage,
                               lettering: letterScore, soundings: soundScore,
                               marks: marks[0].count + marks[1].count)
        result = res
        let record = ChartRecord(groundId: ground.id, day: Orders.dayIndex(), grade: res.grade,
                                 overall: res.overall, fix: fixScore, ink: inkScore,
                                 hachure: hachureAverage, lettering: letterScore,
                                 soundings: soundScore,
                                 coastStrokes: [flatten(coastStroke)],
                                 hachureStrokes: hachureStrokes.map { flatten($0) },
                                 nameCurve: flatten(nameCurve),
                                 fixes: flatten(fixes))
        improved = store.finish(ground: ground, result: res, record: record, order: order)
        stage = .done
        Tap.heavy()
    }

    private func stageText(_ title: String, _ note: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(Rule.title(18)).foregroundColor(Ink.line)
            Text(note).font(Rule.body(14)).foregroundColor(Ink.lineSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private var finishOverlay: some View {
        if stage == .done, let r = result {
            ZStack {
                Color.black.opacity(0.58).ignoresSafeArea()
                    .onTapGesture { onClose() }
                VStack {
                    Spacer(minLength: 0)
                    PaperCard(padding: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ground.name).font(Rule.title(19)).foregroundColor(Ink.line)
                                    Text(improved ? "Bound into the portfolio"
                                         : "Your earlier sheet is still the better one")
                                        .font(Rule.italic(13)).foregroundColor(Ink.lineSoft)
                                }
                                Spacer()
                                ChartBadge(grade: r.grade, tint: chartTint(r.grade))
                            }
                            MeasureRow(label: "The fix", value: r.fix, tint: Ink.oxblood)
                            MeasureRow(label: "The line", value: r.ink, tint: Ink.line)
                            MeasureRow(label: "Hachures", value: r.hachure, tint: Ink.sepia)
                            MeasureRow(label: "Lettering", value: r.lettering, tint: Ink.verdigris)
                            MeasureRow(label: "Soundings", value: r.soundings, tint: Ink.seaDeep)
                            if let o = order, o.ground.id == ground.id {
                                NoteBanner(title: Int((r.overall * 100).rounded()) >= o.target
                                            ? "The commission is met" : "Short of the commission",
                                           detail: "They asked for \(o.target) out of a hundred; this sheet is \(Int((r.overall * 100).rounded())).",
                                           tint: Int((r.overall * 100).rounded()) >= o.target
                                            ? Ink.moss : Ink.oxblood)
                            }
                            HStack(spacing: 10) {
                                FigureChip(value: "+\(r.points)", label: "points", onPaper: true)
                                FigureChip(value: "\(r.marks)", label: "angles", onPaper: true)
                            }
                            WideDrawButton(title: "Back to the office", tint: Ink.oxblood) { onClose() }
                        }
                    }
                    .padding(.horizontal, 18)
                    Spacer(minLength: 0)
                }
                .centreColumn()
            }
        }
    }
}
