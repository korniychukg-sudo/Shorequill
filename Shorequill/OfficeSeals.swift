import SwiftUI

struct OfficeSeal: Identifiable {
    let id: String
    let title: String
    let note: String
    let emblem: String
    let test: (InkStore) -> Bool
}

enum SealBoard {
    static let all: [OfficeSeal] = setA + setB

    private static let setA: [OfficeSeal] = [
        OfficeSeal(id: "first_sheet", title: "The First Sheet",
                   note: "Carry one ground from bearings to soundings and bind the sheet. The office keeps a copy of everything, including the bad ones.",
                   emblem: "theodolite") { $0.surveys >= 1 },
        OfficeSeal(id: "tight_fix", title: "A Tight Fix",
                   note: "Ninety-two for the fix. Three rays crossing in a point you could cover with a pin head.",
                   emblem: "plumb") { store in store.charts.values.contains { $0.fix >= 0.92 } },
        OfficeSeal(id: "one_line", title: "One Steady Line",
                   note: "Ninety-two for the line. A ruling pen laid down at the headland and lifted at the point.",
                   emblem: "rulingpen") { store in store.charts.values.contains { $0.ink >= 0.92 } },
        OfficeSeal(id: "good_hill", title: "The Hill Reads",
                   note: "Ninety-two for hachures. Steep where it is steep, open where the ground eases, and no strokes crossing.",
                   emblem: "hachure") { store in store.charts.values.contains { $0.hachure >= 0.92 } },
        OfficeSeal(id: "fair_letter", title: "A Fair Hand",
                   note: "Ninety-two for lettering. The name follows the coast without being cramped into a bay.",
                   emblem: "letter") { store in store.charts.values.contains { $0.lettering >= 0.92 } },
        OfficeSeal(id: "leadline", title: "The Lead Line",
                   note: "Ninety-two for soundings. Every figure sits where the lead actually went down.",
                   emblem: "sounding") { store in store.charts.values.contains { $0.soundings >= 0.92 } },
        OfficeSeal(id: "first_a", title: "Passed A",
                   note: "One sheet passed A by the office. It goes to the engraver as drawn.",
                   emblem: "star") { store in store.charts.values.contains { $0.grade == "A" } },
        OfficeSeal(id: "hundred_marks", title: "A Hundred Angles",
                   note: "A hundred angles taken at the instrument. The wire stops swimming somewhere around sixty.",
                   emblem: "chain") { $0.marksTaken >= 100 },
    ]

    private static let setB: [OfficeSeal] = [
        OfficeSeal(id: "three_days", title: "Three Days in the Field",
                   note: "Three days running. Survey is a season's work done one morning at a time.",
                   emblem: "streak") { $0.bestStreak >= 3 },
        OfficeSeal(id: "fortnight", title: "A Fortnight",
                   note: "Fourteen days running. The board knows your hand on sight now.",
                   emblem: "calendar") { $0.bestStreak >= 14 },
        OfficeSeal(id: "miles", title: "Two Hundred Miles",
                   note: "Two hundred miles of coast inked. Most of it in weather nobody would choose.",
                   emblem: "rose") { $0.milesInked >= 200 },
        OfficeSeal(id: "half_folio", title: "Half the Folio",
                   note: "Twelve grounds surveyed and bound, from estuary flats to a rock in the offing.",
                   emblem: "sheets") { $0.chartCount >= 12 },
        OfficeSeal(id: "whole_folio", title: "The Whole Folio",
                   note: "Every ground in the district drawn, each sheet the best you have made of it.",
                   emblem: "atlas") { $0.chartCount >= GroundBook.all.count },
        OfficeSeal(id: "office_read", title: "The Office Read",
                   note: "All twelve plates opened. Triangulation, hachuring, lettering and the lead.",
                   emblem: "book") { $0.plateRead.count >= 12 },
        OfficeSeal(id: "drill_hand", title: "The Instrument Hand",
                   note: "Twenty short rounds at the theodolite. It is the same skill as the survey, cut down to ten minutes.",
                   emblem: "compass") { $0.drills >= 20 },
        OfficeSeal(id: "hydrographer", title: "The Hydrographer's Seal",
                   note: "Six thousand points on the office roll. Your name goes in the margin of the printed chart.",
                   emblem: "medal") { $0.points >= 6000 },
    ]
}

