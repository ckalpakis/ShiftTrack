import SwiftUI

struct TimeEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var timeManager: TimeManager
    @Binding var isPresented: Bool
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Start Time")) {
                    DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                    }
                    
                Section(header: Text("End Time")) {
                    DatePicker("", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                    }
                    
                Section {
                        HStack {
                        Text("Duration")
                            Spacer()
                        Text(String(format: "%.1f hours", endTime.timeIntervalSince(startTime) / 3600))
                                    .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Add Time Entry")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                        saveTimeEntry()
                        isPresented = false
                }
                .disabled(endTime <= startTime)
            )
        }
    }
    
    private func saveTimeEntry() {
        timeManager.addTimeEntry(start: startTime, end: endTime)
    }
}