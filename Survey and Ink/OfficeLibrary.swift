import SwiftUI

struct TechEntry {
    let id: String
    let kicker: String
    let title: String
    let sub: String
    let summary: String
    var plate: String { "tech_" + id }
}

struct ToolEntry {
    let id: String
    let name: String
    let note: String
    var plate: String { "inst_" + id }
}

enum Office {
    static let technique: [TechEntry] = techA + techB

    private static let techA: [TechEntry] = [
        TechEntry(id: "baseline", kicker: "Plate I", title: "The base",
                  sub: "One measured line, and everything else is arithmetic",
                  summary: "A survey contains exactly one measured distance. The base is chained on trestles, aligned by theodolite and corrected for temperature and sag, and every other length on the sheet is computed from it."),
        TechEntry(id: "triangulation", kicker: "Plate II", title: "The network",
                  sub: "Triangles carried across a country",
                  summary: "Great triangles between hilltops first, smaller ones inside them, detail last. A triangle with an angle under thirty degrees computes badly, so stations are chosen for shape as much as for view."),
        TechEntry(id: "resection", kicker: "Plate III", title: "Fixing your own position",
                  sub: "Two angles, three known points, and one trap",
                  summary: "Each angle puts you on a circle through two of the objects, and the circles cross at your station. Unless all three points and you lie on one circle, in which case there is no fix at all."),
        TechEntry(id: "planetable", kicker: "Plate IV", title: "The plane table",
                  sub: "A survey that draws itself in the field",
                  summary: "Sight the object along the alidade and rule a line; from a second station rule another; where they cross is the object. No angle is ever written down and no computation is ever made."),
        TechEntry(id: "chain", kicker: "Plate V", title: "Chain and offsets",
                  sub: "The cheapest survey there is",
                  summary: "Sixty-six feet in a hundred links, because ten square chains make an acre. Run the line straight and measure short perpendicular offsets to the hedge at every bend."),
        TechEntry(id: "soundings", kicker: "Plate VI", title: "Lines of soundings",
                  sub: "How the sea floor gets onto paper",
                  summary: "A boat rows a straight line while the leadsman heaves and the officer fixes her by sextant angles. Every number on a chart was once a wet rope and a shout."),
    ]

    private static let techB: [TechEntry] = [
        TechEntry(id: "datum", kicker: "Plate VII", title: "Which zero",
                  sub: "Depths from one level, heights from another",
                  summary: "Soundings are reduced to about the lowest tide expected; drying heights carry a line under the figure; land heights and clearances use different zeros again. Three zeros on one sheet."),
        TechEntry(id: "hachures", kicker: "Plate VIII", title: "Hachures and contours",
                  sub: "The same hill drawn two ways",
                  summary: "Hachures run straight down the fall of the ground and make a hill look like a hill. Contours look like nothing until you learn them, and then they give height, slope and line of sight."),
        TechEntry(id: "signs", kicker: "Plate IX", title: "Conventional signs",
                  sub: "A language small enough to fit between the names",
                  summary: "Marsh, pasture, wood and orchard are a repeated small symbol scattered over the ground, never an outlined area, so the eye reads texture and the space stays free for lettering."),
        TechEntry(id: "lettering", kicker: "Plate X", title: "Lettering",
                  sub: "The slowest and most visible work on the sheet",
                  summary: "Upright for anything you can stand on, sloping for anything that floats or covers. A name follows its feature, never crosses a coastline, and its size alone gives the rank of the place."),
        TechEntry(id: "rose", kicker: "Plate XI", title: "The compass rose",
                  sub: "Two norths on one card",
                  summary: "True north from the survey, magnetic north from the compass, and the variation with its annual change written between them. Working an old bearing without correcting it is a classic way to lose a ship."),
        TechEntry(id: "engraving", kicker: "Plate XII", title: "Onto copper",
                  sub: "Cut backwards, printed forwards",
                  summary: "A burin pushed through copper throws up a curl of metal and leaves a line finer than any pen. The engraver cuts the whole chart in reverse, lettering included."),
    ]

    static let instruments: [ToolEntry] = [
        ToolEntry(id: "planetable", name: "Plane table and alidade",
                  note: "A drawing board on a tripod and a brass rule with sight vanes, so the survey is drawn in the presence of the ground it describes."),
        ToolEntry(id: "theodolite", name: "The theodolite",
                  note: "A telescope that can be pointed anywhere and read against two graduated circles. Every triangle in a national survey came out of one."),
        ToolEntry(id: "chain", name: "Gunter's chain and arrows",
                  note: "A hundred links and ten arrows. The odd length exists so that ten square chains make an acre."),
        ToolEntry(id: "level", name: "Level and staff",
                  note: "A telescope that will only look horizontally and a graduated staff, carrying a height across a country a few feet at a time."),
        ToolEntry(id: "pens", name: "Ruling pen and dividers",
                  note: "The pen sets its width with a screw and holds ink between two blades; the dividers step a distance off the scale without reading a number."),
        ToolEntry(id: "station", name: "Station mark and pole",
                  note: "A cut cross, a buried stone, a cairn and a whitened pole, so the next survey can stand exactly where this one stood."),
    ]
}
