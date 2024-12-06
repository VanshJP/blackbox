import SwiftUI
import DeviceActivity
import FamilyControls

// MARK: - Tip Model
struct Tip: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, description: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
    }
}

// MARK: - InsightCard View
struct InsightCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - TipRow View
struct TipRow: View {
    @Binding var tip: Tip
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.blue)
                }
                
                Text(tip.title)
                    .strikethrough(tip.isCompleted, color: .primary)
                    .foregroundColor(tip.isCompleted ? .secondary : .primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        tip.isCompleted.toggle()
                    }
                }) {
                    Image(systemName: tip.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(tip.isCompleted ? .green : .gray)
                        .imageScale(.large)
                }
            }
            
            if isExpanded {
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 28)
            }
        }
    }
}

// MARK: - InsightsView
struct InsightsView: View {
    @AppStorage("tips") private var tipsData: Data = Data()
    @State private var mostUsedApp: String = "Loading..."
    @State private var totalScreenTime: Double = 0.0
    @State private var mostActiveHour: String = "Loading..."
    @State private var tips: [Tip] = [
        Tip(title: "Set App Limits", description: "Choose specific time limits for your most distracting apps"),
        Tip(title: "Digital Sunset", description: "Stop using your phone 1 hour before bedtime"),
        Tip(title: "Grayscale Mode", description: "Enable grayscale to make your phone less visually appealing"),
        Tip(title: "App Organizing", description: "Move distracting apps to a separate folder or second screen"),
        Tip(title: "Notification Detox", description: "Turn off non-essential notifications"),
        Tip(title: "Mindful Breaks", description: "Take regular breaks every 30 minutes of screen time"),
        Tip(title: "Phone-Free Zones", description: "Designate certain areas as no-phone spaces"),
        Tip(title: "Morning Routine", description: "Don't check your phone for the first hour after waking up")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Insights")
                    .font(.system(size: 34, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Usage Insights Section
                InsightCard(title: "Today's Activity") {
                    VStack(spacing: 16) {
                        insightRow(icon: "app.fill", title: "Most Used", value: mostUsedApp)
                        insightRow(icon: "clock.fill", title: "Screen Time", value: formattedTime(totalScreenTime))
                        insightRow(icon: "chart.bar.fill", title: "Peak Activity", value: mostActiveHour)
                    }
                }
                
                // Tips Section
                InsightCard(title: "Digital Wellbeing Tips") {
                    VStack(spacing: 12) {
                        ForEach($tips) { $tip in
                            TipRow(tip: $tip)
                        }
                    }
                }
            }
            .padding()
        }
  
        .onAppear {
            loadTips()
            loadInsights()
        }
    }
    
    private func insightRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    private func loadInsights() {
        // TODO: Implement actual data loading from DeviceActivity
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            mostUsedApp = "Instagram"
            totalScreenTime = 300
            mostActiveHour = "8 PM - 9 PM"
        }
    }
    
    private func formattedTime(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        return "\(hours)h \(mins)m"
    }
    
    private func saveTips() {
        if let encoded = try? JSONEncoder().encode(tips) {
            tipsData = encoded
        }
    }
    
    private func loadTips() {
        if let decoded = try? JSONDecoder().decode([Tip].self, from: tipsData) {
            tips = decoded
        }
    }
}

// MARK: - Preview Provider
struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}

#Preview {
    InsightsView()
}