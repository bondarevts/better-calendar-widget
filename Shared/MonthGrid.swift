import Foundation

extension Calendar {
    /// The user's calendar, but with weeks always starting on Monday.
    static var widget: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
}

/// The days shown for one month: always at least one day of the previous month before the 1st
/// and at least one day of the next month after the last day, padded out to whole weeks.
struct MonthGrid {
    struct Day: Identifiable, Hashable {
        let date: Date
        let number: Int
        /// -1 for a day of the previous month, 1 for the next month, 0 for the shown month.
        let monthDelta: Int
        let isToday: Bool
        let isWeekend: Bool

        var id: Date { date }
        var isInMonth: Bool { monthDelta == 0 }
    }

    struct Weekday: Identifiable, Hashable {
        let index: Int
        let symbol: String
        let isWeekend: Bool

        var id: Int { index }
    }

    let title: String
    let weekdays: [Weekday]
    let weeks: [[Day]]

    /// - Parameters:
    ///   - month: Any date within the month to show.
    ///   - today: The date highlighted as today, if it falls in the grid.
    init(month: Date, today: Date, calendar: Calendar = .widget) {
        let monthStart = calendar.dateInterval(of: .month, for: month)!.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count

        // Days before the 1st in its week; a month starting on the first weekday gets a full week instead.
        let offset = (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7
        let leading = offset == 0 ? 7 : offset
        // Reserve at least one trailing day, then round up to whole weeks.
        let cellCount = (leading + daysInMonth + 1 + 6) / 7 * 7
        let firstDate = calendar.date(byAdding: .day, value: -leading, to: monthStart)!

        let days = (0..<cellCount).map { index in
            let date = calendar.date(byAdding: .day, value: index, to: firstDate)!
            return Day(
                date: date,
                number: calendar.component(.day, from: date),
                monthDelta: index < leading ? -1 : index < leading + daysInMonth ? 0 : 1,
                isToday: calendar.isDate(date, inSameDayAs: today),
                isWeekend: calendar.isDateInWeekend(date)
            )
        }

        let showsYear = !calendar.isDate(monthStart, equalTo: today, toGranularity: .year)
        title = monthStart.formatted(showsYear ? .dateTime.month(.wide).year() : .dateTime.month(.wide)).uppercased()
        weekdays = days.prefix(7).enumerated().map { index, day in
            Weekday(
                index: index,
                symbol: calendar.veryShortStandaloneWeekdaySymbols[calendar.component(.weekday, from: day.date) - 1],
                isWeekend: day.isWeekend
            )
        }
        weeks = stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<$0 + 7]) }
    }
}
