import Foundation
import CoreGraphics

struct TechSpec {
    let id: String
    let kicker: String
    let title: String
    let sub: String
    let kind: String
    let notes: [(String, String)]
}

let techBook: [TechSpec] = techBookA + techBookB

let techBookA: [TechSpec] = [
    TechSpec(id: "baseline", kicker: "Plate I", title: "The base",
             sub: "One measured line, and everything else is arithmetic",
             kind: "baseline",
             notes: [("Measured to the inch over miles",
                      "The chain or bar is laid on trestles in the open, aligned by theodolite, corrected for temperature and for sag, and the whole line is measured twice in opposite directions. A base of five miles was expected to agree within a few inches."),
                     ("Base extension",
                      "A short base is enlarged by a chain of well-shaped triangles until the sides are long enough for the main network. Every step multiplies the error, which is why the shape of the triangles matters as much as the care taken."),
                     ("Why not simply measure everything",
                      "Because measuring distance across country is slow and full of error, while measuring an angle is quick and exact. Triangulation trades distances for angles, and that trade built every national map.")]),
    TechSpec(id: "triangulation", kicker: "Plate II", title: "The network",
             sub: "Triangles carried across a country",
             kind: "network",
             notes: [("Well-conditioned triangles",
                      "A triangle with an angle under thirty degrees computes badly: a small error in the observed angle throws the calculated side a long way. Surveyors choose stations for shape as much as for view."),
                     ("Primary, secondary, tertiary",
                      "Great triangles between hilltops first, smaller ones inside them, then the detail. Nothing small is ever surveyed before the framework that will hold it."),
                     ("Closing the figure",
                      "The three angles of every triangle must add to a hundred and eighty degrees plus the spherical excess. What they miss by is spread back through the observations, and the size of that miss is the survey's honesty.")]),
    TechSpec(id: "resection", kicker: "Plate III", title: "Fixing your own position",
             sub: "Two angles, three known points, and one trap",
             kind: "resection",
             notes: [("The three-point problem",
                      "Measure the angle between the left and middle objects and between the middle and right. Each angle puts you on a circle through two of them, and the circles cross at your station."),
                     ("The danger circle",
                      "If all three points and the observer lie on one circle, both angles are the same anywhere on it and there is no fix at all. Choose a middle object nearer to you than the line joining the outer two."),
                     ("At sea it is done with a sextant",
                      "Held horizontally, taking the angle between two shore objects. A station pointer laid on the chart then puts the boat's position on the paper in seconds.")]),
    TechSpec(id: "planetable", kicker: "Plate IV", title: "The plane table",
             sub: "A survey that draws itself in the field",
             kind: "planetable",
             notes: [("Draw the ray, not the angle",
                      "Sight the object along the alidade and rule a line. From a second station rule another. Where they cross is the object. Nothing is written down and nothing is computed."),
                     ("Orientation is everything",
                      "At each new station the board is turned until the line already drawn between the two stations lies along the real one on the ground. An unoriented board gives a perfectly neat, entirely wrong map."),
                     ("Its advantage",
                      "You see the map growing beside the country. Mistakes are caught while you are still standing where you can check them, which no notebook method can offer.")]),
    TechSpec(id: "chain", kicker: "Plate V", title: "Chain and offsets",
             sub: "The cheapest survey there is",
             kind: "chain",
             notes: [("Gunter's chain",
                      "Sixty-six feet in a hundred links. Ten square chains make an acre, which is the whole reason for the odd length, and it is why fields were measured in chains for three hundred years."),
                     ("Offsets",
                      "Run the chain in a straight line and measure short perpendicular distances to the hedge at every bend. Anything more than about a chain of offset means the line was badly chosen."),
                     ("Booking",
                      "The field book is written up the page, not across, with the chain line down the middle and the offsets either side, so the page reads like the ground looks.")]),
    TechSpec(id: "soundings", kicker: "Plate VI", title: "Lines of soundings",
             sub: "How the sea floor gets onto paper",
             kind: "soundings",
             notes: [("The boat runs a line",
                      "Rowing a straight course between two marks while the leadsman heaves and calls and the officer fixes the boat with sextant angles. The soundings are written against the fixes and reduced for the tide afterwards."),
                     ("Reduction",
                      "Every sounding must be corrected to chart datum using a tide gauge read ashore at the same time. An uncorrected sounding is only a depth on one particular afternoon."),
                     ("Interlining",
                      "Lines are run close enough that nothing dangerous can lie between them, and closer again over rocky ground. The pattern of lines is a judgement about how much the bottom can surprise you.")]),
]

