import SwiftUI

enum GroundBook {
    static let all: [Ground] = listA + listB + listC

    static func ground(_ id: String) -> Ground? { all.first { $0.id == id } }

    private static let listA: [Ground] = [
        Ground(id: "carrick_bay", name: "Carrick Bay", place: "Western coast", year: "1841",
               kind: "bay", kicker: "Sheet I",
               blurb: "The head of a bay is out of sight of its entrance, so the work is a chain of triangles carried round the shore until it closes on itself.",
               difficulty: 1),
        Ground(id: "ossary_island", name: "Ossary Island", place: "Outer approaches", year: "1838",
               kind: "island", kicker: "Sheet II",
               blurb: "Standing on unknown ground with three known points in sight, two angles fix the station. Unless you happen to stand on the danger circle.",
               difficulty: 2),
        Ground(id: "mardle_estuary", name: "Mardle Estuary", place: "Tidal reaches", year: "1846",
               kind: "estuary", kicker: "Sheet III",
               blurb: "A chart has two shorelines, high water and low, and between them a mile of ground that is land twice a day and sea twice a day.",
               difficulty: 3),
        Ground(id: "black_head", name: "Black Head", place: "Northern seaboard", year: "1852",
               kind: "cape", kicker: "Sheet IV",
               blurb: "Hachures run with the fall of the water: short, thick and crowded on steep ground, long and fine on gentle.",
               difficulty: 2),
        Ground(id: "wrenport", name: "Wrenport Harbour", place: "Packet station", year: "1859",
               kind: "harbour", kicker: "Sheet V",
               blurb: "Two objects in line give a bearing more exactly than any compass, so a harbour survey hunts for leading marks.",
               difficulty: 2),
        Ground(id: "loch_tarbh", name: "Loch Tarbh", place: "Sea loch", year: "1848",
               kind: "loch", kicker: "Sheet VI",
               blurb: "Every number on the chart was once a wet rope and a shout from a boat rowing a straight line between two marks.",
               difficulty: 3),
        Ground(id: "thrift_sands", name: "Thrift Sands", place: "Outer bank", year: "1843",
               kind: "bay", kicker: "Sheet VII",
               blurb: "A bank surveyed one decade is not where the chart says the next. The date in the cartouche is a warning, not decoration.",
               difficulty: 3),
        Ground(id: "crag_sound", name: "Crag Sound", place: "Inner passage", year: "1855",
               kind: "sound", kicker: "Sheet VIII",
               blurb: "A sound runs like a river and turns twice a day, and the rate is taken from a boat anchored for a whole tide.",
               difficulty: 3),
    ]

    private static let listB: [Ground] = [
        Ground(id: "sker_reef", name: "Sker Reef", place: "Offshore dangers", year: "1861",
               kind: "reef", kicker: "Sheet IX",
               blurb: "A cross for a rock that never covers, a cross with dots for one that uncovers, a dotted circle for one nobody is sure of.",
               difficulty: 4),
        Ground(id: "dunmore_haven", name: "Dunmore Haven", place: "Fishing haven", year: "1857",
               kind: "harbour", kicker: "Sheet X",
               blurb: "The surveyor writes down what the people on the shore call each gully, and half the odd names on any chart are a mishearing that outlived him.",
               difficulty: 2),
        Ground(id: "glass_water", name: "The Glass Water", place: "Inland water", year: "1850",
               kind: "loch", kicker: "Sheet XI",
               blurb: "Point the rule at the object and draw the ray. Move, draw again, and the intersection is the object's place. No angle is ever written down.",
               difficulty: 2),
        Ground(id: "hallow_delta", name: "Hallow Delta", place: "River mouth", year: "1864",
               kind: "delta", kicker: "Sheet XII",
               blurb: "Run the chain along a straight line and measure short offsets to the bank. It is the cheapest survey there is.",
               difficulty: 3),
        Ground(id: "north_ness", name: "North Ness", place: "Northern isles", year: "1866",
               kind: "cape", kicker: "Sheet XIII",
               blurb: "The compass does not point north, and the difference changes with the place and the year. The rose carries both norths for a reason.",
               difficulty: 4),
        Ground(id: "lammer_bay", name: "Lammer Bay", place: "Eastern coast", year: "1844",
               kind: "bay", kicker: "Sheet XIV",
               blurb: "Three bearings should meet in a point and never do. A careful surveyor assumes he is at the worst corner of the little triangle they make.",
               difficulty: 2),
        Ground(id: "quarry_isle", name: "Quarry Isle", place: "Granite island", year: "1853",
               kind: "island", kicker: "Sheet XV",
               blurb: "Charts were engraved in reverse on copper with a burin, which is why the lines can be a hair fine and still print black.",
               difficulty: 3),
        Ground(id: "faither_fjord", name: "The Faither", place: "Deep inlet", year: "1869",
               kind: "fjord", kicker: "Sheet XVI",
               blurb: "A hand lead reaches about twenty fathoms. Beyond that every sounding costs the ship a stop and a cold hour.",
               difficulty: 4),
    ]

