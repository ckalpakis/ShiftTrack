import SwiftUI

struct TimeEntriesListView: View {
    @ObservedObject var timeManager: TimeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                Text("Time Entries")
                    .font(.headline)
                    .foregroundColor(.white)
            
            if timeManager.timeEntries.isEmpty {
                Text("No time entries yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(timeManager.timeEntries) { entry in
                            TimeEntryRow(entry: entry)
                                .contextMenu {
                                    Button(action: {
                                        timeManager.deleteTimeEntry(entry)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

struct TimeEntryRow: View {
    let entry: TimeEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.startTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Text(entry.startTime, style: .time)
                    Text("-")
                    Text(entry.endTime, style: .time)
                }
                .font(.system(.body, design: .monospaced))
            }
            
            Spacer()
            
            Text(String(format: "%.1f hrs", entry.hours))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}