let techBookB: [TechSpec] = [
    TechSpec(id: "datum", kicker: "Plate VII", title: "Which zero",
             sub: "Depths from one level, heights from another",
             kind: "datum",
             notes: [("Chart datum",
                      "Soundings are reduced to about the lowest astronomical tide, so that the charted depth is nearly always less than what is actually there. It is a deliberately pessimistic zero."),
                     ("Drying heights",
                      "A bank that uncovers carries its height above datum with a line under the figure. Read the underline or you will take a drying bank for four fathoms of water."),
                     ("Heights and clearances",
                      "Land heights and lighthouse elevations are given above mean high water springs, and bridge clearances above the highest tide. Three different zeros on one sheet, and every one of them matters.")]),
    TechSpec(id: "hachures", kicker: "Plate VIII", title: "Hachures and contours",
             sub: "The same hill drawn two ways",
             kind: "hachures",
             notes: [("The rule of the slope",
                      "Hachures run straight down the fall of the ground, and the steeper the ground the shorter, thicker and more crowded they are. The convention was codified by Lehmann and taught unchanged for a century."),
                     ("What each is for",
                      "Hachures make a hill look like a hill and tell you nothing you can measure. Contours look like nothing at all until you learn them, and then they give height, slope, volume and line of sight."),
                     ("Drawing them",
                      "Hachures are drawn between guide lines laid down at intervals of equal height, so the two methods are really the same survey rendered differently.")]),
    TechSpec(id: "signs", kicker: "Plate IX", title: "Conventional signs",
             sub: "A language small enough to fit between the names",
             kind: "signs",
             notes: [("Texture, not outline",
                      "Marsh, rough pasture, wood and orchard are shown by a repeated small symbol scattered over the area, never by a boundary line. The eye reads the texture and the space stays free for lettering."),
                     ("Made for engraving",
                      "Every sign is a few strokes of a burin. The forms that survived are the ones a tired engraver could cut a thousand times without variation."),
                     ("Reading a sign is not optional",
                      "A dotted circle round a rock, a line under a figure, a small anchor upside down: each one changes what the sheet is telling you, and none of them is decorative.")]),
    TechSpec(id: "lettering", kicker: "Plate X", title: "Lettering",
             sub: "The slowest and most visible work on the sheet",
             kind: "lettering",
             notes: [("Upright for dry, sloping for wet",
                      "The single most useful convention on any chart. Names of anything that floats, flows or covers are set in italic; anything you could stand on is upright."),
                     ("Along the feature, not across it",
                      "A river name curves with the river, a bank name lies along the bank, and a name never crosses a coastline. Placing names well takes as long as drawing the coast."),
                     ("Size means rank",
                      "The letter height alone tells you a village from a town from a county, before you have read a word of it.")]),
    TechSpec(id: "rose", kicker: "Plate XI", title: "The compass rose",
             sub: "Two norths on one card",
             kind: "rose",
             notes: [("True and magnetic",
                      "The outer ring is true north from the survey; the inner is magnetic north from the compass, with the variation and its annual change written in the middle. They are years out of step on any old chart."),
                     ("Variation moves",
                      "It changes by several minutes a year and by tens of degrees across the world. Working an old bearing without correcting the variation of its date is one of the classic ways to put a ship ashore."),
                     ("The fleur",
                      "The ornamented north point is inherited from the portolan charts of the fourteenth century, and it survived every reform because it can be found at a glance in bad light.")]),
    TechSpec(id: "engraving", kicker: "Plate XII", title: "Onto copper",
             sub: "Cut backwards, printed forwards",
             kind: "engraving",
             notes: [("The burin",
                      "A square-section steel graver pushed through the copper, throwing up a curl of metal. Line width is controlled by depth and angle, which is why an engraved coast can be a hair fine and still print black."),
                     ("Everything is mirrored",
                      "The engraver cuts the whole chart in reverse, lettering included. Apprentices spent years learning to letter backwards without hesitation."),
                     ("Corrections",
                      "A wrong line is burnished out and the copper is hammered up from the back to restore the surface. A plate could carry forty years of corrections and still print cleanly.")]),
]

func drawFigure(_ p: Sheet, at c: CGPoint, scale: Double, seed: UInt64) {
    let x = Double(c.x), y = Double(c.y)
    let h = 46.0 * scale
    p.ellipse(x, y - h, 6 * scale, 7 * scale, Field.ink)
    pen(p, [pnt(x, y - h + 7 * scale), pnt(x, y - h * 0.35)], weight: 5 * scale,
        colour: Field.ink, wobble: 0.3, taper: false, seed: seed)
    pen(p, [pnt(x, y - h * 0.35), pnt(x - 7 * scale, y)], weight: 4 * scale,
        colour: Field.ink, wobble: 0.3, taper: false, seed: seed &+ 1)
    pen(p, [pnt(x, y - h * 0.35), pnt(x + 7 * scale, y)], weight: 4 * scale,
        colour: Field.ink, wobble: 0.3, taper: false, seed: seed &+ 2)
    pen(p, [pnt(x, y - h * 0.75), pnt(x + 13 * scale, y - h * 0.62)], weight: 3.4 * scale,
        colour: Field.ink, wobble: 0.3, taper: false, seed: seed &+ 3)
}

