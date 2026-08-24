import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var store: InkStore
    @State private var selected: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("THE PORTFOLIO").font(Rule.title(11)).tracking(3.2)
                        .foregroundColor(Ink.brass)
                    Text("Your sheets").font(Rule.title(24)).foregroundColor(Ink.paper)
                    Text("Every chart is drawn from your own angles, your own line and your own lettering. Only the best sheet of each ground is kept.")
                        .font(Rule.italic(14)).foregroundColor(Ink.paper.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 10) {
                    FigureChip(value: "\(store.chartCount)/\(GroundBook.all.count)",
                               label: "sheets", tint: Ink.oxblood, onPaper: false)
                    FigureChip(value: "\(store.topGrades)", label: "first class",
                               tint: Ink.verdigris, onPaper: false)
                    FigureChip(value: "\(store.bestStreak)", label: "best streak",
                               tint: Ink.brass, onPaper: false)
                }

                if store.chartCount == 0 {
                    NoteBanner(title: "The portfolio is empty",
                               detail: "Survey any ground and the finished sheet is bound in here with your own coastline on it.",
                               tint: Ink.oxblood)
                }

                grid

                if !store.orders.isEmpty {
                    PaperCard {
                        VStack(alignment: .leading, spacing: 8) {
                            RuledHead(title: "The order book",
                                      note: "\(store.orders.filter { $0.met }.count) of \(store.orders.count) accepted")
                            ForEach(store.orders.suffix(8).reversed(), id: \.day) { rec in
                                HStack(spacing: 10) {
                                    Text("Day \(rec.day)").font(Rule.figure(12))
                                        .foregroundColor(Ink.linePale)
                                        .frame(width: 62, alignment: .leading)
                                    Text(GroundBook.ground(rec.groundId)?.name ?? rec.groundId)
                                        .font(Rule.body(13)).foregroundColor(Ink.lineSoft)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                    Text("\(Int((rec.overall * 100).rounded()))/\(rec.target)")
                                        .font(Rule.figure(12))
                                        .foregroundColor(rec.met ? Ink.moss : Ink.oxblood)
                                }
                            }
                        }
                    }
                }
                Color.clear.frame(height: 12)
            }
            .padding(.horizontal, Board.gutter)
            .padding(.top, 8)
            .centreColumn()
        }
        .deskPage()
        .navigationBarHidden(true)
        .sheet(isPresented: Binding(get: { selected != nil },
                                    set: { if !$0 { selected = nil } })) {
            if let id = selected, let ground = GroundBook.ground(id) {
                SheetDetail(ground: ground, record: store.record(for: id)) { selected = nil }
                    .environmentObject(store)
            }
        }
    }

    private var grid: some View {
        let columns = Board.isPad ? 3 : 2
        let rows = (GroundBook.all.count + columns - 1) / columns
        return VStack(spacing: 10) {
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 10) {
                    ForEach(0..<columns, id: \.self) { c in
                        let index = r * columns + c
                        if index < GroundBook.all.count {
                            slot(GroundBook.all[index])
                        } else {
                            Color.clear.frame(maxWidth: .infinity).frame(height: 120)
                        }
                    }
                }
            }
        }
    }

    private func slot(_ ground: Ground) -> some View {
        let record = store.record(for: ground.id)
        return Button(action: { Tap.light(); selected = ground.id }) {
            VStack(spacing: 5) {
                DrawnChart(ground: ground, record: record)
                    .frame(height: 132)
                Text(ground.name).font(Rule.body(10))
                    .foregroundColor(Ink.paper.opacity(0.75))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct DrawnChart: View {
    let ground: Ground
    let record: ChartRecord?

    var body: some View {
        Canvas { ctx, size in
            let rect = CGRect(origin: .zero, size: size)
            var paper = Path()
            paper.addRect(rect)
            ctx.fill(paper, with: .color(record != nil ? Ink.paper : Ink.paperSunk.opacity(0.45)))

            func place(_ p: CGPoint) -> CGPoint {
                CGPoint(x: rect.minX + p.x * rect.width, y: rect.minY + p.y * rect.height)
            }

            var grid = Path()
            var g = 0.2
            while g < 1 {
                grid.move(to: place(CGPoint(x: g, y: 0)))
                grid.addLine(to: place(CGPoint(x: g, y: 1)))
                grid.move(to: place(CGPoint(x: 0, y: g)))
                grid.addLine(to: place(CGPoint(x: 1, y: g)))
                g += 0.2
            }
            ctx.stroke(grid, with: .color(Ink.pencil.opacity(0.16)), lineWidth: 0.5)

            if let rec = record {
                for raw in rec.coastStrokes {
                    let pts = unflatten(raw).map(place)
                    guard pts.count > 1 else { continue }
                    var line = Path()
                    line.move(to: pts[0])
                    for p in pts.dropFirst() { line.addLine(to: p) }
                    ctx.stroke(line, with: .color(Ink.line),
                               style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                }
                for raw in rec.hachureStrokes {
                    let pts = unflatten(raw).map(place)
                    guard pts.count > 1 else { continue }
                    var line = Path()
                    line.move(to: pts[0])
                    for p in pts.dropFirst() { line.addLine(to: p) }
                    ctx.stroke(line, with: .color(Ink.line.opacity(0.8)), lineWidth: 1.2)
                }
                let curve = unflatten(rec.nameCurve).map(place)
                if curve.count > 2 {
                    let word = Array(ground.name.uppercased())
                    for (i, ch) in word.enumerated() {
                        let t = Double(i) / Double(max(1, word.count - 1))
                        let idx = min(curve.count - 1, Int(t * Double(curve.count - 1)))
                        ctx.draw(Text(String(ch)).font(Rule.italic(7)).foregroundColor(Ink.line),
                                 at: curve[idx])
                    }
                }
                for p in unflatten(rec.fixes).map(place) {
                    var dot = Path()
                    dot.addEllipse(in: CGRect(x: p.x - 2, y: p.y - 2, width: 4, height: 4))
                    ctx.fill(dot, with: .color(Ink.oxblood))
                }
                for mark in ground.soundingMarks {
                    ctx.draw(Text("\(ground.depth(at: mark))").font(Rule.italic(7))
                                .foregroundColor(Ink.lineSoft),
                             at: place(mark))
                }
            } else {
                let pts = ground.coastSegment.map(place)
                var pencil = Path()
                pencil.move(to: pts[0])
                for p in pts.dropFirst() { pencil.addLine(to: p) }
                ctx.stroke(pencil, with: .color(Ink.pencil.opacity(0.45)),
                           style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous)
            .stroke(record != nil ? Ink.brass.opacity(0.6) : Color.white.opacity(0.12),
                    lineWidth: 1))
    }
}

struct SheetDetail: View {
    let ground: Ground
    let record: ChartRecord?
    let onClose: () -> Void

    @EnvironmentObject var store: InkStore
    @State private var running = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ground.name).font(Rule.title(20)).foregroundColor(Ink.paper)
                        Text("\(ground.place) · \(ground.year)")
                            .font(Rule.italic(13)).foregroundColor(Ink.paper.opacity(0.7))
                    }
                    Spacer()
                    Button(action: { Tap.light(); onClose() }) {
                        CrossGlyph(size: 16, color: Ink.paper)
                            .padding(9).background(Circle().fill(Color.white.opacity(0.14)))
                    }
                    .buttonStyle(.plain)
                }

                DrawnChart(ground: ground, record: record)
                    .frame(height: 340)

                if let rec = record {
                    PaperCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                RuledHead(title: "As you drew it", note: "Day \(rec.day)")
                                Spacer()
                                ChartBadge(grade: rec.grade, tint: chartTint(rec.grade))
                            }
                            MeasureRow(label: "The fix", value: rec.fix, tint: Ink.oxblood)
                            MeasureRow(label: "The line", value: rec.ink, tint: Ink.line)
                            MeasureRow(label: "Hachures", value: rec.hachure, tint: Ink.sepia)
                            MeasureRow(label: "Lettering", value: rec.lettering, tint: Ink.verdigris)
                            MeasureRow(label: "Soundings", value: rec.soundings, tint: Ink.seaDeep)
                            Text("The wobble in this coast is your own hand. Survey it again and the portfolio keeps whichever sheet is better.")
                                .font(Rule.italic(12)).foregroundColor(Ink.linePale)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else {
                    NoteBanner(title: "Nothing drawn yet",
                               detail: "The dotted line is the pencil coast waiting for ink.",
                               tint: Ink.linePale)
                }

                WideDrawButton(title: record == nil ? "Survey it" : "Survey it again",
                               tint: Ink.oxblood) { running = true }
                Color.clear.frame(height: 16)
            }
            .padding(.horizontal, Board.gutter)
            .padding(.top, 14)
            .centreColumn()
        }
        .deskPage()
        .fullScreenCover(isPresented: $running) {
            SurveyView(ground: ground, order: nil) { running = false }
                .environmentObject(store)
        }
    }
}