struct SealEmblem: View {
    let kind: String
    let earned: Bool
    var size: CGFloat = 74

    private var line: Color { earned ? Ink.line : Ink.linePale.opacity(0.40) }
    private var red: Color { earned ? Ink.oxblood : Ink.linePale.opacity(0.34) }
    private var brass: Color { earned ? Ink.brass : Ink.linePale.opacity(0.30) }
    private var blue: Color { earned ? Ink.seaDeep : Ink.linePale.opacity(0.28) }

    var body: some View {
        Canvas { ctx, s in
            draw(&ctx, s)
        }
        .frame(width: size, height: size)
    }

    private func draw(_ ctx: inout GraphicsContext, _ s: CGSize) {
        let w = s.width, h = s.height
        var field = Path()
        field.addRoundedRect(in: CGRect(origin: .zero, size: s),
                             cornerSize: CGSize(width: w * 0.13, height: w * 0.13))
        ctx.fill(field, with: .linearGradient(
            Gradient(colors: earned
                     ? [Ink.paperWarm, Ink.paperSunk]
                     : [Ink.paperSunk.opacity(0.55), Ink.paperSunk.opacity(0.3)]),
            startPoint: .zero, endPoint: CGPoint(x: w, y: h)))
        ctx.stroke(field, with: .color(earned ? Ink.oxblood.opacity(0.65) : Ink.hairline),
                   lineWidth: earned ? 2 : 1)
        var inner = Path()
        inner.addRoundedRect(in: CGRect(origin: .zero, size: s).insetBy(dx: w * 0.09, dy: w * 0.09),
                             cornerSize: CGSize(width: w * 0.07, height: w * 0.07))
        ctx.stroke(inner, with: .color(earned ? Ink.line.opacity(0.30) : Ink.hairline),
                   lineWidth: 1)

        switch kind {
        case "theodolite":
            var tripod = Path()
            tripod.move(to: CGPoint(x: w * 0.24, y: h * 0.84))
            tripod.addLine(to: CGPoint(x: w * 0.50, y: h * 0.50))
            tripod.addLine(to: CGPoint(x: w * 0.76, y: h * 0.84))
            tripod.move(to: CGPoint(x: w * 0.50, y: h * 0.50))
            tripod.addLine(to: CGPoint(x: w * 0.50, y: h * 0.84))
            ctx.stroke(tripod, with: .color(line), lineWidth: w * 0.045)
            var head = Path()
            head.addRect(CGRect(x: w * 0.34, y: h * 0.36, width: w * 0.32, height: h * 0.14))
            ctx.fill(head, with: .color(brass))
            ctx.stroke(head, with: .color(line), lineWidth: w * 0.03)
            var scope = Path()
            scope.move(to: CGPoint(x: w * 0.22, y: h * 0.30))
            scope.addLine(to: CGPoint(x: w * 0.80, y: h * 0.22))
            ctx.stroke(scope, with: .color(line), lineWidth: w * 0.075)
            var glass = Path()
            glass.addRect(CGRect(x: w * 0.72, y: h * 0.18, width: w * 0.10, height: h * 0.09))
            ctx.fill(glass, with: .color(blue))
        case "plumb":
            var cordPath = Path()
            cordPath.move(to: CGPoint(x: w * 0.50, y: h * 0.14))
            cordPath.addLine(to: CGPoint(x: w * 0.50, y: h * 0.52))
            ctx.stroke(cordPath, with: .color(line), lineWidth: w * 0.028)
            var bob = Path()
            bob.move(to: CGPoint(x: w * 0.50, y: h * 0.50))
            bob.addLine(to: CGPoint(x: w * 0.64, y: h * 0.62))
            bob.addLine(to: CGPoint(x: w * 0.50, y: h * 0.86))
            bob.addLine(to: CGPoint(x: w * 0.36, y: h * 0.62))
            bob.closeSubpath()
            ctx.fill(bob, with: .linearGradient(
                Gradient(colors: [brass, earned ? Ink.brassDark : Ink.linePale.opacity(0.25)]),
                startPoint: CGPoint(x: w * 0.36, y: h * 0.5),
                endPoint: CGPoint(x: w * 0.64, y: h * 0.86)))
            ctx.stroke(bob, with: .color(line), lineWidth: w * 0.028)
        case "rulingpen":
            var shaft = Path()
            shaft.move(to: CGPoint(x: w * 0.24, y: h * 0.80))
            shaft.addLine(to: CGPoint(x: w * 0.74, y: h * 0.24))
            ctx.stroke(shaft, with: .color(brass), lineWidth: w * 0.10)
            var nib = Path()
            nib.move(to: CGPoint(x: w * 0.16, y: h * 0.88))
            nib.addLine(to: CGPoint(x: w * 0.34, y: h * 0.74))
            nib.addLine(to: CGPoint(x: w * 0.26, y: h * 0.66))
            nib.closeSubpath()
            ctx.fill(nib, with: .color(line))
            var stroke = Path()
            stroke.move(to: CGPoint(x: w * 0.12, y: h * 0.92))
            stroke.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.86),
                                control: CGPoint(x: w * 0.50, y: h * 0.98))
            ctx.stroke(stroke, with: .color(red), lineWidth: w * 0.035)
        case "hachure":
            var ridge = Path()
            ridge.move(to: CGPoint(x: w * 0.16, y: h * 0.72))
            ridge.addLine(to: CGPoint(x: w * 0.40, y: h * 0.28))
            ridge.addLine(to: CGPoint(x: w * 0.62, y: h * 0.50))
            ridge.addLine(to: CGPoint(x: w * 0.84, y: h * 0.24))
            ctx.stroke(ridge, with: .color(line), lineWidth: w * 0.035)
            for i in 0..<9 {
                var t = Path()
                let x = w * (0.20 + Double(i) * 0.072)
                t.move(to: CGPoint(x: x, y: h * (0.74 - Double(abs(4 - i)) * 0.02)))
                t.addLine(to: CGPoint(x: x + w * 0.012, y: h * 0.88))
                ctx.stroke(t, with: .color(line.opacity(0.85)),
                           lineWidth: w * (i % 2 == 0 ? 0.035 : 0.022))
            }
        case "letter":
            var base = Path()
            base.move(to: CGPoint(x: w * 0.14, y: h * 0.70))
            base.addQuadCurve(to: CGPoint(x: w * 0.86, y: h * 0.58),
                              control: CGPoint(x: w * 0.50, y: h * 0.86))
            ctx.stroke(base, with: .color(line.opacity(0.35)), lineWidth: w * 0.02)
            for i in 0..<5 {
                var tick = Path()
                let x = w * (0.20 + Double(i) * 0.15)
                let y = h * (0.68 - Double(i) * 0.02)
                tick.move(to: CGPoint(x: x, y: y))
                tick.addLine(to: CGPoint(x: x + w * 0.02, y: y - h * 0.20))
                tick.addLine(to: CGPoint(x: x + w * 0.09, y: y - h * 0.02))
                ctx.stroke(tick, with: .color(red), lineWidth: w * 0.030)
            }
        case "sounding":
            var wave = Path()
            wave.move(to: CGPoint(x: w * 0.12, y: h * 0.30))
            wave.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.30),
                              control: CGPoint(x: w * 0.31, y: h * 0.20))
            wave.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.30),
                              control: CGPoint(x: w * 0.69, y: h * 0.40))
            ctx.stroke(wave, with: .color(blue), lineWidth: w * 0.035)
            var cordPath = Path()
            cordPath.move(to: CGPoint(x: w * 0.50, y: h * 0.30))
            cordPath.addLine(to: CGPoint(x: w * 0.50, y: h * 0.64))
            ctx.stroke(cordPath, with: .color(line), lineWidth: w * 0.026)
            var lead = Path()
            lead.addRect(CGRect(x: w * 0.42, y: h * 0.64, width: w * 0.16, height: h * 0.22))
            ctx.fill(lead, with: .color(line))
            for i in 0..<3 {
                var mark = Path()
                let x = w * (0.18 + Double(i) * 0.28)
                mark.move(to: CGPoint(x: x, y: h * 0.50))
                mark.addLine(to: CGPoint(x: x + w * 0.06, y: h * 0.50))
                ctx.stroke(mark, with: .color(blue.opacity(0.8)), lineWidth: w * 0.022)
            }
        case "star":
            var star = Path()
            let cx: CGFloat = w * 0.5
            let cy: CGFloat = h * 0.52
            let outer: CGFloat = w * 0.28
            let innerR: CGFloat = w * 0.12
            for i in 0..<10 {
                let a = Double(i) * Double.pi / 5 - Double.pi / 2
                let r: CGFloat = i % 2 == 0 ? outer : innerR
                let p = CGPoint(x: cx + CGFloat(cos(a)) * r, y: cy + CGFloat(sin(a)) * r)
                if i == 0 { star.move(to: p) } else { star.addLine(to: p) }
            }
            star.closeSubpath()
            ctx.fill(star, with: .color(red))
            ctx.stroke(star, with: .color(line), lineWidth: w * 0.022)
        case "chain":
            for i in 0..<4 {
                var linkPath = Path()
                linkPath.addRoundedRect(in: CGRect(x: w * (0.12 + Double(i) * 0.19), y: h * 0.44,
                                                   width: w * 0.22, height: h * 0.14),
                                        cornerSize: CGSize(width: w * 0.07, height: h * 0.07))
                ctx.stroke(linkPath, with: .color(i % 2 == 0 ? brass : line), lineWidth: w * 0.032)
            }
        case "streak":
            for i in 0..<3 {
                var bar = Path()
                let x = w * (0.22 + Double(i) * 0.22)
                bar.addRect(CGRect(x: x, y: h * (0.62 - Double(i) * 0.14),
                                   width: w * 0.14, height: h * (0.24 + Double(i) * 0.14)))
                ctx.fill(bar, with: .color(i == 2 ? red : line.opacity(0.7)))
            }
        case "calendar":
            var sheet = Path()
            sheet.addRect(CGRect(x: w * 0.18, y: h * 0.22, width: w * 0.64, height: h * 0.58))
            ctx.stroke(sheet, with: .color(line), lineWidth: w * 0.04)
            for r in 0..<3 {
                for c in 0..<4 {
                    var cell = Path()
                    cell.addRect(CGRect(x: w * (0.24 + Double(c) * 0.14),
                                        y: h * (0.32 + Double(r) * 0.15),
                                        width: w * 0.09, height: h * 0.09))
                    ctx.fill(cell, with: .color((r * 4 + c) % 3 == 0 ? red : line.opacity(0.35)))
                }
            }
        case "rose":
            var rose = Path()
            for i in 0..<8 {
                let a = Double(i) * Double.pi / 4
                let rx: CGFloat = w * 0.50 + CGFloat(cos(a)) * w * 0.30
                let ry: CGFloat = h * 0.52 + CGFloat(sin(a)) * w * 0.30
                rose.move(to: CGPoint(x: w * 0.50, y: h * 0.52))
                rose.addLine(to: CGPoint(x: rx, y: ry))
            }
            ctx.stroke(rose, with: .color(line.opacity(0.55)), lineWidth: w * 0.022)
            var north = Path()
            north.move(to: CGPoint(x: w * 0.50, y: h * 0.16))
            north.addLine(to: CGPoint(x: w * 0.58, y: h * 0.52))
            north.addLine(to: CGPoint(x: w * 0.50, y: h * 0.66))
            north.addLine(to: CGPoint(x: w * 0.42, y: h * 0.52))
            north.closeSubpath()
            ctx.fill(north, with: .color(red))
        case "sheets":
            for i in 0..<3 {
                var sheet = Path()
                let off = Double(i) * 0.07
                sheet.addRect(CGRect(x: w * (0.16 + off), y: h * (0.20 + off),
                                     width: w * 0.54, height: h * 0.54))
                ctx.fill(sheet, with: .color(earned ? Ink.paperWarm : Ink.paperSunk.opacity(0.4)))
                ctx.stroke(sheet, with: .color(line.opacity(0.8)), lineWidth: w * 0.028)
            }
            var coast = Path()
            coast.move(to: CGPoint(x: w * 0.34, y: h * 0.70))
            coast.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.44),
                               control: CGPoint(x: w * 0.48, y: h * 0.40))
            ctx.stroke(coast, with: .color(blue), lineWidth: w * 0.03)
        case "atlas":
            var cover = Path()
            cover.addRect(CGRect(x: w * 0.18, y: h * 0.16, width: w * 0.64, height: h * 0.68))
            ctx.fill(cover, with: .color(red))
            ctx.stroke(cover, with: .color(line), lineWidth: w * 0.03)
            var spine = Path()
            spine.addRect(CGRect(x: w * 0.18, y: h * 0.16, width: w * 0.10, height: h * 0.68))
            ctx.fill(spine, with: .color(earned ? Ink.sepia : Ink.linePale.opacity(0.3)))
            var label = Path()
            label.addRect(CGRect(x: w * 0.36, y: h * 0.32, width: w * 0.36, height: h * 0.20))
            ctx.fill(label, with: .color(brass))
            ctx.stroke(label, with: .color(line), lineWidth: w * 0.02)
        case "book":
            var left = Path()
            left.move(to: CGPoint(x: w * 0.12, y: h * 0.30))
            left.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.34),
                              control: CGPoint(x: w * 0.30, y: h * 0.24))
            left.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
            left.addQuadCurve(to: CGPoint(x: w * 0.12, y: h * 0.72),
                              control: CGPoint(x: w * 0.30, y: h * 0.70))
            left.closeSubpath()
            var right = Path()
            right.move(to: CGPoint(x: w * 0.88, y: h * 0.30))
            right.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.34),
                               control: CGPoint(x: w * 0.70, y: h * 0.24))
            right.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
            right.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.72),
                               control: CGPoint(x: w * 0.70, y: h * 0.70))
            right.closeSubpath()
            ctx.fill(left, with: .color(earned ? Ink.paperWarm : Ink.paperSunk.opacity(0.35)))
            ctx.fill(right, with: .color(earned ? Ink.paper : Ink.paperSunk.opacity(0.25)))
            ctx.stroke(left, with: .color(line), lineWidth: w * 0.028)
            ctx.stroke(right, with: .color(line), lineWidth: w * 0.028)
        case "compass":
            var legA = Path()
            legA.move(to: CGPoint(x: w * 0.50, y: h * 0.18))
            legA.addLine(to: CGPoint(x: w * 0.26, y: h * 0.84))
            var legB = Path()
            legB.move(to: CGPoint(x: w * 0.50, y: h * 0.18))
            legB.addLine(to: CGPoint(x: w * 0.74, y: h * 0.84))
            ctx.stroke(legA, with: .color(brass), lineWidth: w * 0.075)
            ctx.stroke(legB, with: .color(line), lineWidth: w * 0.075)
            var head = Path()
            head.addRect(CGRect(x: w * 0.42, y: h * 0.12, width: w * 0.16, height: h * 0.10))
            ctx.fill(head, with: .color(line))
            var arc = Path()
            arc.move(to: CGPoint(x: w * 0.24, y: h * 0.88))
            arc.addQuadCurve(to: CGPoint(x: w * 0.76, y: h * 0.88),
                             control: CGPoint(x: w * 0.50, y: h * 0.76))
            ctx.stroke(arc, with: .color(red.opacity(0.7)), lineWidth: w * 0.025)
        default:
            var ribbon = Path()
            ribbon.move(to: CGPoint(x: w * 0.34, y: h * 0.14))
            ribbon.addLine(to: CGPoint(x: w * 0.66, y: h * 0.14))
            ribbon.addLine(to: CGPoint(x: w * 0.62, y: h * 0.42))
            ribbon.addLine(to: CGPoint(x: w * 0.38, y: h * 0.42))
            ribbon.closeSubpath()
            ctx.fill(ribbon, with: .color(red))
            var plate = Path()
            plate.move(to: CGPoint(x: w * 0.50, y: h * 0.34))
            plate.addLine(to: CGPoint(x: w * 0.80, y: h * 0.58))
            plate.addLine(to: CGPoint(x: w * 0.50, y: h * 0.86))
            plate.addLine(to: CGPoint(x: w * 0.20, y: h * 0.58))
            plate.closeSubpath()
            ctx.fill(plate, with: .linearGradient(
                Gradient(colors: [brass, earned ? Ink.brassDark : Ink.linePale.opacity(0.25)]),
                startPoint: CGPoint(x: w * 0.2, y: h * 0.34),
                endPoint: CGPoint(x: w * 0.8, y: h * 0.86)))
            ctx.stroke(plate, with: .color(line), lineWidth: w * 0.024)
        }
    }
}