func drawTripod(_ p: Sheet, at c: CGPoint, height: Double, seed: UInt64) {
    let x = Double(c.x), y = Double(c.y)
    for k in 0..<3 {
        let off = [-1.0, 0.25, 1.0][k] * height * 0.34
        pen(p, [pnt(x, y - height), pnt(x + off, y)], weight: 3.0, colour: Field.sepia,
            wobble: 0.4, taper: false, seed: seed &+ bits(k))
    }
}

func makeTechPlate(_ spec: TechSpec, dir: String) {
    let p = Sheet(1350, 1200)
    let seed = hashOf(spec.id)
    layPaper(p, seed: seed, tone: Field.paperWarm)
    p.topDown()
    p.light = 2.30
    var rng = Dice(seed &+ 5)

    switch spec.kind {
    case "baseline":
        pen(p, [pnt(150, 470), pnt(1200, 470)], weight: 2.4, colour: Field.ink,
            wobble: 0.6, taper: false, seed: seed)
        var x = 190.0
        var k = 0
        while x < 1180 {
            drawTripod(p, at: pnt(x, 470), height: 54, seed: seed &+ bits(k))
            pen(p, [pnt(x, 416), pnt(x + 120, 416)], weight: 5.0, colour: Field.brass,
                wobble: 0.3, taper: false, seed: seed &+ bits(k &+ 40))
            x += 120
            k += 1
        }
        drawFigure(p, at: pnt(180, 470), scale: 1.2, seed: seed &+ 71)
        drawFigure(p, at: pnt(1210, 470), scale: 1.2, seed: seed &+ 73)
        caption(p, "the bars aligned, levelled and read for temperature", at: 150, 540,
                size: 23, colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
        pen(p, [pnt(150, 380), pnt(150, 350)], weight: 1.4, colour: Field.oxblood,
            wobble: 0.2, taper: false, seed: seed &+ 9)
        pen(p, [pnt(1200, 380), pnt(1200, 350)], weight: 1.4, colour: Field.oxblood,
            wobble: 0.2, taper: false, seed: seed &+ 11)
        pen(p, [pnt(150, 365), pnt(1200, 365)], weight: 1.4, colour: Field.oxblood,
            wobble: 0.2, taper: false, seed: seed &+ 13)
        caption(p, "measured base", at: 675, 344, size: 24, colour: Field.oxblood,
                face: "Georgia-Italic", align: .centre)
        for k in 0..<3 {
            let apex = pnt(340.0 + Double(k) * 340, 190)
            pen(p, [pnt(150 + Double(k) * 340, 470), apex], weight: 1.2,
                colour: Field.inkPale, wobble: 0.4, taper: false, seed: seed &+ bits(k &+ 80))
            pen(p, [pnt(490 + Double(k) * 340, 470), apex], weight: 1.2,
                colour: Field.inkPale, wobble: 0.4, taper: false, seed: seed &+ bits(k &+ 90))
            p.disc(Double(apex.x), Double(apex.y), 5, Field.ink)
        }
    case "network":
        var stations: [CGPoint] = []
        for _ in 0..<11 {
            stations.append(pnt(rng.r(180, 1180), rng.r(150, 640)))
        }
        for i in 0..<stations.count {
            for j in (i + 1)..<stations.count {
                let dx = Double(stations[i].x - stations[j].x)
                let dy = Double(stations[i].y - stations[j].y)
                guard (dx * dx + dy * dy).squareRoot() < 340 else { continue }
                pen(p, [stations[i], stations[j]], weight: 1.1, colour: Field.inkPale.al(0.8),
                    wobble: 0.4, taper: false, seed: seed &+ bits(i * 20 + j))
            }
        }
        for (i, s) in stations.enumerated() {
            p.disc(Double(s.x), Double(s.y), 6, Field.ink)
            p.ring(Double(s.x), Double(s.y), 12, 1.2, Field.oxblood)
            caption(p, "\(i + 1)", at: Double(s.x) + 18, Double(s.y) + 6, size: 19,
                    colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
        }
        var coast: [CGPoint] = []
        var cx = 150.0
        while cx < 1200 {
            coast.append(pnt(cx, 660 + sin(cx / 120) * 30 + rng.signed() * 8))
            cx += 40
        }
        for i in 0..<coast.count - 1 {
            pen(p, [coast[i], coast[i + 1]], weight: 2.2, colour: Field.ink, wobble: 0.5,
                taper: false, seed: seed &+ bits(i))
        }
        caption(p, "great triangles first, detail last", at: 150, 720, size: 23,
                colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
    case "resection":
        let a = pnt(300, 200), b = pnt(700, 160), c = pnt(1080, 260)
        let me = pnt(660, 560)
        for (pt0, label) in [(a, "A"), (b, "B"), (c, "C")] {
            p.disc(Double(pt0.x), Double(pt0.y), 7, Field.ink)
            caption(p, label, at: Double(pt0.x), Double(pt0.y) - 18, size: 24, colour: Field.ink,
                    face: "Georgia-Bold", align: .centre)
            pen(p, [me, pt0], weight: 1.4, colour: Field.inkSoft, wobble: 0.4, taper: false,
                seed: seed &+ bits(Int(pt0.x)))
        }
        p.disc(Double(me.x), Double(me.y), 8, Field.oxblood)
        caption(p, "station", at: Double(me.x), Double(me.y) + 34, size: 22, colour: Field.oxblood,
                face: "Georgia-Italic", align: .centre)
        p.ring(640, 330, 262, 1.2, Field.carmine.al(0.6))
        caption(p, "danger circle", at: 640, 60, size: 22, colour: Field.carmine,
                face: "Georgia-Italic", align: .centre)
        var arc: [CGPoint] = []
        var ang = -1.9
        while ang < -1.1 {
            arc.append(pnt(Double(me.x) + cos(ang) * 90, Double(me.y) + sin(ang) * 90))
            ang += 0.08
        }
        pen(p, arc, weight: 1.6, colour: Field.verdigris, wobble: 0.3, taper: false, seed: seed &+ 31)
    case "planetable":
        let board: [CGPoint] = [pnt(300, 380), pnt(900, 330), pnt(940, 470), pnt(340, 520)]
        p.poly(board, Field.paperCool)
        penContour(p, board, weight: 2.4, colour: Field.ink, seed: seed &+ 5)
        drawTripod(p, at: pnt(620, 660), height: 210, seed: seed &+ 7)
        let rule: [CGPoint] = [pnt(400, 470), pnt(860, 386), pnt(864, 410), pnt(404, 494)]
        p.poly(rule, Field.brass)
        penContour(p, rule, weight: 1.8, colour: Field.ink, seed: seed &+ 9)
        pen(p, [pnt(410, 486), pnt(410, 430)], weight: 3.0, colour: Field.brassDark,
            wobble: 0.3, taper: false, seed: seed &+ 11)
        pen(p, [pnt(858, 398), pnt(858, 342)], weight: 3.0, colour: Field.brassDark,
            wobble: 0.3, taper: false, seed: seed &+ 13)
        for k in 0..<3 {
            pen(p, [pnt(430, 470), pnt(1140, 250 - Double(k) * 60)], weight: 1.0,
                colour: Field.graphite, wobble: 0.5, taper: false, seed: seed &+ bits(k &+ 20))
        }
        drawFigure(p, at: pnt(300, 700), scale: 1.5, seed: seed &+ 41)
        for k in 0..<3 {
            let hx = 1000.0 + Double(k) * 80
            p.poly([pnt(hx - 40, 700), pnt(hx, 640 - Double(k) * 20), pnt(hx + 40, 700)],
                   Field.inkPale.al(0.5))
        }
        caption(p, "sight the object, rule the ray, move on", at: 300, 780, size: 23,
                colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
    case "chain":
        pen(p, [pnt(200, 560), pnt(1150, 470)], weight: 2.0, colour: Field.oxblood,
            wobble: 0.3, taper: false, seed: seed &+ 5)
        var t = 0.0
        var k = 0
        while t <= 1.0 {
            let x = 200 + t * 950
            let y = 560 - t * 90
            pen(p, [pnt(x, y - 5), pnt(x, y + 5)], weight: 1.4, colour: Field.oxblood,
                wobble: 0.2, taper: false, seed: seed &+ bits(k))
            t += 0.1
            k += 1
        }
        var hedge: [CGPoint] = []
        var hx = 200.0
        while hx < 1160 {
            hedge.append(pnt(hx, 380 + sin(hx / 90) * 46 + rng.signed() * 10))
            hx += 40
        }
        for i in 0..<hedge.count - 1 {
            pen(p, [hedge[i], hedge[i + 1]], weight: 2.0, colour: Field.moss.dk(0.1),
                wobble: 0.8, taper: false, seed: seed &+ bits(i))
        }
        for i in stride(from: 0, to: hedge.count, by: 2) {
            let hxp = Double(hedge[i].x)
            let ty = (hxp - 200) / 950
            let baseY = 560 - ty * 90
            pen(p, [pnt(hxp, baseY), hedge[i]], weight: 1.0, colour: Field.graphite,
                wobble: 0.3, taper: false, seed: seed &+ bits(i &+ 60))
            caption(p, "\(Int(baseY - Double(hedge[i].y)))", at: hxp + 6,
                    (baseY + Double(hedge[i].y)) / 2, size: 16, colour: Field.inkPale,
                    face: "Georgia-Italic", align: .left)
        }
        drawFigure(p, at: pnt(200, 600), scale: 1.1, seed: seed &+ 71)
        drawFigure(p, at: pnt(1150, 510), scale: 1.1, seed: seed &+ 73)
        caption(p, "offsets at every change of direction", at: 200, 680, size: 23,
                colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
    case "soundings":
        var coast: [CGPoint] = []
        var cx = 150.0
        while cx < 1210 {
            coast.append(pnt(cx, 250 + sin(cx / 140) * 40 + rng.signed() * 8))
            cx += 40
        }
        for i in 0..<coast.count - 1 {
            pen(p, [coast[i], coast[i + 1]], weight: 2.2, colour: Field.ink, wobble: 0.5,
                taper: false, seed: seed &+ bits(i))
        }
        for line in 0..<5 {
            let y = 340.0 + Double(line) * 78
            pen(p, [pnt(170, y), pnt(1190, y - 14)], weight: 0.9, colour: Field.seaDeep.al(0.7),
                wobble: 0.4, taper: false, seed: seed &+ bits(line &+ 10))
            var sx = 190.0
            while sx < 1180 {
                caption(p, "\(rng.i(3, 19))", at: sx, y - 6 - (sx - 170) / 1020 * 14, size: 17,
                        colour: Field.inkSoft, face: "Georgia-Italic", align: .centre)
                sx += 74
            }
        }
        let boat = pnt(640, 420)
        p.poly([pnt(Double(boat.x) - 34, Double(boat.y)), pnt(Double(boat.x) + 34, Double(boat.y)),
                pnt(Double(boat.x) + 24, Double(boat.y) + 14),
                pnt(Double(boat.x) - 24, Double(boat.y) + 14)], Field.ink)
        pen(p, [pnt(Double(boat.x) + 20, Double(boat.y) + 8), pnt(Double(boat.x) + 30, 470)],
            weight: 1.2, colour: Field.inkSoft, wobble: 0.4, taper: false, seed: seed &+ 33)
        p.disc(Double(boat.x) + 30, 476, 6, Field.ink)
        for target in [pnt(300, 236), pnt(980, 224)] {
            pen(p, [boat, target], weight: 1.0, colour: Field.carmine.al(0.7),
                wobble: 0.3, taper: false, seed: seed &+ bits(Int(target.x)))
            p.disc(Double(target.x), Double(target.y), 6, Field.oxblood)
        }
        caption(p, "fixed by sextant angles to the shore", at: 150, 760, size: 23,
                colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
    case "datum":
        let levels: [(Double, String, Tone)] = [(240, "highest tide", Field.seaDeep),
                                                (300, "mean high water springs", Field.seaBlue),
                                                (430, "mean sea level", Field.inkPale),
                                                (560, "chart datum", Field.oxblood)]
        for (y, label, tone) in levels {
            pen(p, [pnt(200, y), pnt(1150, y)], weight: 1.8, colour: tone,
                wobble: 0.3, taper: false, seed: seed &+ bits(Int(y)))
            caption(p, label, at: 1160, y + 6, size: 20, colour: tone, face: "Georgia-Italic",
                    align: .left)
        }
        p.clipRect(CGRect(x: 200, y: 300, width: 950, height: 260)) {
            p.ctx.setFillColor(cg(Field.seaBlue.al(0.22)))
            p.ctx.fill(CGRect(x: 200, y: 300, width: 950, height: 260))
        }
        var bed: [CGPoint] = [pnt(200, 700)]
        var bx = 200.0
        while bx < 1150 {
            bed.append(pnt(bx, 640 - sin(bx / 200) * 90 + rng.signed() * 10))
            bx += 40
        }
        bed.append(pnt(1150, 700))
        p.poly(bed, Field.sand)
        for i in 1..<bed.count - 2 {
            pen(p, [bed[i], bed[i + 1]], weight: 2.0, colour: Field.sepia, wobble: 0.6,
                taper: false, seed: seed &+ bits(i))
        }
        let bankTop = pnt(700, 470)
        p.poly([pnt(560, 560), bankTop, pnt(840, 560)], Field.sand.dk(0.06))
        stipple(p, pathOf([pnt(560, 560), bankTop, pnt(840, 560)]), density: 0.004,
                sizeMin: 0.6, sizeMax: 1.8, colour: Field.sepia.al(0.7), seed: seed &+ 21)
        pen(p, [pnt(700, 470), pnt(700, 560)], weight: 1.2, colour: Field.oxblood,
            wobble: 0.2, taper: false, seed: seed &+ 23)
        caption(p, "3", at: 726, 520, size: 22, colour: Field.oxblood, face: "Georgia-Italic",
                align: .left)
        pen(p, [pnt(720, 528), pnt(742, 528)], weight: 1.4, colour: Field.oxblood,
            wobble: 0.2, taper: false, seed: seed &+ 25)
        caption(p, "dries 3 feet", at: 760, 520, size: 19, colour: Field.inkSoft,
                face: "Georgia-Italic", align: .left)
        caption(p, "5", at: 380, 610, size: 22, colour: Field.inkSoft, face: "Georgia-Italic",
                align: .centre)
        caption(p, "sounding, reduced to datum", at: 200, 760, size: 23, colour: Field.inkSoft,
                face: "Georgia-Italic", align: .left)
    case "hachures":
        let leftC = pnt(400, 400)
        var ringR = 40.0
        while ringR < 190 {
            let count = Int(ringR / 3)
            for k in 0..<count {
                let a = Double(k) / Double(count) * 6.283
                let steep = 0.4 + 0.6 * pow(sin(a * 2 + 1), 2)
                pen(p, [pnt(Double(leftC.x) + cos(a) * ringR, Double(leftC.y) + sin(a) * ringR),
                        pnt(Double(leftC.x) + cos(a) * (ringR + 26 * (1.2 - steep)),
                            Double(leftC.y) + sin(a) * (ringR + 26 * (1.2 - steep)))],
                    weight: 0.8 + steep * 1.6, colour: Field.ink.al(0.5 + steep * 0.4),
                    wobble: 0.4, taper: true, seed: seed &+ bits(k &+ Int(ringR)))
            }
            ringR += 34
        }
        let rightC = pnt(960, 400)
        var contourR = 40.0
        var level = 300
        while contourR < 200 {
            var ring: [CGPoint] = []
            var a = 0.0
            while a < 6.283 {
                let steep = 0.4 + 0.6 * pow(sin(a * 2 + 1), 2)
                ring.append(pnt(Double(rightC.x) + cos(a) * contourR * (1.4 - steep * 0.5),
                                Double(rightC.y) + sin(a) * contourR * (1.4 - steep * 0.5)))
                a += 0.16
            }
            for i in 0..<ring.count {
                pen(p, [ring[i], ring[(i + 1) % ring.count]], weight: 1.2,
                    colour: Field.sepia.al(0.85), wobble: 0.4, taper: false,
                    seed: seed &+ bits(i &+ level))
            }
            caption(p, "\(level)", at: Double(ring[3].x), Double(ring[3].y), size: 16,
                    colour: Field.sepia, face: "Georgia-Italic", align: .centre)
            contourR += 36
            level -= 50
        }
        caption(p, "hachures", at: 400, 640, size: 26, colour: Field.ink, face: "Georgia",
                align: .centre)
        caption(p, "contours", at: 960, 640, size: 26, colour: Field.ink, face: "Georgia",
                align: .centre)
        caption(p, "the same hill, surveyed once", at: 150, 740, size: 23, colour: Field.inkSoft,
                face: "Georgia-Italic", align: .left)
    case "signs":
        let names = ["marsh", "rough pasture", "wood", "orchard", "sand", "shingle",
                     "rock awash", "rock covered", "wreck", "anchorage", "beacon", "church"]
        for k in 0..<12 {
            let col = k % 4, row = k / 4
            let cx0 = 240.0 + Double(col) * 270
            let cy0 = 220.0 + Double(row) * 170
            p.rect(cx0 - 90, cy0 - 60, 180, 110, Field.paperCool.al(0.5))
            penContour(p, [pnt(cx0 - 90, cy0 - 60), pnt(cx0 + 90, cy0 - 60),
                           pnt(cx0 + 90, cy0 + 50), pnt(cx0 - 90, cy0 + 50)],
                       weight: 1.0, colour: Field.inkPale, seed: seed &+ bits(k))
            switch k {
            case 0:
                for j in 0..<6 {
                    let sx = cx0 - 60 + Double(j % 3) * 50
                    let sy = cy0 - 30 + Double(j / 3) * 40
                    pen(p, [pnt(sx - 9, sy), pnt(sx + 9, sy)], weight: 1.2, colour: Field.marsh,
                        wobble: 0.3, taper: false, seed: seed &+ bits(j))
                    pen(p, [pnt(sx - 4, sy - 7), pnt(sx - 4, sy)], weight: 1.0, colour: Field.marsh,
                        wobble: 0.3, taper: true, seed: seed &+ bits(j &+ 5))
                }
            case 1:
                for _ in 0..<40 { p.disc(cx0 + rng.r(-70, 70), cy0 + rng.r(-40, 30), 1.4, Field.moss) }
            case 2:
                for j in 0..<7 {
                    let sx = cx0 - 60 + Double(j) * 20
                    p.disc(sx, cy0 + rng.r(-20, 10), 7, Field.moss.al(0.5))
                    p.ring(sx, cy0 + rng.r(-20, 10), 8, 1.0, Field.moss)
                }
            case 3:
                for j in 0..<9 {
                    p.ring(cx0 - 50 + Double(j % 3) * 50, cy0 - 25 + Double(j / 3) * 30, 6, 1.0,
                           Field.moss)
                }
            case 4:
                stipple(p, pathOf([pnt(cx0 - 80, cy0 - 50), pnt(cx0 + 80, cy0 - 50),
                                   pnt(cx0 + 80, cy0 + 40), pnt(cx0 - 80, cy0 + 40)]),
                        density: 0.004, sizeMin: 0.6, sizeMax: 1.6, colour: Field.sepia,
                        seed: seed &+ 3)
            case 5:
                for _ in 0..<26 {
                    p.ellipse(cx0 + rng.r(-70, 70), cy0 + rng.r(-40, 30), rng.r(2, 4),
                              rng.r(1.4, 3), Field.inkPale)
                }
            case 6:
                for j in 0..<3 {
                    let a = Double(j) / 3 * 3.14
                    pen(p, [pnt(cx0 - cos(a) * 16, cy0 - sin(a) * 16),
                            pnt(cx0 + cos(a) * 16, cy0 + sin(a) * 16)], weight: 1.8,
                        colour: Field.ink, wobble: 0.2, taper: false, seed: seed &+ bits(j))
                }
            case 7:
                for j in 0..<3 {
                    let a = Double(j) / 3 * 3.14
                    pen(p, [pnt(cx0 - cos(a) * 14, cy0 - sin(a) * 14),
                            pnt(cx0 + cos(a) * 14, cy0 + sin(a) * 14)], weight: 1.6,
                        colour: Field.ink, wobble: 0.2, taper: false, seed: seed &+ bits(j))
                }
                for j in 0..<5 {
                    let a = Double(j) / 5 * 6.283
                    p.disc(cx0 + cos(a) * 30, cy0 + sin(a) * 26, 1.6, Field.ink)
                }
            case 8:
                pen(p, [pnt(cx0 - 34, cy0), pnt(cx0 + 34, cy0)], weight: 2.0, colour: Field.ink,
                    wobble: 0.3, taper: false, seed: seed &+ 7)
                pen(p, [pnt(cx0 - 16, cy0 - 12), pnt(cx0 - 16, cy0 + 12)], weight: 1.6,
                    colour: Field.ink, wobble: 0.3, taper: false, seed: seed &+ 9)
                pen(p, [pnt(cx0 + 8, cy0 - 14), pnt(cx0 + 8, cy0 + 14)], weight: 1.6,
                    colour: Field.ink, wobble: 0.3, taper: false, seed: seed &+ 11)
            case 9:
                pen(p, [pnt(cx0, cy0 - 26), pnt(cx0, cy0 + 20)], weight: 2.2, colour: Field.ink,
                    wobble: 0.2, taper: false, seed: seed &+ 13)
                pen(p, [pnt(cx0 - 16, cy0 - 16), pnt(cx0 + 16, cy0 - 16)], weight: 2.0,
                    colour: Field.ink, wobble: 0.2, taper: false, seed: seed &+ 15)
                var hook: [CGPoint] = []
                var a = 0.2
                while a < 2.9 {
                    hook.append(pnt(cx0 + cos(a) * 22 * -1, cy0 + 20 + sin(a) * 14))
                    a += 0.2
                }
                pen(p, hook, weight: 2.0, colour: Field.ink, wobble: 0.3, taper: false,
                    seed: seed &+ 17)
            case 10:
                pen(p, [pnt(cx0, cy0 + 24), pnt(cx0, cy0 - 26)], weight: 2.4, colour: Field.ink,
                    wobble: 0.2, taper: false, seed: seed &+ 19)
                p.poly([pnt(cx0, cy0 - 30), pnt(cx0 + 18, cy0 - 20), pnt(cx0, cy0 - 12)], Field.ink)
            default:
                p.rect(cx0 - 16, cy0 - 10, 32, 30, Field.ink.al(0.85))
                pen(p, [pnt(cx0, cy0 - 40), pnt(cx0, cy0 - 10)], weight: 2.0, colour: Field.ink,
                    wobble: 0.2, taper: false, seed: seed &+ 21)
                pen(p, [pnt(cx0 - 8, cy0 - 32), pnt(cx0 + 8, cy0 - 32)], weight: 1.8,
                    colour: Field.ink, wobble: 0.2, taper: false, seed: seed &+ 23)
            }
            caption(p, names[k], at: cx0, cy0 + 74, size: 19, colour: Field.inkSoft,
                    face: "Georgia", align: .centre)
        }
    case "lettering":
        caption(p, "STONEHAVEN", at: 200, 240, size: 40, colour: Field.ink, face: "Georgia-Bold",
                align: .left, tracking: 6)
        caption(p, "upright: anything you can stand on", at: 200, 280, size: 21,
                colour: Field.inkPale, face: "Georgia-Italic", align: .left)
        caption(p, "Thrift Sands", at: 200, 380, size: 40, colour: Field.ink, face: "Georgia-Italic",
                align: .left)
        caption(p, "sloping: anything that floats, flows or covers", at: 200, 420, size: 21,
                colour: Field.inkPale, face: "Georgia-Italic", align: .left)
        var curve: [CGPoint] = []
        var t2 = 0.0
        while t2 <= 1.0 {
            curve.append(pnt(220 + t2 * 900, 600 + sin(t2 * 3.2) * 70))
            t2 += 0.02
        }
        for i in 0..<curve.count - 1 {
            pen(p, [curve[i], curve[i + 1]], weight: 1.0, colour: Field.graphite.al(0.5),
                wobble: 0.2, taper: false, seed: seed &+ bits(i))
        }
        let word = Array("R I V E R   C A L D E R")
        for (i, ch) in word.enumerated() {
            let t3 = Double(i) / Double(word.count - 1)
            let idx = min(curve.count - 2, Int(t3 * Double(curve.count - 1)))
            let a = curve[idx], b = curve[idx + 1]
            let ang = atan2(Double(b.y - a.y), Double(b.x - a.x))
            caption(p, String(ch), at: Double(a.x), Double(a.y) - 8, size: 26, colour: Field.ink,
                    face: "Georgia-Italic", align: .centre, rotate: ang)
        }
        caption(p, "names follow the feature and never cross the coast", at: 200, 760,
                size: 23, colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
    case "rose":
        compassRose(p, at: pnt(560, 420), radius: 230, seed: seed &+ 5)
        p.ring(560, 420, 178, 1.4, Field.carmine.al(0.8))
        for k in 0..<32 {
            let a = Double(k) / 32 * 6.283 - 1.5708 + 0.22
            pen(p, [pnt(560 + cos(a) * 162, 420 + sin(a) * 162),
                    pnt(560 + cos(a) * 178, 420 + sin(a) * 178)], weight: k % 8 == 0 ? 1.8 : 0.9,
                colour: Field.carmine.al(0.8), wobble: 0.2, taper: false, seed: seed &+ bits(k))
        }
        pen(p, [pnt(560, 420), pnt(560 + cos(-1.35) * 200, 420 + sin(-1.35) * 200)], weight: 2.4,
            colour: Field.carmine, wobble: 0.2, taper: false, seed: seed &+ 41)
        caption(p, "magnetic", at: 800, 236, size: 22, colour: Field.carmine,
                face: "Georgia-Italic", align: .left)
        caption(p, "true", at: 560, 150, size: 22, colour: Field.ink, face: "Georgia-Italic",
                align: .centre)
        caption(p, "Var. 18° 40' W in 1850,", at: 900, 440, size: 22, colour: Field.inkSoft,
                face: "Georgia-Italic", align: .left)
        caption(p, "decreasing about 8' yearly", at: 900, 472, size: 22, colour: Field.inkSoft,
                face: "Georgia-Italic", align: .left)
    default:
        let plate: [CGPoint] = [pnt(240, 220), pnt(1080, 190), pnt(1100, 600), pnt(260, 640)]
        p.poly(plate, Field.brass.dk(0.06))
        formShade(p, plate, inset: 60, depth: 2, spacing: 8, colour: Field.inkSoft, seed: seed)
        penContour(p, plate, weight: 2.6, colour: Field.ink, seed: seed &+ 5)
        var coast2: [CGPoint] = []
        var cx2 = 300.0
        while cx2 < 1040 {
            coast2.append(pnt(cx2, 400 + sin(cx2 / 110) * 60))
            cx2 += 30
        }
        for i in 0..<coast2.count - 1 {
            pen(p, [coast2[i], coast2[i + 1]], weight: 1.6, colour: Field.ink.al(0.8),
                wobble: 0.3, taper: false, seed: seed &+ bits(i))
        }
        let burin: [CGPoint] = [pnt(700, 300), pnt(940, 130), pnt(986, 176), pnt(742, 340)]
        p.poly(burin, Field.sepia)
        penContour(p, burin, weight: 2.2, colour: Field.ink, seed: seed &+ 7)
        p.poly([pnt(700, 300), pnt(742, 340), pnt(686, 352)], Field.graphite)
        for k in 0..<6 {
            pen(p, [pnt(676 + Double(k) * 5, 360), pnt(650 + Double(k) * 5, 400)], weight: 1.0,
                colour: Field.brass.lt(0.2), wobble: 0.6, taper: true, seed: seed &+ bits(k))
        }
        caption(p, "cut in reverse, lettering and all", at: 240, 720, size: 23,
                colour: Field.inkSoft, face: "Georgia-Italic", align: .left)
    }

    caption(p, spec.kicker.uppercased(), at: 120, 88, size: 20, colour: Field.oxblood,
            face: "Georgia-Bold", align: .left, tracking: 3.4)
    caption(p, spec.title, at: 120, 830, size: 50, colour: Field.ink, face: "Georgia-Bold", align: .left)
    caption(p, spec.sub, at: 120, 868, size: 25, colour: Field.inkPale, face: "Georgia-Italic",
            align: .left)

    var y = 920.0
    for note in spec.notes {
        caption(p, note.0.uppercased(), at: 120, y, size: 18, colour: Field.sepia,
                face: "Georgia-Bold", align: .left, tracking: 2.4)
        y += 28
        for line in wrapText(note.1, width: 1110, size: 22) {
            caption(p, line, at: 120, y, size: 22, colour: Field.inkSoft, face: "Georgia", align: .left)
            y += 28
        }
        y += 10
    }

    plateFrame(p, inset: 44, seed: seed &+ 99)
    p.write(dir, "tech_" + spec.id, quality: 0.88)
}
