import SwiftUI

struct WeeklySummaryView: View {
    @ObservedObject var timeManager: TimeManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                // Hours worked
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hours")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(String(format: "%.1f", timeManager.hoursThisWeek))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                    
                    Text("\(String(format: "%.1f", timeManager.hoursRemaining)) left")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.5))
            
            // Earnings
                VStack(alignment: .leading, spacing: 4) {
                    Text("Earnings")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(String(format: "$%.2f", timeManager.netEarningsThisWeek))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                    
                    Text("after tax")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 6)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(timeManager.hoursThisWeek / 40.0) * geometry.size.width, geometry.size.width), height: 6)
                        .foregroundColor(Color.green)
                }
                .cornerRadius(3)
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ProgressBar: View {
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
                    .foregroundColor(.accentColor)
                    .animation(.easeInOut, value: value)
            }
            .cornerRadius(45)
        }
    }
}