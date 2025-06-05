import Foundation
import Combine
import SwiftUI

class TimeManager: ObservableObject {
    // Published properties that will cause the UI to update
    @Published var hourlyWage: Double = 20.0
    @Published var taxRate: Double = 0.12
    @Published var weekStartDay: Int = 1 // 1 = Monday, 7 = Sunday
    @Published var timeEntries: [TimeEntry] = []
    
    // Constants
    private let weeklyHoursCap: Double = 40.0
    
    // UserDefaults keys
    private let hourlyWageKey = "hourlyWage"
    private let taxRateKey = "taxRate"
    private let weekStartDayKey = "weekStartDay"
    private let timeEntriesKey = "timeEntries"
    
    private let defaults = UserDefaults(suiteName: "group.com.yourcompany.ShiftTrack")
    
    init() {
        loadData()
    }
    
    // MARK: - Computed Properties
    
    var hoursWorkedThisWeek: Double {
        let weekEntries = currentWeekEntries()
        let totalSeconds = weekEntries.reduce(0) { $0 + $1.duration }
        return totalSeconds / 3600
    }
    
    var hoursRemainingThisWeek: Double {
        return max(0, weeklyHoursCap - hoursWorkedThisWeek)
    }
    
    var weeklyHoursProgress: CGFloat {
        return CGFloat(min(hoursWorkedThisWeek / weeklyHoursCap, 1.0))
    }
    
    var grossEarningsThisWeek: Double {
        return hoursWorkedThisWeek * hourlyWage
    }
    
    var netEarningsThisWeek: Double {
        return grossEarningsThisWeek * (1 - taxRate)
    }
    
    var currentWeekRange: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        
        var startOfWeekComponents = DateComponents()
        startOfWeekComponents.yearForWeekOfYear = components.yearForWeekOfYear
        startOfWeekComponents.weekOfYear = components.weekOfYear
        startOfWeekComponents.weekday = weekStartDay + 1 // Adjust weekday
        
        guard let startDate = calendar.date(from: startOfWeekComponents) else { return "" }
        guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    // MARK: - Time Entry Methods
    
    func addTimeEntry(start: Date, end: Date) {
        let entry = TimeEntry(startTime: start, endTime: end)
        timeEntries.append(entry)
        timeEntries.sort { $0.startTime > $1.startTime } // Sort with newest first
        saveData()
    }
    
    func deleteTimeEntry(_ entry: TimeEntry) {
        timeEntries.removeAll { $0.id == entry.id }
        saveData()
    }
    
    // MARK: - Helper Methods
    
    private func currentWeekEntries() -> [TimeEntry] {
        let calendar = Calendar.current
        
        // Get start of the current week based on weekStartDay
        let today = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        
        var startOfWeekComponents = DateComponents()
        startOfWeekComponents.yearForWeekOfYear = components.yearForWeekOfYear
        startOfWeekComponents.weekOfYear = components.weekOfYear
        startOfWeekComponents.weekday = weekStartDay + 1 // Adjust weekday
        
        guard let startOfWeek = calendar.date(from: startOfWeekComponents) else { return [] }
        guard let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else { return [] }
        
        // Filter entries within current week
        return timeEntries.filter { entry in
            return entry.startTime >= startOfWeek && entry.startTime < endOfWeek
        }
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(timeEntries) {
            defaults?.set(data, forKey: timeEntriesKey)
        }
        defaults?.set(hourlyWage, forKey: hourlyWageKey)
        defaults?.set(taxRate, forKey: taxRateKey)
        defaults?.set(weekStartDay, forKey: weekStartDayKey)
    }
    
    private func loadData() {
        if let data = defaults?.data(forKey: timeEntriesKey),
           let entries = try? JSONDecoder().decode([TimeEntry].self, from: data) {
            timeEntries = entries
        }
        
        hourlyWage = defaults?.double(forKey: hourlyWageKey) ?? 20.0
        taxRate = defaults?.double(forKey: taxRateKey) ?? 0.12
        weekStartDay = defaults?.integer(forKey: weekStartDayKey) ?? 1
    }
    
    func resetAllData() {
        hourlyWage = 20.0
        taxRate = 0.12
        weekStartDay = 1
        timeEntries = []
        
        saveData()
    }
    
    // MARK: - Settings
    
    func updateSettings(hourlyWage: Double, taxRate: Double, weekStartDay: Int) {
        self.hourlyWage = hourlyWage
        self.taxRate = taxRate
        self.weekStartDay = weekStartDay
        saveData()
    }
}