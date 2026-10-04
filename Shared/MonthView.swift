import SwiftUI
import WidgetKit

/// Month grid styled after the stock macOS Calendar widget (small size).
///
/// `title` wraps the month name, `controls` sit at the trailing end of the header, and `day` wraps
/// each day cell, so the widget can make them interactive while the app preview stays static.
struct MonthView<Title: View, Controls: View, DayContent: View>: View {
    let grid: MonthGrid
    @ViewBuilder var title: (Text) -> Title
    @ViewBuilder var controls: () -> Controls
    @ViewBuilder var day: (MonthGrid.Day, DayCell) -> DayContent

    // Measured from the stock widget, as fractions of its size: the title's center sits 14.5% from the top,
    // the last row's center 15% from the bottom, and the grid is inset 7.7% on each side.
    private static var titleCenter: CGFloat { 0.145 }
    private static var lastRowCenter: CGFloat { 0.15 }
    private static var sideInset: CGFloat { 0.077 }

    var body: some View {
        GeometryReader { proxy in
            let lineCount = grid.weeks.count + 2
            let top = proxy.size.height * Self.titleCenter
            let bottom = proxy.size.height * Self.lastRowCenter
            let pitch = (proxy.size.height - top - bottom) / CGFloat(lineCount - 1)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    title(Text(grid.title))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.red)
                        .widgetAccentable()
                        .padding(.leading, 4)
                    Spacer(minLength: 0)
                    controls()
                }
                .frame(height: pitch)

                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    GridRow {
                        ForEach(grid.weekdays) { weekday in
                            Text(weekday.symbol)
                                .foregroundStyle(weekday.isWeekend ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: pitch)
                        }
                    }
                    ForEach(grid.weeks, id: \.first!.id) { week in
                        GridRow {
                            ForEach(week) { model in
                                day(model, DayCell(day: model, height: pitch))
                            }
                        }
                    }
                }
                .font(.system(size: 11, weight: .semibold))
            }
            .padding(.top, top - pitch / 2)
            .padding(.horizontal, proxy.size.width * Self.sideInset)
        }
    }
}

extension MonthView where Title == Text, Controls == EmptyView, DayContent == DayCell {
    init(grid: MonthGrid) {
        self.init(grid: grid, title: { $0 }, controls: { EmptyView() }, day: { $1 })
    }
}

/// One day, filling its whole grid cell so the entire cell is a click target.
struct DayCell: View {
    let day: MonthGrid.Day
    let height: CGFloat

    var body: some View {
        Text("\(day.number)")
            .monospacedDigit()
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .contentShape(.rect)
            .background {
                if day.isToday {
                    Circle()
                        .fill(.red)
                        .frame(width: 18, height: 18)
                        .widgetAccentable()
                }
            }
    }

    private var foreground: AnyShapeStyle {
        if day.isToday { return AnyShapeStyle(.white) }
        if !day.isInMonth { return AnyShapeStyle(.tertiary) }
        if day.isWeekend { return AnyShapeStyle(.secondary) }
        return AnyShapeStyle(.primary)
    }
}
