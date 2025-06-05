import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), hoursWorked: 25.5, hoursRemaining: 14.5, netEarnings: 459.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), hoursWorked: 25.5, hoursRemaining: 14.5, netEarnings: 459.0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.ShiftTrack")
        let hourlyWage = defaults?.double(forKey: "hourlyWage") ?? 20.0
        let taxRate = defaults?.double(forKey: "taxRate") ?? 0.12
        
        // Get time entries and calculate hours
        var hoursWorked: Double = 0
        if let data = defaults?.data(forKey: "timeEntries"),
           let entries = try? JSONDecoder().decode([TimeEntry].self, from: data) {
            // Calculate current week's hours
            let calendar = Calendar.current
            let today = Date()
            let weekday = calendar.component(.weekday, from: today)
            let weekStartDay = defaults?.integer(forKey: "weekStartDay") ?? 1
            let daysToSubtract = (weekday + 7 - weekStartDay) % 7
            let weekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            hoursWorked = entries
                .filter { $0.startTime >= weekStart && $0.endTime <= weekEnd }
                .reduce(0) { $0 + $0.hours }
        }
        
        let hoursRemaining = max(0, 40 - hoursWorked)
        let netEarnings = hoursWorked * hourlyWage * (1 - taxRate)
        
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            hoursWorked: hoursWorked,
            hoursRemaining: hoursRemaining,
            netEarnings: netEarnings
        )
        
        // Update every 30 minutes
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let hoursWorked: Double
    let hoursRemaining: Double
    let netEarnings: Double
}

struct ShiftTrackWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("ShiftTrack")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Hours progress
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hours")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("\(entry.hoursWorked, specifier: "%.1f")")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("\(entry.hoursRemaining, specifier: "%.1f") left")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    if family != .systemSmall {
                        Divider()
                            .background(Color.gray.opacity(0.5))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Earnings")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("$\(entry.netEarnings, specifier: "%.2f")")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text("after tax")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Progress bar
                WidgetProgressBar(value: min(CGFloat(entry.hoursWorked / 40.0), 1.0))
                    .frame(height: 6)
            }
            .padding()
        }
    }
}

struct WidgetProgressBar: View {
    var value: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: min(value * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.green)
            }
            .cornerRadius(45)
        }
    }
}

@main
struct ShiftTrackWidget: Widget {
    let kind: String = "ShiftTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ShiftTrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ShiftTrack")
        .description("Track your hours and earnings")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ShiftTrackWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShiftTrackWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                hoursWorked: 25.5,
                hoursRemaining: 14.5,
                netEarnings: 459.0
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .preferredColorScheme(.dark)
            
            ShiftTrackWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                hoursWorked: 25.5,
                hoursRemaining: 14.5,
                netEarnings: 459.0
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
        }
    }
}