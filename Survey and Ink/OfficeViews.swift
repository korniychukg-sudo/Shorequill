import SwiftUI

struct OfficeView: View {
    @EnvironmentObject var store: InkStore
    @State private var section = 0
    @State private var openPlate: String?
    @State private var plateTitle = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("THE OFFICE").font(Rule.title(11)).tracking(3.2).foregroundColor(Ink.brass)
                    Text(section == 0 ? "Twelve plates" : "What is on the table")
                        .font(Rule.title(24)).foregroundColor(Ink.paper)
                    Text(section == 0
                         ? "Bases, triangles, resection, plane tables, chains, soundings, datums, hachures, signs, lettering, the rose and the copper."
                         : "Six instruments, and what each one is actually for.")
                        .font(Rule.italic(14)).foregroundColor(Ink.paper.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    segment("Plates", 0)
                    segment("Instruments", 1)
                }

                if section == 0 {
                    ForEach(Array(Office.technique.enumerated()), id: \.element.id) { pair in
                        LiftIn(index: min(5, pair.offset)) { techCard(pair.element) }
                    }
                } else {
                    ForEach(Array(Office.instruments.enumerated()), id: \.element.id) { pair in
                        LiftIn(index: min(5, pair.offset)) { toolCard(pair.element) }
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
        .sheet(isPresented: Binding(get: { openPlate != nil },
                                    set: { if !$0 { openPlate = nil } })) {
            if let plate = openPlate {
                PlateViewer(name: plate, title: plateTitle) { openPlate = nil }
            }
        }
    }

    private func segment(_ label: String, _ index: Int) -> some View {
        Button(action: { Tap.light(); section = index }) {
            Text(label).font(Rule.title(13))
                .foregroundColor(section == index ? Ink.paper : Ink.paper.opacity(0.7))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Capsule().fill(section == index ? Ink.oxblood : Ink.felt))
        }
        .buttonStyle(.plain)
    }

    private func techCard(_ entry: TechEntry) -> some View {
        Button(action: {
            Tap.light()
            store.markPlate(entry.id)
            plateTitle = entry.title
            openPlate = entry.plate
        }) {
            PaperCard(padding: 11) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        RuledHead(title: entry.kicker)
                        Spacer()
                        if store.plateRead.contains(entry.id) {
                            TickGlyph(size: 15, color: Ink.moss)
                        }
                    }
                    PlateCard(name: entry.plate, height: 150)
                    Text(entry.title).font(Rule.title(17)).foregroundColor(Ink.line)
                    Text(entry.sub).font(Rule.italic(12)).foregroundColor(Ink.linePale)
                    Text(entry.summary).font(Rule.body(14)).foregroundColor(Ink.lineSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func toolCard(_ tool: ToolEntry) -> some View {
        Button(action: {
            Tap.light()
            plateTitle = tool.name
            openPlate = tool.plate
        }) {
            PaperCard(padding: 11) {
                VStack(alignment: .leading, spacing: 7) {
                    PlateCard(name: tool.plate, height: 140)
                    Text(tool.name).font(Rule.title(16)).foregroundColor(Ink.line)
                    Text(tool.note).font(Rule.body(13)).foregroundColor(Ink.lineSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