struct SealCaseView: View {
    @EnvironmentObject var store: InkStore
    @State private var selected: OfficeSeal?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PaperCard(padding: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    RuledHead(title: "The office seals",
                              note: "\(store.earnedSeals.count) of \(SealBoard.all.count) struck")
                    Text("The office stamps a seal on the folio for work already passed. They are struck against the sheet, not against the surveyor, and they stay struck.")
                        .font(Rule.body(13)).foregroundColor(Ink.lineSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    MeterLine(value: Double(store.earnedSeals.count) / Double(SealBoard.all.count),
                              tint: Ink.oxblood)
                }
            }

            let columns = Board.isPad ? 5 : 4
            let rows = (SealBoard.all.count + columns - 1) / columns
            VStack(spacing: 10) {
                ForEach(0..<rows, id: \.self) { r in
                    HStack(spacing: 10) {
                        ForEach(0..<columns, id: \.self) { c in
                            let index = r * columns + c
                            if index < SealBoard.all.count {
                                let seal = SealBoard.all[index]
                                Button(action: { Tap.light(); selected = seal }) {
                                    SealEmblem(kind: seal.emblem,
                                               earned: store.earnedSeals.contains(seal.id),
                                               size: Board.isPad ? 92 : 74)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Color.clear.frame(width: 74, height: 74)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: Binding(get: { selected != nil },
                                    set: { if !$0 { selected = nil } })) {
            if let seal = selected {
                SealSheet(seal: seal, earned: store.earnedSeals.contains(seal.id)) {
                    selected = nil
                }
            }
        }
    }
}

struct SealSheet: View {
    let seal: OfficeSeal
    let earned: Bool
    let onClose: () -> Void

    var body: some View {
        ZStack {
            DeskLayer(name: "bg_baize", fallback: Ink.baize).ignoresSafeArea()
            VStack(spacing: 18) {
                HStack {
                    Spacer()
                    Button(action: { Tap.light(); onClose() }) {
                        CrossGlyph(size: 16, color: Ink.bone)
                            .padding(9).background(Circle().fill(Color.black.opacity(0.22)))
                    }
                    .buttonStyle(.plain)
                }
                SealEmblem(kind: seal.emblem, earned: earned, size: 148)
                Text(seal.title).font(Rule.title(24)).foregroundColor(Ink.bone)
                    .multilineTextAlignment(.center)
                Text(seal.note).font(Rule.body(16)).foregroundColor(Ink.bone.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
                Text(earned ? "Struck on the folio" : "Not struck yet")
                    .font(Rule.italic(13))
                    .foregroundColor(earned ? Ink.sand : Ink.bone.opacity(0.5))
                Spacer()
                WideDrawButton(title: "Close", tint: Ink.oxblood) { onClose() }
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, Board.gutter)
            .padding(.top, 14)
            .centreColumn()
        }
    }
}

struct SealToast: View {
    let seal: OfficeSeal
    let onDismiss: () -> Void
    @State private var shown = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.58).ignoresSafeArea()
                .onTapGesture { onDismiss() }
            VStack(spacing: 14) {
                SealEmblem(kind: seal.emblem, earned: true, size: 120)
                    .scaleEffect(shown ? 1 : 0.7)
                    .rotationEffect(.degrees(shown ? 0 : -9))
                Text("A seal struck").font(Rule.title(12)).tracking(2.8)
                    .foregroundColor(Ink.sand)
                Text(seal.title).font(Rule.title(24)).foregroundColor(Ink.bone)
                    .multilineTextAlignment(.center)
                Text(seal.note).font(Rule.body(15)).foregroundColor(Ink.bone.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 26)
                SmallDrawButton(title: "Into the folio") { onDismiss() }
                    .padding(.top, 4)
            }
            .padding(.vertical, 26)
            .opacity(shown ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.62)) { shown = true }
            Tap.heavy()
        }
    }
}
