import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var timeManager: TimeManager
    
    @State private var hourlyWage: String
    @State private var taxRate: String
    @State private var weekStartDay: Int
    
    init(timeManager: TimeManager) {
        self.timeManager = timeManager
        _hourlyWage = State(initialValue: String(format: "%.2f", timeManager.hourlyWage))
        _taxRate = State(initialValue: String(format: "%.2f", timeManager.taxRate * 100))
        _weekStartDay = State(initialValue: timeManager.weekStartDay)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pay Rate")) {
                    HStack {
                        Text("$")
                        TextField("Hourly Wage", text: $hourlyWage)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        TextField("Tax Rate", text: $taxRate)
                            .keyboardType(.decimalPad)
                        Text("%")
                    }
                }
                
                Section(header: Text("Week Settings")) {
                    Picker("Week Starts On", selection: $weekStartDay) {
                        Text("Monday").tag(1)
                        Text("Tuesday").tag(2)
                        Text("Wednesday").tag(3)
                        Text("Thursday").tag(4)
                        Text("Friday").tag(5)
                        Text("Saturday").tag(6)
                        Text("Sunday").tag(7)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func saveSettings() {
        let wage = Double(hourlyWage) ?? timeManager.hourlyWage
        let tax = (Double(taxRate) ?? timeManager.taxRate * 100) / 100
        
        timeManager.updateSettings(
            hourlyWage: wage,
            taxRate: tax,
            weekStartDay: weekStartDay
        )
    }
}