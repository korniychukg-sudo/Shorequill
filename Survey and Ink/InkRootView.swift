import SwiftUI

struct InkRootView: View {
    @EnvironmentObject var store: InkStore
    @State private var tab = 0
    @State private var lastTab = 0

    var body: some View {
        ZStack {
            if store.onboarded { shell }
            else { InkOnboarding { store.markOnboarded() }.transition(.opacity) }
        }
        .animation(.easeInOut(duration: 0.35), value: store.onboarded)
    }

    private var shell: some View {
        VStack(spacing: 0) {
            Group {
                switch tab {
                case 0:
                    NavigationView { DeskView() }.navigationViewStyle(StackNavigationViewStyle())
                case 1:
                    NavigationView { FieldView() }.navigationViewStyle(StackNavigationViewStyle())
                case 2:
                    NavigationView { ChartsView() }.navigationViewStyle(StackNavigationViewStyle())
                case 3:
                    NavigationView { OfficeView() }.navigationViewStyle(StackNavigationViewStyle())
                default:
                    NavigationView { PortfolioView() }.navigationViewStyle(StackNavigationViewStyle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(tab)
            .transition(.asymmetric(
                insertion: .move(edge: tab > lastTab ? .trailing : .leading).combined(with: .opacity),
                removal: .opacity))
            tabBar
        }
        .deskPage()
    }

    private var tabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [Color.black.opacity(0.30), Color.clear],
                                     startPoint: .bottom, endPoint: .top))
                .frame(height: 8)
            HStack(spacing: 0) {
                tabButton(0, "Office", AnyView(BoardGlyph(size: 21, color: tint(0))))
                tabButton(1, "Ground", AnyView(RoseGlyph(size: 21, color: tint(1))))
                tabButton(2, "Charts", AnyView(ChartGlyph(size: 21, color: tint(2))))
                tabButton(3, "Plates", AnyView(PenGlyph(size: 21, color: tint(3))))
                tabButton(4, "Portfolio", AnyView(FolioGlyph(size: 21, color: tint(4))))
            }
            .padding(.top, 9).padding(.bottom, 3)
            .background(Ink.baizeDeep.edgesIgnoringSafeArea(.bottom))
        }
    }

    private func tint(_ i: Int) -> Color { tab == i ? Ink.brass : Ink.paper.opacity(0.55) }

    private func tabButton(_ index: Int, _ label: String, _ icon: AnyView) -> some View {
        Button(action: {
            guard tab != index else { return }
            Tap.light()
            lastTab = tab
            withAnimation(.easeInOut(duration: 0.28)) { tab = index }
        }) {
            VStack(spacing: 3) {
                icon
                Text(label).font(Rule.body(10)).foregroundColor(tint(index))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.white.opacity(tab == index ? 0.08 : 0))
                    .padding(.horizontal, 5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct InkOnboarding: View {
    let onDone: () -> Void
    @State private var page = 0

    private let pages: [(String, String, Int)] = [
        ("A survey is angles, not distances",
         "Measuring across country is slow and full of error; measuring an angle is quick and exact. So you stand at two stations, take the angle to every landmark, and let the triangles give you the map.",
         0),
        ("The rays will not meet in a point",
         "They never do. The little triangle they make is the cocked hat, and its size is the honest measure of how good your angles were.",
         1),
        ("Then it has to be drawn",
         "One steady line for the coast, hachures running straight down the fall of every hill, the name curved along the feature without touching it, and the soundings pricked in.",
         2),
        ("And the sheet is yours",
         "Twenty-four grounds, twelve plates on how it was really done, and a portfolio that keeps your own coastline with your own hand in it.",
         3),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if page > 0 {
                    Button(action: { Tap.light(); withAnimation { page -= 1 } }) {
                        AngleGlyph(size: 16, color: Ink.paper, facing: .pi)
                            .padding(9).background(Circle().fill(Ink.felt))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Button(action: { Tap.light(); onDone() }) {
                    Text("Skip").font(Rule.title(14)).foregroundColor(Ink.paper.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Board.gutter).padding(.top, 14)

            Spacer(minLength: 0)
            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Ink.felt)
                        .frame(width: 176, height: 176)
                    switch pages[page].2 {
                    case 0: RoseGlyph(size: 96, color: Ink.brass)
                    case 1: AngleGlyph(size: 92, color: Ink.oxblood)
                    case 2: HillGlyph(size: 100, color: Ink.paper)
                    default: FolioGlyph(size: 96, color: Ink.verdigris)
                    }
                }
                VStack(spacing: 12) {
                    Text(pages[page].0).font(Rule.title(24)).foregroundColor(Ink.paper)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(pages[page].1).font(Rule.body(16))
                        .foregroundColor(Ink.paper.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 26)
            }
            .id(page)
            .transition(.opacity)
            Spacer(minLength: 0)

            HStack(spacing: 7) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Circle().fill(i == page ? Ink.brass : Ink.paper.opacity(0.35))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.bottom, 18)
            WideDrawButton(title: page == pages.count - 1 ? "Open the office" : "Next",
                           tint: Ink.oxblood) {
                if page == pages.count - 1 { onDone() }
                else { withAnimation(.easeInOut(duration: 0.28)) { page += 1 } }
            }
            .padding(.horizontal, Board.gutter).padding(.bottom, 26)
        }
        .deskPage()
        .centreColumn()
    }
}
