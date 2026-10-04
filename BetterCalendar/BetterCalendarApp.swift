import SwiftUI

/// Host app for the widget extension. Launching it once registers the widgets with the system;
/// the window just shows a preview and how to add them.
@main
struct BetterCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            MonthView(grid: MonthGrid(month: .now, today: .now))
                .frame(width: 170, height: 170)
                .background(.background, in: .rect(cornerRadius: 22))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)

            Text("Open Notification Center, right-click it, and choose **Edit Widgets** to add the Better Calendar widget.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(width: 260)
        }
        .padding(32)
    }
}
