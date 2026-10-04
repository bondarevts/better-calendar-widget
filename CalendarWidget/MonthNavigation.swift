import AppIntents
import Foundation

/// How many months the widget is scrolled away from the current one.
/// The offset expires `resetDelay` after the last navigation, and also at midnight,
/// so the widget drifts back to the current month on its own.
enum MonthNavigation {
    static let resetDelay: TimeInterval = 15 * 60

    private static let offsetKey = "monthOffset"
    private static let setAtKey = "monthOffsetSetAt"

    /// The offset in effect at `date`, and when it expires (nil when already at the current month).
    static func state(at date: Date, calendar: Calendar = .widget) -> (offset: Int, resetsAt: Date?) {
        let defaults = UserDefaults.standard
        let offset = defaults.integer(forKey: offsetKey)
        guard offset != 0,
              let setAt = defaults.object(forKey: setAtKey) as? Date,
              calendar.isDate(setAt, inSameDayAs: date)
        else { return (0, nil) }
        let resetsAt = setAt.addingTimeInterval(resetDelay)
        return date < resetsAt ? (offset, resetsAt) : (0, nil)
    }

    static func shift(by delta: Int) {
        let now = Date.now
        let defaults = UserDefaults.standard
        defaults.set(delta == 0 ? 0 : state(at: now).offset + delta, forKey: offsetKey)
        defaults.set(now, forKey: setAtKey)
    }
}

/// Moves the month widget by `delta` months; a delta of 0 jumps back to the current month.
struct ShiftMonthIntent: AppIntent {
    static let title: LocalizedStringResource = "Change Month"
    static let isDiscoverable = false

    @Parameter(title: "Months")
    var delta: Int

    init() {}

    init(delta: Int) {
        self.delta = delta
    }

    func perform() async throws -> some IntentResult {
        MonthNavigation.shift(by: delta)
        return .result()
    }
}
