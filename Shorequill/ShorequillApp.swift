import SwiftUI

@main
struct ShorequillApp: App {
    @StateObject private var store = InkStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            InkRootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive { store.saveNow() }
        }
    }
}
