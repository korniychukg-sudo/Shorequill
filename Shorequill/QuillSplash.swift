import SwiftUI

struct QuillSplash: View {
    @State private var glow = false

    var body: some View {
        ZStack {
            DeskLayer(name: "bg_baize", fallback: Ink.baize).ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer(minLength: 0)
                RoseGlyph(size: 96, color: Ink.brass)
                    .opacity(glow ? 1 : 0.55)
                    .scaleEffect(glow ? 1 : 0.94)
                VStack(spacing: 5) {
                    Text("Shorequill").font(Rule.title(27)).foregroundColor(Ink.paper)
                    Text("Survey and the drawing office").font(Rule.italic(15)).foregroundColor(Ink.paper.opacity(0.72))
                        .multilineTextAlignment(.center)
                }
                Spacer(minLength: 0)
                HStack(spacing: 7) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Ink.brass.opacity(glow ? 0.75 : 0.25))
                            .frame(width: 6, height: 6)
                            .scaleEffect(glow ? 1 : 0.7)
                            .animation(.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.16), value: glow)
                    }
                }
                .padding(.bottom, 44)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}
