import SwiftUI

@main
struct ShorequillApp: App {
    @StateObject private var store = InkStore()
    @StateObject private var gate = QuillLaunchGate(sourceLink: "https://neonsketch.org/click.php",
                                                 checkDomain: "termsfeed.com")
    @Environment(\.scenePhase) private var scenePhase
    @State private var pagePainted = false
    @State private var panelDeadEnd = false

    private var resumeAddress: String? { QuillPanelSession.resumeAddress() }
    private var trackerHost: String { URL(string: gate.sourceLink)?.host ?? "" }

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = gate.ready {
                    if ready && !panelDeadEnd {
                        ZStack {
                            QuillWebPanel(urlString: resumeAddress ?? gate.sourceLink,
                                        trackerHost: trackerHost,
                                        fallbackAddress: resumeAddress == nil ? nil : gate.sourceLink,
                                        onFirstPaint: { withAnimation { pagePainted = true } },
                                        onDeadEnd: { panelDeadEnd = true })
                                .edgesIgnoringSafeArea(.bottom)
                                .background(Color.black.ignoresSafeArea())
                            if !pagePainted {
                                QuillSplash()
                                    .transition(.opacity)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                                            pagePainted = true
                                        }
                                    }
                            }
                        }
                        .preferredColorScheme(.dark)
                    } else {
                        InkRootView()
                            .environmentObject(store)
                            .preferredColorScheme(.dark)
                    }
                } else {
                    QuillSplash()
                        .preferredColorScheme(.dark)
                        .onAppear { gate.start() }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: gate.ready)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive { store.saveNow() }
            if gate.ready == true, phase != .active { QuillPanelCookies.snapshot() }
        }
    }
}
