import SwiftUI

enum Ink {
    static let baize = Color(red: 0.200, green: 0.278, blue: 0.231)
    static let baizeDark = Color(red: 0.118, green: 0.169, blue: 0.145)
    static let baizeDeep = Color(red: 0.078, green: 0.118, blue: 0.102)
    static let felt = Color(red: 0.247, green: 0.325, blue: 0.271)

    static let paper = Color(red: 0.918, green: 0.890, blue: 0.827)
    static let paperWarm = Color(red: 0.941, green: 0.914, blue: 0.851)
    static let paperSunk = Color(red: 0.855, green: 0.824, blue: 0.749)

    static let line = Color(red: 0.114, green: 0.102, blue: 0.090)
    static let lineSoft = Color(red: 0.247, green: 0.227, blue: 0.204)
    static let linePale = Color(red: 0.443, green: 0.420, blue: 0.388)
    static let pencil = Color(red: 0.478, green: 0.482, blue: 0.482)

    static let oxblood = Color(red: 0.545, green: 0.212, blue: 0.173)
    static let carmine = Color(red: 0.694, green: 0.286, blue: 0.243)
    static let sepia = Color(red: 0.353, green: 0.267, blue: 0.180)
    static let brass = Color(red: 0.776, green: 0.624, blue: 0.302)
    static let brassDark = Color(red: 0.529, green: 0.412, blue: 0.184)
    static let seaBlue = Color(red: 0.549, green: 0.639, blue: 0.671)
    static let seaDeep = Color(red: 0.353, green: 0.475, blue: 0.522)
    static let sand = Color(red: 0.831, green: 0.769, blue: 0.635)
    static let moss = Color(red: 0.396, green: 0.463, blue: 0.325)
    static let verdigris = Color(red: 0.384, green: 0.545, blue: 0.494)
    static let bone = Color(red: 0.878, green: 0.855, blue: 0.792)

    static let hairline = Color.black.opacity(0.16)
    static let hairlineLight = Color.white.opacity(0.10)
}

enum Rule {
    static func title(_ size: CGFloat) -> Font { .custom("Georgia-Bold", size: size) }
    static func body(_ size: CGFloat) -> Font { .custom("Georgia", size: size) }
    static func italic(_ size: CGFloat) -> Font { .custom("Georgia-Italic", size: size) }
    static func figure(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .monospaced) }
}

enum Board {
    static var isPad: Bool { UIScreen.main.bounds.width >= 700 }
    static var contentWidth: CGFloat { isPad ? 660 : UIScreen.main.bounds.width }
    static var gutter: CGFloat { isPad ? 32 : 18 }
    static var screenW: CGFloat { UIScreen.main.bounds.width }
    static var screenH: CGFloat { UIScreen.main.bounds.height }
}

func inkPlate(_ name: String) -> UIImage? {
    if let path = Bundle.main.path(forResource: name, ofType: "jpg", inDirectory: "Art"),
       let img = UIImage(contentsOfFile: path) {
        return img
    }
    if let path = Bundle.main.path(forResource: name, ofType: "jpg") {
        return UIImage(contentsOfFile: path)
    }
    return nil
}

struct DeskLayer: View {
    let name: String
    var fallback: Color
    var opacity: Double = 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                fallback
                if let ui = inkPlate(name) {
                    Color.clear
                        .overlay(Image(uiImage: ui).resizable().aspectRatio(contentMode: .fill))
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .opacity(opacity)
                }
            }
        }
    }
}

extension View {
    func deskPage() -> some View {
        self.background(DeskLayer(name: "bg_baize", fallback: Ink.baize).ignoresSafeArea())
    }

    func centreColumn() -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            self.frame(maxWidth: Board.contentWidth)
            Spacer(minLength: 0)
        }
    }
}

enum Tap {
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func firm() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    static func soft() { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
}

struct Draw {
    var s: UInt64
    init(_ seed: UInt64) { s = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 { s ^= s << 13; s ^= s >> 7; s ^= s << 17; return s }
    mutating func unit() -> Double { Double(next() % 1_000_000) / 1_000_000.0 }
    mutating func range(_ a: Double, _ b: Double) -> Double { a + unit() * (b - a) }
    mutating func index(_ n: Int) -> Int { n <= 0 ? 0 : Int(next() % UInt64(n)) }
    mutating func chance(_ p: Double) -> Bool { unit() < p }
    mutating func signed() -> Double { unit() * 2 - 1 }
}

func inkSeed(_ text: String) -> UInt64 {
    var h: UInt64 = 14695981039346656037
    for b in text.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
    return h
}
