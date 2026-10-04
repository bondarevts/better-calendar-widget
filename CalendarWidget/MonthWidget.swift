import SwiftUI
import WidgetKit

struct MonthEntry: TimelineEntry {
    let date: Date
    let monthOffset: Int
}

struct MonthProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonthEntry {
        MonthEntry(date: .now, monthOffset: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (MonthEntry) -> Void) {
        completion(MonthEntry(date: .now, monthOffset: MonthNavigation.state(at: .now).offset))
    }

    /// One entry now, one when month navigation expires, and one at each of the next several midnights,
    /// so the widget resets and the day flips on time even if the system delays the next reload.
    func getTimeline(in context: Context, completion: @escaping (Timeline<MonthEntry>) -> Void) {
        let calendar = Calendar.widget
        let now = Date.now
        let today = calendar.startOfDay(for: now)
        let midnights = (1...7).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
        let navigation = MonthNavigation.state(at: now)

        var entries = [MonthEntry(date: now, monthOffset: navigation.offset)]
        if let resetsAt = navigation.resetsAt, resetsAt < midnights[0] {
            entries.append(MonthEntry(date: resetsAt, monthOffset: 0))
        }
        entries += midnights.map { MonthEntry(date: $0, monthOffset: 0) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct MonthWidgetView: View {
    let entry: MonthEntry

    var body: some View {
        let month = Calendar.widget.date(byAdding: .month, value: entry.monthOffset, to: entry.date)!
        MonthView(grid: MonthGrid(month: month, today: entry.date)) { title in
            Button(intent: ShiftMonthIntent(delta: 0)) { title }
                .buttonStyle(.plain)
        } controls: {
            HStack(spacing: 2) {
                arrow("chevron.left", delta: -1)
                arrow("chevron.right", delta: 1)
            }
        } day: { day, cell in
            // Days of the neighboring months switch to their month.
            if day.isInMonth {
                cell
            } else {
                Button(intent: ShiftMonthIntent(delta: day.monthDelta)) { cell }
                    .buttonStyle(.plain)
            }
        }
    }

    private func arrow(_ symbol: String, delta: Int) -> some View {
        Button(intent: ShiftMonthIntent(delta: delta)) {
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 18, height: 18)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

struct MonthWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MonthCalendar", provider: MonthProvider()) { entry in
            MonthWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Calendar")
        .description("This month, with days from the neighboring months.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
