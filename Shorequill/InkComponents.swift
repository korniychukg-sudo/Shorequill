import SwiftUI

struct PaperCard<Content: View>: View {
    var padding: CGFloat = 14
    var tint: Color = Ink.paper
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(tint)
                    DeskLayer(name: "bg_card", fallback: tint, opacity: 0.55)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Ink.hairline, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.34), radius: 8, x: 0, y: 4)
            )
    }
}

struct FeltCard<Content: View>: View {
    var padding: CGFloat = 14
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Ink.felt)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Ink.hairlineLight, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
            )
    }
}

struct RuledHead: View {
    let title: String
    var note: String? = nil
    var tint: Color = Ink.oxblood
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased()).font(Rule.title(11)).tracking(2.6).foregroundColor(tint)
            if let note = note {
                Text(note).font(Rule.italic(13)).foregroundColor(Ink.lineSoft)
            }
        }
    }
}

struct FigureChip: View {
    let value: String
    let label: String
    var tint: Color = Ink.oxblood
    var onPaper: Bool = true
    var body: some View {
        VStack(spacing: 1) {
            Text(value).font(Rule.figure(15)).foregroundColor(tint)
            Text(label.uppercased()).font(Rule.body(9)).tracking(1.2)
                .foregroundColor(onPaper ? Ink.linePale : Ink.paper.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(onPaper ? Ink.paperSunk.opacity(0.6) : Color.black.opacity(0.2))
        )
    }
}

struct WideDrawButton: View {
    let title: String
    var subtitle: String? = nil
    var tint: Color = Ink.oxblood
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: { if enabled { Tap.firm(); action() } }) {
            VStack(spacing: 2) {
                Text(title).font(Rule.title(17)).foregroundColor(Ink.paper)
                if let subtitle = subtitle {
                    Text(subtitle).font(Rule.italic(12)).foregroundColor(Ink.paper.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(enabled ? tint : Ink.linePale.opacity(0.55))
            )
        }
        .buttonStyle(.plain)
        .opacity(enabled ? 1 : 0.7)
    }
}

struct SmallDrawButton: View {
    let title: String
    var tint: Color = Ink.lineSoft
    let action: () -> Void
    var body: some View {
        Button(action: { Tap.light(); action() }) {
            Text(title).font(Rule.title(14)).foregroundColor(tint)
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Ink.paperSunk.opacity(0.7)))
        }
        .buttonStyle(.plain)
    }
}

struct LiftIn<Content: View>: View {
    let index: Int
    @ViewBuilder var content: Content
    @State private var shown = false

    var body: some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.42).delay(Double(index) * 0.06)) { shown = true }
            }
    }
}

struct NoteBanner: View {
    let title: String
    let detail: String
    var tint: Color = Ink.oxblood
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 2).fill(tint).frame(width: 3)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(Rule.title(14)).foregroundColor(Ink.line)
                Text(detail).font(Rule.body(13)).foregroundColor(Ink.lineSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(tint.opacity(0.10)))
    }
}

struct PlateCard: View {
    let name: String
    var height: CGFloat = 200
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Ink.paperSunk)
            if let ui = inkPlate(name) {
                GeometryReader { geo in
                    Image(uiImage: ui)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width,
                               height: geo.size.width * ui.size.height / max(1, ui.size.width),
                               alignment: .top)
                        .clipped()
                }
                .clipped()
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous)
            .stroke(Ink.hairline, lineWidth: 1))
    }
}

struct PlateViewer: View {
    let name: String
    let title: String
    let onClose: () -> Void
    @State private var scale: CGFloat = 1

    var body: some View {
        ZStack {
            Ink.baizeDeep.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text(title).font(Rule.title(16)).foregroundColor(Ink.paper)
                    Spacer()
                    Button(action: { Tap.light(); onClose() }) {
                        CrossGlyph(size: 18, color: Ink.paper)
                            .padding(10).background(Circle().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    if let ui = inkPlate(name) {
                        Image(uiImage: ui)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Board.screenW * scale)
                    } else {
                        Text("Plate unavailable").font(Rule.italic(15))
                            .foregroundColor(Ink.paper.opacity(0.7)).padding(40)
                    }
                }
                HStack(spacing: 12) {
                    SmallDrawButton(title: "Fit") { scale = 1 }
                    SmallDrawButton(title: "Closer") { scale = min(2.8, scale + 0.4) }
                }
                .padding(.bottom, 14)
            }
        }
    }
}

struct ChartBadge: View {
    let grade: String
    var tint: Color
    var body: some View {
        Text(grade)
            .font(Rule.title(15))
            .foregroundColor(Ink.paper)
            .frame(width: 30, height: 30)
            .background(Circle().fill(tint))
    }
}

struct MeasureRow: View {
    let label: String
    let value: Double
    var tint: Color
    var body: some View {
        HStack(spacing: 10) {
            Text(label).font(Rule.body(13)).foregroundColor(Ink.lineSoft)
                .frame(width: 92, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Ink.paperSunk)
                    Capsule().fill(tint).frame(width: max(0, min(1, value)) * geo.size.width)
                }
            }
            .frame(height: 8)
            Text("\(Int(value * 100))").font(Rule.figure(12)).foregroundColor(Ink.linePale)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct MeterLine: View {
    let value: Double
    var tint: Color = Ink.oxblood
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Ink.paperSunk)
                Capsule().fill(tint).frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: 8)
    }
}