    private static let listC: [Ground] = [
        Ground(id: "dorn_narrows", name: "Dorn Narrows", place: "Tidal narrows", year: "1858",
               kind: "sound", kicker: "Sheet XVII",
               blurb: "A ship can chart a coast without landing: bearings of headlands, the run between them by log, and the whole strung together.",
               difficulty: 4),
        Ground(id: "the_saltings", name: "The Saltings", place: "Marsh and creek", year: "1847",
               kind: "estuary", kicker: "Sheet XVIII",
               blurb: "Marsh is a tuft with two short strokes, repeated and never outlined, so the eye reads texture and the space stays free for names.",
               difficulty: 3),
        Ground(id: "the_mewstone", name: "The Mewstone", place: "Approach mark", year: "1862",
               kind: "island", kicker: "Sheet XIX",
               blurb: "The coastal profiles along an old chart's border are measured drawings, not sketches, and for a stranger they are worth the whole survey.",
               difficulty: 3),
        Ground(id: "broad_water", name: "Broad Water", place: "Shallow bay", year: "1851",
               kind: "bay", kicker: "Sheet XX",
               blurb: "Tallow in the hollow of the lead brings up sand, shell or mud, and a master in fog navigates by what comes up on it.",
               difficulty: 2),
        Ground(id: "calder_mouth", name: "Calder Mouth", place: "Bar harbour", year: "1867",
               kind: "estuary", kicker: "Sheet XXI",
               blurb: "Where a river's silt meets the sea's swell there is a bar, shallowest exactly where everyone must cross.",
               difficulty: 4),
        Ground(id: "hoy_skerries", name: "Hoy Skerries", place: "Outlying rocks", year: "1871",
               kind: "reef", kicker: "Sheet XXII",
               blurb: "Keep the church open west of the cliff and you pass outside the reef. A clearing mark needs no instrument at all.",
               difficulty: 5),
        Ground(id: "penhale_cove", name: "Penhale Cove", place: "Boat cove", year: "1849",
               kind: "harbour", kicker: "Sheet XXIII",
               blurb: "The scale of a chart is set by the danger and not by the importance of the place, so a cove for six boats gets a large sheet.",
               difficulty: 1),
        Ground(id: "white_horse_bank", name: "White Horse Bank", place: "Offshore shoal", year: "1873",
               kind: "reef", kicker: "Sheet XXIV",
               blurb: "The white water over a shoal is what names it, and the name is generally older than any chart of it.",
               difficulty: 5),
    ]
}

struct SurveyRank {
    let name: String
    let need: Int
    let note: String
}

enum SurveyRanks {
    static let ladder: [SurveyRank] = [
        SurveyRank(name: "Chainman", need: 0,
                   note: "You carry the chain, hold the staff and are trusted with nothing that has a screw on it."),
        SurveyRank(name: "Draughtsman", need: 440,
                   note: "You ink the fair copy from another man's field book and your lettering is beginning to be praised."),
        SurveyRank(name: "Assistant Surveyor", need: 1450,
                   note: "You take your own angles, and the errors in the sheet are now yours to explain."),
        SurveyRank(name: "Surveyor", need: 3300,
                   note: "The sheet goes out under your name and the engraver works from your drawing."),
        SurveyRank(name: "Hydrographer", need: 6600,
                   note: "You decide what is surveyed, at what scale, and which old chart is no longer to be trusted."),
    ]

    static func rank(for points: Int) -> SurveyRank {
        var current = ladder[0]
        for r in ladder where points >= r.need { current = r }
        return current
    }

    static func next(for points: Int) -> SurveyRank? { ladder.first { $0.need > points } }
}

struct Order {
    let ground: Ground
    let title: String
    let note: String
    let target: Int
}

enum Orders {
    static let epoch: TimeInterval = 1_767_225_600

    static func dayIndex(_ date: Date = Date()) -> Int {
        max(0, Int((date.timeIntervalSince1970 - epoch) / 86400))
    }

    static func forDay(_ day: Int) -> Order {
        var rng = Draw(UInt64(day &* 2_654_435_761 &+ 7717))
        let ground = GroundBook.all[rng.index(GroundBook.all.count)]
        let titles = ["The Hydrographer wants a fair copy",
                      "A packet company has asked for this sheet",
                      "The old chart is forty years out and nobody trusts it",
                      "A wreck last winter, and questions asked in London",
                      "The harbour board will pay for a plan and nothing else",
                      "The engraver is idle and wants work by Friday",
                      "A new light is proposed and needs the ground surveyed",
                      "The trustees want it before the season opens"]
        let notes = ["Angles first, and do not let the triangles get thin.",
                     "They will accept a rough coast but not a wrong fix.",
                     "The lettering will be looked at as closely as the soundings.",
                     "The weather is thick, so take your marks while you can see them.",
                     "Everything on one sheet, and the cartouche is to be plain."]
        let target = [60, 66, 72, 78, 84][rng.index(5)]
        return Order(ground: ground, title: titles[rng.index(titles.count)],
                     note: notes[rng.index(notes.count)], target: target)
    }
}
