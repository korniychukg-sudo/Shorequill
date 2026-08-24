import Foundation
import CoreGraphics

func makeGrounds(dir: String) {
    let paper = Sheet(1100, 1900)
    layPaper(paper, seed: 2207, tone: Field.cartridge)
    paper.write(dir, "bg_paper", quality: 0.82)

    let card = Sheet(900, 1200)
    layPaper(card, seed: 3301, tone: Field.paperWarm, laid: false)
    card.write(dir, "bg_card", quality: 0.82)

    let baize = Sheet(1100, 1900)
    var rng = Dice(5501)
    baize.fillAll(Field.baize)
    for _ in 0..<26000 {
        let x = rng.d() * baize.w, y = rng.d() * baize.h
        baize.disc(x, y, rng.r(0.6, 2.2),
                   (rng.chance(0.5) ? Field.baize.lt(0.10) : Field.baizeDark).al(rng.r(0.10, 0.34)))
    }
    for _ in 0..<400 {
        let x = rng.d() * baize.w, y = rng.d() * baize.h
        pen(baize, [pnt(x, y), pnt(x + rng.r(-26, 26), y + rng.r(-8, 8))], weight: rng.r(0.6, 1.8),
            colour: Field.baize.lt(0.14).al(rng.r(0.08, 0.22)), wobble: 0.6, taper: true,
            seed: bits(Int(x)))
    }
    if let g = CGGradient(colorsSpace: rgbSpace,
                          colors: [cg(Field.baizeDark.al(0)), cg(Field.baizeDark.al(0.62))] as CFArray,
                          locations: [0.4, 1]) {
        baize.ctx.drawRadialGradient(g, startCenter: CGPoint(x: baize.w * 0.4, y: baize.h * 0.3),
                                     startRadius: 0,
                                     endCenter: CGPoint(x: baize.w * 0.4, y: baize.h * 0.3),
                                     endRadius: CGFloat(baize.h * 0.9),
                                     options: [.drawsAfterEndLocation])
    }
    baize.write(dir, "bg_baize", quality: 0.84)

    let field = Sheet(1400, 800)
    var rf = Dice(7703)
    field.fillAll(Field.paperCool)
    field.topDown()
    washBand(field, from: 0, to: 420, Field.seaBlue.lt(0.18), strength: 0.28, seed: 991)
    washBand(field, from: 420, to: 560, Field.moss.lt(0.10), strength: 0.30, seed: 997)
    washBand(field, from: 560, to: 800, Field.sand, strength: 0.34, seed: 1009)
    for k in 0..<7 {
        var ridge: [CGPoint] = []
        var x = -40.0
        let base = 430.0 - Double(k) * 12
        while x < field.w + 40 {
            ridge.append(pnt(x, base - sin(x / (120 + Double(k) * 30) + Double(k)) * (30 + Double(k) * 8)
                             + rf.signed() * 6))
            x += 50
        }
        for i in 0..<ridge.count - 1 {
            pen(field, [ridge[i], ridge[i + 1]], weight: 1.4 - Double(k) * 0.1,
                colour: Field.inkSoft.al(0.5 - Double(k) * 0.05), wobble: 0.6, taper: false,
                seed: bits(i &+ k * 40))
        }
    }
    field.write(dir, "bg_field", quality: 0.84)
}

struct InstrumentSpec {
    let id: String
    let name: String
    let note: String
    let kind: String
}

