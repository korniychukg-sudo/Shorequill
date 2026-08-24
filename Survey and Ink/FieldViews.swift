import SwiftUI

struct FieldView: View {
    @EnvironmentObject var store: InkStore
    @State private var chosen: Ground?
    @State private var running = false

    private var day: Int { Orders.dayIndex() }
    private var order: Order { Orders.forDay(day) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("THE GROUND").font(Rule.title(11)).tracking(3.2).foregroundColor(Ink.brass)
                    Text("Choose a survey").font(Rule.title(24)).foregroundColor(Ink.paper)
                    Text("Twenty-four coasts. Take the angles, ink the coast, hachure the hills, letter the sheet and prick the soundings.")
                        .font(Rule.italic(14)).foregroundColor(Ink.paper.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }

                LiftIn(index: 0) {
                    FeltCard {
                        VStack(alignment: .leading, spacing: 8) {
                            RuledHead(title: "On the order book", note: order.title, tint: Ink.brass)
                            Text(order.ground.name).font(Rule.body(15))
                                .foregroundColor(Ink.paper)
                            WideDrawButton(title: "Set up on it", tint: Ink.oxblood) {
                                chosen = order.ground
                                running = true
                            }
                        }
                    }
                }

                ForEach(Array(GroundBook.all.enumerated()), id: \.element.id) { pair in
                    LiftIn(index: min(6, pair.offset)) { groundRow(pair.element) }
                }
                Color.clear.frame(height: 12)
            }
            .padding(.horizontal, Board.gutter)
            .padding(.top, 8)
            .centreColumn()
        }
        .deskPage()
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $running) {
            if let ground = chosen {
                SurveyView(ground: ground,
                           order: ground.id == order.ground.id ? order : nil) { running = false }
                    .environmentObject(store)
            } else {
                VStack(spacing: 14) {
                    Text("No ground chosen.").font(Rule.body(16)).foregroundColor(Ink.paper)
                    SmallDrawButton(title: "Back") { running = false }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .deskPage()
            }
        }
    }

    private func groundRow(_ ground: Ground) -> some View {
        Button(action: { Tap.light(); chosen = ground; running = true }) {
            PaperCard(padding: 11) {
                HStack(spacing: 12) {
                    PlateCard(name: ground.plate, height: 88).frame(width: 72)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ground.name).font(Rule.title(16)).foregroundColor(Ink.line)
                        Text("\(ground.place) · \(ground.year)")
                            .font(Rule.italic(12)).foregroundColor(Ink.linePale)
                        Text(ground.kind).font(Rule.body(12)).foregroundColor(Ink.lineSoft)
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { i in
                                Circle()
                                    .fill(i < ground.difficulty ? Ink.oxblood : Ink.paperSunk)
                                    .frame(width: 6, height: 6)
                            }
                            Text("ground").font(Rule.body(10)).foregroundColor(Ink.linePale)
                        }
                    }
                    Spacer(minLength: 0)
                    if let rec = store.record(for: ground.id) {
                        ChartBadge(grade: rec.grade, tint: chartTint(rec.grade))
                    } else {
                        AngleGlyph(size: 15, color: Ink.linePale)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct ChartsView: View {
    @EnvironmentObject var store: InkStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("THE CHARTS").font(Rule.title(11)).tracking(3.2).foregroundColor(Ink.brass)
                    Text("Twenty-four sheets").font(Rule.title(24)).foregroundColor(Ink.paper)
                    Text("The engraved fair copies, with what each one is trying to tell a master coming in at night.")
                        .font(Rule.italic(14)).foregroundColor(Ink.paper.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(Array(GroundBook.all.enumerated()), id: \.element.id) { pair in
                    LiftIn(index: min(6, pair.offset)) {
                        NavigationLink(destination: ChartDetail(ground: pair.element)
                                        .environmentObject(store)) {
                            PaperCard(padding: 11) {
                                VStack(alignment: .leading, spacing: 8) {
                                    PlateCard(name: pair.element.plate, height: 190)
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(pair.element.kicker.uppercased())
                                                .font(Rule.title(10)).tracking(2)
                                                .foregroundColor(Ink.oxblood)
                                            Text(pair.element.name).font(Rule.title(17))
                                                .foregroundColor(Ink.line)
                                            Text("\(pair.element.place) · \(pair.element.year)")
                                                .font(Rule.italic(12)).foregroundColor(Ink.linePale)
                                        }
                                        Spacer(minLength: 0)
                                        AngleGlyph(size: 15, color: Ink.linePale)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
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
    }
}

struct ChartDetail: View {
    let ground: Ground
    @EnvironmentObject var store: InkStore
    @State private var openPlate = false
    @State private var running = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(ground.kicker.uppercased()).font(Rule.title(11)).tracking(2.6)
                        .foregroundColor(Ink.brass)
                    Text(ground.name).font(Rule.title(25)).foregroundColor(Ink.paper)
                    Text("\(ground.place) · \(ground.year)")
                        .font(Rule.italic(14)).foregroundColor(Ink.paper.opacity(0.7))
                }
                Button(action: { Tap.light(); openPlate = true }) {
                    PlateCard(name: ground.plate, height: 330)
                }
                .buttonStyle(.plain)

                PaperCard {
                    VStack(alignment: .leading, spacing: 9) {
                        RuledHead(title: "What the sheet is about")
                        Text(ground.blurb).font(Rule.body(15)).foregroundColor(Ink.lineSoft)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 10) {
                            FigureChip(value: "\(ground.landmarks.count * 2)", label: "angles")
                            FigureChip(value: "\(ground.hills.count)", label: "hills",
                                       tint: Ink.sepia)
                            FigureChip(value: ground.kind, label: "ground", tint: Ink.verdigris)
                        }
                    }
                }

                if let rec = store.record(for: ground.id) {
                    PaperCard(tint: Ink.paperWarm) {
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                RuledHead(title: "Your sheet", note: "Day \(rec.day)")
                                Spacer()
                                ChartBadge(grade: rec.grade, tint: chartTint(rec.grade))
                            }
                            MeasureRow(label: "The fix", value: rec.fix, tint: Ink.oxblood)
                            MeasureRow(label: "The line", value: rec.ink, tint: Ink.line)
                            MeasureRow(label: "Hachures", value: rec.hachure, tint: Ink.sepia)
                            MeasureRow(label: "Lettering", value: rec.lettering, tint: Ink.verdigris)
                            MeasureRow(label: "Soundings", value: rec.soundings, tint: Ink.seaDeep)
                        }
                    }
                }

                WideDrawButton(title: store.record(for: ground.id) == nil
                                ? "Survey this ground" : "Survey it again", tint: Ink.oxblood) {
                    running = true
                }
                Color.clear.frame(height: 16)
            }
            .padding(.horizontal, Board.gutter)
            .padding(.top, 8)
            .centreColumn()
        }
        .deskPage()
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $openPlate) {
            PlateViewer(name: ground.plate, title: ground.name) { openPlate = false }
        }
        .fullScreenCover(isPresented: $running) {
            SurveyView(ground: ground, order: nil) { running = false }
                .environmentObject(store)
        }
    }
}
