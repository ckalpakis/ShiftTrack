import SwiftUI

struct ContentView: View {
    @StateObject private var timeManager = TimeManager()
    @State private var isSettingsPresented = false
    @State private var isAddingTimeEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // Weekly summary card
                    WeeklySummaryView(timeManager: timeManager)
                    
                    // Time entries list
                    TimeEntriesListView(timeManager: timeManager)
                    
                    Spacer()
                    
                    // Add time entry button
                    Button(action: {
                        isAddingTimeEntry = true
                    }) {
                        Label("Add Time Entry", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .preferredColorScheme(.dark)
            .navigationTitle("ShiftTrack")
            .navigationBarItems(trailing: Button(action: {
                isSettingsPresented = true
            }) {
                Image(systemName: "gear")
                    .imageScale(.large)
            })
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView(timeManager: timeManager)
            }
            .sheet(isPresented: $isAddingTimeEntry) {
                TimeEntryView(timeManager: timeManager, isPresented: $isAddingTimeEntry)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}