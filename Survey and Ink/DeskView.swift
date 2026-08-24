import SwiftUI

struct DeskView: View {
    @EnvironmentObject var store: InkStore
    @State private var openSurvey = false
    @State private var openPlate: String?
    @State private var plateTitle = ""

    private var day: Int { Orders.dayIndex() }
    private var order: Order { Orders.forDay(day) }
    private var doneToday: DayOrder? { store.todayOrder() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                header
                LiftIn(index: 0) { OfficeScene(ground: order.ground) }
                LiftIn(index: 1) { orderCard }
                LiftIn(index: 2) { standingCard }
                LiftIn(index: 3) { readingCard }
                Color.clear.frame(height: 12)
            }
            .padding(.horizontal, Board.gutter)
            .padding(.top, 8)
            .centreColumn()
        }
        .deskPage()
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $openSurvey) {
            SurveyView(ground: order.ground, order: order) { openSurvey = false }
                .environmentObject(store)
        }
        .sheet(isPresented: Binding(get: { openPlate != nil },
                                    set: { if !$0 { openPlate = nil } })) {
            if let plate = openPlate {
                PlateViewer(name: plate, title: plateTitle) { openPlate = nil }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("THE DRAWING OFFICE").font(Rule.title(11)).tracking(3.2)
                .foregroundColor(Ink.brass)
            Text(DeskLight.hue(for: DeskLight.nowHour).label)
                .font(Rule.title(24)).foregroundColor(Ink.paper)
            Text("Day \(day) on the survey · \(store.rank.name)")
                .font(Rule.italic(14)).foregroundColor(Ink.paper.opacity(0.7))
        }
    }

    private var orderCard: some View {
        PaperCard {
            VStack(alignment: .leading, spacing: 11) {
                RuledHead(title: "Today's order", note: order.title)
                Text(order.note).font(Rule.body(15)).foregroundColor(Ink.lineSoft)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    PlateCard(name: order.ground.plate, height: 116).frame(width: 92)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.ground.name).font(Rule.title(17)).foregroundColor(Ink.line)
                        Text("\(order.ground.place) · \(order.ground.year)")
                            .font(Rule.italic(12)).foregroundColor(Ink.linePale)
                        Text("\(order.ground.landmarks.count * 2) angles · \(order.ground.hills.count) hills")
                            .font(Rule.body(12)).foregroundColor(Ink.lineSoft)
                        Text("They will accept \(order.target) out of a hundred.")
                            .font(Rule.body(12)).foregroundColor(Ink.oxblood)
                    }
                    Spacer(minLength: 0)
                }
                if let done = doneToday {
                    NoteBanner(title: done.met ? "Delivered and accepted" : "Delivered, and sent back with remarks",
                               detail: "You made \(Int((done.overall * 100).rounded())) against a mark of \(done.target). The ground can be surveyed again.",
                               tint: done.met ? Ink.moss : Ink.oxblood)
                    WideDrawButton(title: "Survey it again", tint: Ink.lineSoft) { openSurvey = true }
                } else {
                    WideDrawButton(title: "Take the order",
                                   subtitle: "Angles, ink, hachures, lettering and soundings",
                                   tint: Ink.oxblood) { openSurvey = true }
                }
            }
        }
    }

    private var standingCard: some View {
        PaperCard {
            VStack(alignment: .leading, spacing: 11) {
                RuledHead(title: "Standing in the office", note: store.rank.note)
                HStack(spacing: 10) {
                    FigureChip(value: "\(store.liveStreak)", label: "day streak", tint: Ink.brassDark)
                    FigureChip(value: "\(store.points)", label: "points", tint: Ink.oxblood)
                    FigureChip(value: "\(store.chartCount)/\(GroundBook.all.count)",
                               label: "sheets", tint: Ink.moss)
                }
                if let next = store.nextRank {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Toward \(next.name)").font(Rule.body(13))
                                .foregroundColor(Ink.lineSoft)
                            Spacer()
                            Text("\(store.points)/\(next.need)").font(Rule.figure(12))
                                .foregroundColor(Ink.linePale)
                        }
                        MeterLine(value: store.rankProgress, tint: Ink.brassDark)
                    }
                } else {
                    Text("Above hydrographer there is only the weather and the Admiralty.")
                        .font(Rule.italic(13)).foregroundColor(Ink.linePale)
                }
                HStack(spacing: 10) {
                    FigureChip(value: "\(store.surveys)", label: "surveys", tint: Ink.lineSoft)
                    FigureChip(value: "\(store.marksTaken)", label: "angles", tint: Ink.lineSoft)
                    FigureChip(value: "\(store.topGrades)", label: "first class", tint: Ink.verdigris)
                }
            }
        }
    }

    private var readingCard: some View {
        let entry = Office.technique[day % Office.technique.count]
        return FeltCard {
            VStack(alignment: .leading, spacing: 9) {
                RuledHead(title: "Pinned above the board", note: entry.kicker, tint: Ink.brass)
                Text(entry.title).font(Rule.title(17)).foregroundColor(Ink.paper)
                Text(entry.summary).font(Rule.body(14)).foregroundColor(Ink.paper.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: {
                    Tap.light()
                    store.markPlate(entry.id)
                    plateTitle = entry.title
                    openPlate = entry.plate
                }) {
                    Text("Open the plate").font(Rule.title(13)).foregroundColor(Ink.brass)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