let instrumentBook: [InstrumentSpec] = [
    InstrumentSpec(id: "planetable", name: "Plane table and alidade",
                   note: "A drawing board on a tripod and a brass rule with sight vanes. The survey is drawn in the field, in the presence of the ground it describes.",
                   kind: "planetable"),
    InstrumentSpec(id: "theodolite", name: "The theodolite",
                   note: "A telescope that can be pointed anywhere and read against two graduated circles. Every triangle in a national survey came out of one of these.",
                   kind: "theodolite"),
    InstrumentSpec(id: "chain", name: "Gunter's chain and arrows",
                   note: "Sixty-six feet in a hundred links, with ten arrows to mark each chain length. Ten square chains make an acre, which is the whole reason for the length.",
                   kind: "chain"),
    InstrumentSpec(id: "level", name: "Level and staff",
                   note: "A telescope that will only look horizontally, and a graduated staff held upright. Between them they carry a height across a country a few feet at a time.",
                   kind: "level"),
    InstrumentSpec(id: "pens", name: "Ruling pen and dividers",
                   note: "The ruling pen sets its line width with a screw and holds ink between two blades; the dividers step a distance off the scale without ever reading a number.",
                   kind: "pens"),
    InstrumentSpec(id: "station", name: "Station mark and pole",
                   note: "A cut cross in rock, a buried stone, a cairn and a whitened pole. The next survey stands exactly where this one stood, and the two can be compared.",
                   kind: "station"),
]

