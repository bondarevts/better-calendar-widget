# Better Calendar

A small macOS desktop/Notification Center widget that shows a month calendar, styled after the stock macOS Calendar widget, but navigable.

<p align="center">
  <img src="docs/images/widget.png" alt="Better Calendar widget showing October with today, the 31st, highlighted" width="300">
</p>

## Features

- **Month grid** with weeks starting on Monday, always showing at least one day of the previous and next month.
- **Month navigation** right in the widget: the arrows step back and forth one month, clicking a day of a neighboring month jumps to that month, and clicking the month title returns to the current month.
- **Automatic reset**: the widget drifts back to the current month 15 minutes after the last navigation, and at midnight.
- Today is highlighted, weekends are dimmed, and the year appears in the title only when browsing outside the current year.
- Supports accented/tinted widget rendering.

## Requirements

- macOS 26 or later
- Xcode 26 or later (Swift 6)

## Building and running

1. Set up signing: copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig` and put your Apple Developer team ID in it. That file is gitignored, so your team ID stays out of the repo. If your team can't use the `com.bondarevts.*` bundle identifiers, change them in the targets' build settings.
2. Open `BetterCalendar.xcodeproj` in Xcode.
3. Run the `BetterCalendar` scheme. Launching the app once registers the widget with the system; its window shows a preview.
4. Add the widget: open Notification Center (or right-click the desktop), choose **Edit Widgets**, and add **Calendar** from Better Calendar.

## Project structure

| Path | Contents |
| --- | --- |
| `BetterCalendar/` | Host app: registers the widget extension and shows a static preview. |
| `CalendarWidget/` | WidgetKit extension: timeline provider, interactive widget view, and the App Intent that changes months. |
| `Shared/` | Code used by both targets: `MonthGrid` (calendar math) and `MonthView` (the SwiftUI layout). |
| `Config/` | Build settings: `Signing.xcconfig` (tracked) pulls in your own `Local.xcconfig` (gitignored). |
| `docs/images/` | Screenshots used in this README. |

## License

[MIT](LICENSE)
