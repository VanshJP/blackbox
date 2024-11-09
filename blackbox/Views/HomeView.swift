import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings
import Firebase

struct HomeView: View {
    @State private var selectedApps = FamilyActivitySelection()
    @State private var isAppPickerPresented = false
    @State private var dailyScreenTimeGoal: Double = 5 * 60 // default 5 hours in minutes
    @State private var currentScreenTime: Double = 0 // track current screen time in minutes
    @State private var appLimits: [AppLimit] = [] // list to hold app-specific limits
    @State private var goals: [Goal] = [
        Goal(title: "Hit Screen Time Goal", rewardPoints: 5),
        Goal(title: "Open Apps less than 5 times", rewardPoints: 5),
        Goal(title: "Complete Mental Check-In", rewardPoints: 5),
        Goal(title: "Hit 10 Day Streak", rewardPoints: 5)
    ]
    @State private var isAddingGoal = false
    @State private var showCompletionPopup = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Circular Timer
                CircularTimerView(currentScreenTime: $currentScreenTime, dailyGoal: $dailyScreenTimeGoal)
                
                // Screen Time Info
                HStack {
                    Text("Current Screen Time")
                        .font(.headline)
                    Spacer()
                    Text("\(formattedTime(currentScreenTime)) / \(formattedTime(dailyScreenTimeGoal))")
                }
                .padding()
                
                // Blocked Apps Section
                VStack {
                    Text("Blocked Apps")
                        .font(.headline)
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            ForEach(appLimits, id: \.appName) { limit in
                                VStack {
                                    Image(systemName: limit.iconName) // Set app icons here
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    Text(limit.appName)
                                }
                            }
                        }
                    }
                }
                .padding()
                
                // Goal Section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Goals")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            isAddingGoal = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
                    
                    ForEach(goals) { goal in
                        HStack {
                            Text(goal.title)
                                .strikethrough(goal.isCompleted, color: .black)
                                .foregroundColor(goal.isCompleted ? .gray : .black)
                            Spacer()
                            Text("\(goal.rewardPoints)")
                            Button(action: {
                                toggleGoalCompletion(goal: goal)
                            }) {
                                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(goal.isCompleted ? .green : .gray)
                            }
                        }
                    }
                }
                .padding()
                
                // Set Time Goal Button
                Button(action: {
                    isAppPickerPresented = true
                }) {
                    Text("Choose Apps to Block")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $selectedApps)
            }
            .padding()
            .sheet(isPresented: $isAddingGoal) {
                AddGoalView(goals: $goals, isAddingGoal: $isAddingGoal)
            }
            
            // Completion Popup
            if showCompletionPopup {
                VStack {
                    Spacer()
                    Text("🎉 Good Job! 🎉")
                        .font(.title)
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    Spacer().frame(height: 150)
                }
                .transition(.move(edge: .top))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showCompletionPopup = false
                        }
                    }
                }
            }
        }
    }
    
    func formattedTime(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        return "\(hours)h \(mins)m"
    }
    
    private func toggleGoalCompletion(goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
            if goals[index].isCompleted {
                withAnimation {
                    showCompletionPopup = true
                }
            }
        }
    }
}

struct AddGoalView: View {
    @Binding var goals: [Goal]
    @Binding var isAddingGoal: Bool
    @State private var goalTitle: String = ""
    @State private var rewardPoints: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Title")) {
                    TextField("Enter your goal title", text: $goalTitle)
                }
                
                Section(header: Text("Reward Points")) {
                    TextField("Enter reward points", text: $rewardPoints)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add New Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isAddingGoal = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let points = Int(rewardPoints), !goalTitle.isEmpty {
                            let newGoal = Goal(title: goalTitle, rewardPoints: points)
                            goals.append(newGoal)
                            isAddingGoal = false
                        }
                    }
                }
            }
        }
    }
}

struct CircularTimerView: View {
    @Binding var currentScreenTime: Double
    @Binding var dailyGoal: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 15)
            Circle()
                .trim(from: 0, to: CGFloat(min(currentScreenTime / dailyGoal, 1.0)))
                .stroke(currentScreenTime <= dailyGoal ? Color.green : Color.red, lineWidth: 15)
                .rotationEffect(.degrees(-90))
                .animation(.linear)
            Text("\(formattedTime(currentScreenTime))")
                .font(.title)
                .bold()
        }
        .frame(width: 200, height: 200)
    }
    
    func formattedTime(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        return "\(hours)h \(mins)m"
    }
}

// Model for App Limit
struct AppLimit: Identifiable {
    let id = UUID()
    var appName: String
    var timeLimit: Double // in minutes
    var iconName: String // system icon or custom icon name
}

// Model for Goal
struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var rewardPoints: Int
    var isCompleted: Bool = false // Track completion status
}

#Preview {
    HomeView()
}

