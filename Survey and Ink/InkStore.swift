import SwiftUI

struct ChartRecord: Codable {
    var groundId: String
    var day: Int
    var grade: String
    var overall: Double
    var fix: Double
    var ink: Double
    var hachure: Double
    var lettering: Double
    var soundings: Double
    var coastStrokes: [[Double]]
    var hachureStrokes: [[Double]]
    var nameCurve: [Double]
    var fixes: [Double]
}

struct DayOrder: Codable {
    var day: Int
    var groundId: String
    var overall: Double
    var target: Int
    var met: Bool
}

struct InkSnapshot: Codable {
    var onboarded: Bool?
    var points: Int?
    var streak: Int?
    var bestStreak: Int?
    var lastDrawnDay: Int?
    var charts: [String: ChartRecord]?
    var orders: [DayOrder]?
    var surveys: Int?
    var marksTaken: Int?
    var milesInked: Int?
    var plateRead: [String]?
}

final class InkStore: ObservableObject {
    @Published var onboarded = false
    @Published var points = 0
    @Published var streak = 0
    @Published var bestStreak = 0
    @Published var lastDrawnDay = -1
    @Published var charts: [String: ChartRecord] = [:]
    @Published var orders: [DayOrder] = []
    @Published var surveys = 0
    @Published var marksTaken = 0
    @Published var milesInked = 0
    @Published var plateRead: Set<String> = []

    private let key = "surveyandink.portfolio.v1"

    init() { load() }

    var liveStreak: Int {
        let today = Orders.dayIndex()
        if lastDrawnDay == today || lastDrawnDay == today - 1 { return streak }
        return 0
    }

    var rank: SurveyRank { SurveyRanks.rank(for: points) }
    var nextRank: SurveyRank? { SurveyRanks.next(for: points) }
    var rankProgress: Double {
        guard let next = nextRank else { return 1 }
        let base = rank.need
        return max(0, min(1, Double(points - base) / Double(max(1, next.need - base))))
    }

    var chartCount: Int { charts.count }
    var topGrades: Int { charts.values.filter { $0.grade == "A" }.count }

    func record(for id: String) -> ChartRecord? { charts[id] }
    func drawnToday() -> Bool { lastDrawnDay == Orders.dayIndex() }
    func todayOrder() -> DayOrder? { orders.first { $0.day == Orders.dayIndex() } }

    func markOnboarded() {
        onboarded = true
        saveNow()
    }

    func markPlate(_ id: String) {
        if !plateRead.contains(id) {
            plateRead.insert(id)
            points += 6
            saveNow()
        }
    }

    func finish(ground: Ground, result: SurveyResult, record: ChartRecord,
                order: Order?) -> Bool {
        let day = Orders.dayIndex()
        surveys += 1
        marksTaken += result.marks
        milesInked += 4
        points += result.points

        var improved = false
        if let existing = charts[ground.id] {
            if result.overall > existing.overall {
                charts[ground.id] = record
                improved = true
            }
        } else {
            charts[ground.id] = record
            improved = true
        }

        if let o = order, o.ground.id == ground.id, orders.first(where: { $0.day == day }) == nil {
            let met = Int((result.overall * 100).rounded()) >= o.target
            orders.append(DayOrder(day: day, groundId: ground.id, overall: result.overall,
                                   target: o.target, met: met))
            if met { points += 40 }
        }

        if lastDrawnDay != day {
            if lastDrawnDay == day - 1 { streak += 1 } else { streak = 1 }
            lastDrawnDay = day
            bestStreak = max(bestStreak, streak)
        }
        saveNow()
        return improved
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? JSONDecoder().decode(InkSnapshot.self, from: data) else { return }
        onboarded = snap.onboarded ?? false
        points = snap.points ?? 0
        streak = snap.streak ?? 0
        bestStreak = snap.bestStreak ?? 0
        lastDrawnDay = snap.lastDrawnDay ?? -1
        charts = snap.charts ?? [:]
        orders = snap.orders ?? []
        surveys = snap.surveys ?? 0
        marksTaken = snap.marksTaken ?? 0
        milesInked = snap.milesInked ?? 0
        plateRead = Set(snap.plateRead ?? [])
    }

    func saveNow() {
        let snap = InkSnapshot(onboarded: onboarded, points: points, streak: streak,
                               bestStreak: bestStreak, lastDrawnDay: lastDrawnDay,
                               charts: charts, orders: orders, surveys: surveys,
                               marksTaken: marksTaken, milesInked: milesInked,
                               plateRead: Array(plateRead))
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

func flatten(_ pts: [CGPoint]) -> [Double] {
    var out: [Double] = []
    for p in pts.prefix(200) {
        out.append(Double(p.x))
        out.append(Double(p.y))
    }
    return out
}

func unflatten(_ raw: [Double]) -> [CGPoint] {
    var out: [CGPoint] = []
    var i = 0
    while i + 1 < raw.count {
        out.append(CGPoint(x: raw[i], y: raw[i + 1]))
        i += 2
    }
    return out
}
