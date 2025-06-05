import Foundation

struct TimeEntry: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var hours: Double {
        duration / 3600.0
    }
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}