func makeInstrumentPlate(_ spec: InstrumentSpec, dir: String) {
    let p = Sheet(1100, 760)
    let seed = hashOf("inst" + spec.id)
    layPaper(p, seed: seed, tone: Field.paperWarm)
    p.topDown()
    p.light = 2.30
    var rng = Dice(seed &+ 3)

    switch spec.kind {
    case "planetable":
        let board: [CGPoint] = [pnt(220, 300), pnt(860, 250), pnt(890, 380), pnt(250, 434)]
        p.poly(board, Field.paperCool)
        formShade(p, board, inset: 40, depth: 2, spacing: 8, colour: Field.inkSoft, seed: seed)
        penContour(p, board, weight: 2.6, colour: Field.ink, seed: seed &+ 5)
        let rule: [CGPoint] = [pnt(320, 386), pnt(820, 302), pnt(824, 328), pnt(324, 412)]
        p.poly(rule, Field.brass)
        penContour(p, rule, weight: 2.0, colour: Field.ink, seed: seed &+ 7)
        for k in 0..<20 {
            let t = Double(k) / 20
            pen(p, [pnt(324 + t * 496, 412 - t * 84), pnt(324 + t * 496, 404 - t * 84)],
                weight: 1.0, colour: Field.brassDark, wobble: 0.2, taper: false, seed: seed &+ bits(k))
        }
        pen(p, [pnt(332, 400), pnt(332, 330)], weight: 3.4, colour: Field.brassDark,
            wobble: 0.2, taper: false, seed: seed &+ 9)
        pen(p, [pnt(816, 316), pnt(816, 246)], weight: 3.4, colour: Field.brassDark,
            wobble: 0.2, taper: false, seed: seed &+ 11)
        drawTripod(p, at: pnt(560, 620), height: 210, seed: seed &+ 13)
        caption(p, "sight vanes", at: 850, 240, size: 20, colour: Field.oxblood,
                face: "Georgia-Italic", align: .left)
    case "theodolite":
        drawTripod(p, at: pnt(520, 620), height: 240, seed: seed)
        p.ellipse(520, 386, 96, 20, Field.brass)
        p.ring(520, 386, 96, 2.0, Field.ink)
        for k in 0..<36 {
            let a = Double(k) / 36 * 6.283
            pen(p, [pnt(520 + cos(a) * 84, 386 + sin(a) * 17),
                    pnt(520 + cos(a) * 96, 386 + sin(a) * 20)], weight: 1.0,
                colour: Field.brassDark, wobble: 0.2, taper: false, seed: seed &+ bits(k))
        }
        for side in 0..<2 {
            let dx = side == 0 ? -46.0 : 46.0
            p.poly([pnt(520 + dx - 10, 380), pnt(520 + dx + 10, 380),
                    pnt(520 + dx + 6, 280), pnt(520 + dx - 6, 280)], Field.brass.dk(0.06))
            penContour(p, [pnt(520 + dx - 10, 380), pnt(520 + dx + 10, 380),
                           pnt(520 + dx + 6, 280), pnt(520 + dx - 6, 280)],
                       weight: 1.6, colour: Field.ink, seed: seed &+ bits(side))
        }
        let tube: [CGPoint] = [pnt(400, 296), pnt(660, 264), pnt(664, 292), pnt(404, 324)]
        p.poly(tube, Field.brass)
        formShade(p, tube, inset: 18, depth: 2, spacing: 6, colour: Field.inkSoft, seed: seed &+ 21)
        penContour(p, tube, weight: 2.0, colour: Field.ink, seed: seed &+ 23)
        p.ellipse(668, 278, 10, 18, Field.graphite)
        p.ellipse(398, 310, 8, 15, Field.graphite)
        p.ellipse(520, 282, 44, 10, Field.brassDark)
        caption(p, "horizontal circle", at: 640, 400, size: 20, colour: Field.oxblood,
                face: "Georgia-Italic", align: .left)
    case "chain":
        var x = 180.0
        var k = 0
        while x < 900 {
            p.ellipse(x, 340 + sin(x / 60) * 12, 16, 7, Field.graphite)
            p.ring(x, 340 + sin(x / 60) * 12, 16, 2.0, Field.ink)
            x += 26
            k += 1
        }
        for j in 0..<5 {
            let ax = 260.0 + Double(j) * 150
            pen(p, [pnt(ax, 470), pnt(ax + 8, 560)], weight: 2.6, colour: Field.graphite,
                wobble: 0.3, taper: false, seed: seed &+ bits(j))
            var loop: [CGPoint] = []
            var a = 0.0
            while a < 6.283 {
                loop.append(pnt(ax + cos(a) * 12, 462 + sin(a) * 10))
                a += 0.3
            }
            penContour(p, loop, weight: 2.2, colour: Field.graphite, seed: seed &+ bits(j &+ 20))
        }
        caption(p, "a hundred links, ten arrows", at: 180, 620, size: 21, colour: Field.oxblood,
                face: "Georgia-Italic", align: .left)
    case "level":
        drawTripod(p, at: pnt(360, 600), height: 200, seed: seed)
        let tube: [CGPoint] = [pnt(250, 372), pnt(500, 372), pnt(500, 402), pnt(250, 402)]
        p.poly(tube, Field.brass)
        formShade(p, tube, inset: 18, depth: 2, spacing: 6, colour: Field.inkSoft, seed: seed &+ 5)
        penContour(p, tube, weight: 2.0, colour: Field.ink, seed: seed &+ 7)
        p.rect(300, 350, 120, 16, Field.glassTone)
        penContour(p, [pnt(300, 350), pnt(420, 350), pnt(420, 366), pnt(300, 366)],
                   weight: 1.4, colour: Field.ink, seed: seed &+ 9)
        p.ellipse(356, 358, 16, 5, Field.verdigris)
        let staff: [CGPoint] = [pnt(820, 140), pnt(870, 140), pnt(870, 620), pnt(820, 620)]
        p.poly(staff, Field.paperCool)
        penContour(p, staff, weight: 2.0, colour: Field.ink, seed: seed &+ 11)
        var sy = 150.0
        var band = 0
        while sy < 620 {
            if band % 2 == 0 { p.rect(820, sy, 50, 24, Field.ink.al(0.85)) }
            sy += 24
            band += 1
        }
        pen(p, [pnt(500, 388), pnt(820, 388)], weight: 1.2, colour: Field.carmine.al(0.7),
            wobble: 0.2, taper: false, seed: seed &+ 13)
        caption(p, "line of collimation", at: 560, 372, size: 19, colour: Field.carmine,
                face: "Georgia-Italic", align: .left)
    case "pens":
        let pen1: [CGPoint] = [pnt(200, 420), pnt(560, 330), pnt(576, 360), pnt(216, 450)]
        p.poly(pen1, Field.sepia)
        penContour(p, pen1, weight: 2.2, colour: Field.ink, seed: seed &+ 5)
        p.poly([pnt(560, 330), pnt(660, 306), pnt(668, 330), pnt(576, 360)], Field.graphite)
        pen(p, [pnt(660, 306), pnt(700, 296)], weight: 2.0, colour: Field.graphite,
            wobble: 0.2, taper: true, seed: seed &+ 7)
        pen(p, [pnt(668, 330), pnt(704, 314)], weight: 2.0, colour: Field.graphite,
            wobble: 0.2, taper: true, seed: seed &+ 9)
        p.disc(614, 322, 9, Field.brass)
        for side in 0..<2 {
            let dx = side == 0 ? -1.0 : 1.0
            pen(p, [pnt(820, 300), pnt(820 + dx * 90, 560)], weight: 8.0, colour: Field.graphite,
                wobble: 0.2, taper: true, seed: seed &+ bits(side &+ 20))
        }
        p.disc(820, 296, 12, Field.brass)
        caption(p, "the screw sets the width of the line", at: 200, 620, size: 21,
                colour: Field.oxblood, face: "Georgia-Italic", align: .left)
    default:
        var cairn: [CGPoint] = []
        for _ in 0..<26 {
            let cx = rng.r(300, 560), cy = rng.r(430, 560)
            cairn.append(pnt(cx, cy))
            p.poly(blob(cx: cx, cy: cy, rx: rng.r(16, 34), ry: rng.r(12, 24), rough: 0.24,
                        steps: 10, seed: seed &+ bits(Int(cx))), Field.inkPale.al(0.7))
            penContour(p, blob(cx: cx, cy: cy, rx: rng.r(16, 34), ry: rng.r(12, 24), rough: 0.24,
                               steps: 10, seed: seed &+ bits(Int(cx))),
                       weight: 1.4, colour: Field.ink, seed: seed &+ bits(Int(cy)))
        }
        pen(p, [pnt(430, 430), pnt(430, 180)], weight: 7.0, colour: Field.bone,
            wobble: 0.3, taper: false, seed: seed &+ 5)
        for k in 0..<5 {
            p.rect(424, 190.0 + Double(k) * 46, 12, 23, Field.ink.al(0.9))
        }
        p.poly([pnt(430, 176), pnt(500, 196), pnt(430, 216)], Field.oxblood)
        let stone: [CGPoint] = [pnt(700, 470), pnt(830, 456), pnt(840, 560), pnt(710, 574)]
        p.poly(stone, Field.inkPale.al(0.6))
        penContour(p, stone, weight: 2.2, colour: Field.ink, seed: seed &+ 7)
        pen(p, [pnt(740, 500), pnt(800, 530)], weight: 2.4, colour: Field.ink,
            wobble: 0.3, taper: false, seed: seed &+ 9)
        pen(p, [pnt(800, 500), pnt(740, 530)], weight: 2.4, colour: Field.ink,
            wobble: 0.3, taper: false, seed: seed &+ 11)
        caption(p, "a cut cross, and the pole above it", at: 200, 640, size: 21,
                colour: Field.oxblood, face: "Georgia-Italic", align: .left)
    }

    caption(p, spec.name, at: 90, 580, size: 38, colour: Field.ink, face: "Georgia-Bold", align: .left)
    var y = 624.0
    for line in wrapText(spec.note, width: 920, size: 23) {
        caption(p, line, at: 90, y, size: 23, colour: Field.inkSoft, face: "Georgia", align: .left)
        y += 30
    }
    plateFrame(p, inset: 36, seed: seed &+ 41)
    p.write(dir, "inst_" + spec.id, quality: 0.88)
}

extension Field {
    static let glassTone = Tone(r: 0.796, g: 0.831, b: 0.827)
}
