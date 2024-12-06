import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings
import Firebase
import Contacts
import ContactsUI
import MessageUI

// MARK: - Home View
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
    @State private var showUserView = false // Tracks showing UserView
    @State private var selectedTab: Tab = .home // Track selected tab

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content
                ZStack {
                    switch selectedTab {
                    case .home:
                        ScrollView {
                            VStack(spacing: 20) {
                                Spacer(minLength: 40) // Move content slightly downward
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
                        }
                        .sheet(isPresented: $isAddingGoal) {
                            AddGoalView(goals: $goals, isAddingGoal: $isAddingGoal)
                        }
                    case .insights:
                        CenteredTextView(text: "Insights Screen")
                    case .accountability:
                        AccountabilityView()
                    }
                }
                
                // Bottom Tab Bar
                HStack(spacing: 0) {  // Set spacing to 0 to have full control over the layout
                    // First third
                    GeometryReader { geometry in
                        TabBarItem(
                            icon: "house",
                            label: "Home",
                            isSelected: selectedTab == .home
                        ) {
                            selectedTab = .home
                        }
                        .frame(width: geometry.size.width)
                        .frame(maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Middle third
                    GeometryReader { geometry in
                        TabBarItem(
                            icon: "chart.bar.xaxis",
                            label: "Insights",
                            isSelected: selectedTab == .insights
                        ) {
                            selectedTab = .insights
                        }
                        .frame(width: geometry.size.width)
                        .frame(maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Last third
                    GeometryReader { geometry in
                        TabBarItem(
                            icon: "checkmark.seal",
                            label: "Accountability",
                            isSelected: selectedTab == .accountability
                        ) {
                            selectedTab = .accountability
                        }
                        .frame(width: geometry.size.width)
                        .frame(maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 75)
                .background(Color.white)
                
            }
            .background(Color.white.ignoresSafeArea()) // Make the entire background white
            .edgesIgnoringSafeArea(.bottom) // Ensure the bar is fixed to the bottom
            .navigationBarItems(trailing: Button(action: {
                showUserView = true
            }) {
                Image(systemName: "person.circle")
                    .font(.title)
            })
            .background(
                NavigationLink(destination: UserView(), isActive: $showUserView) {
                    EmptyView()
                }
            )
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

// MARK: - Accountability View
struct AccountabilityView: View {
    @State private var contacts: [Contact] = []
    @State private var showContactPicker = false
    @State private var contactToRemove: Contact?
    @State private var showConfirmationDialog = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Accountability Contacts")
                .font(.title2)
                .bold()
            
            Text("Add some friends and family that will be alerted once you reach certain thresholds on your time constraints!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

            List {
                ForEach(contacts) { contact in
                    HStack {
                        Text(contact.name.isEmpty ? contact.phoneNumber : contact.name)
                        Spacer()
                        Button(action: {
                            contactToRemove = contact
                            showConfirmationDialog = true
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())

            Button(action: {
                showContactPicker = true
            }) {
                Text("Add Contacts")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .sheet(isPresented: $showContactPicker) {
            MultipleContactPicker(contacts: $contacts)
        }
        .confirmationDialog(
            "Are you sure you want to remove \(contactToRemove?.name ?? contactToRemove?.phoneNumber ?? "") as an Accountability Contact?",
            isPresented: $showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Yes", role: .destructive) {
                if let contact = contactToRemove {
                    removeContact(contact)
                }
            }
            Button("No", role: .cancel) {}
        }
    }

    func removeContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
    }
}

// MARK: - Multiple Contact Picker
struct MultipleContactPicker: UIViewControllerRepresentable {
    @Binding var contacts: [Contact]
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0") // Ensure contacts have phone numbers
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: MultipleContactPicker

        init(_ parent: MultipleContactPicker) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            for contact in contacts {
                let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? "No Phone"
                let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                parent.contacts.append(Contact(phoneNumber: phoneNumber, name: name))
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Contact Model
struct Contact: Identifiable {
    let id = UUID()
    var phoneNumber: String
    var name: String
}

// MARK: - Circular Timer View
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
                .animation(.linear, value: currentScreenTime)
            Text(formattedTime(currentScreenTime))
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

// MARK: - Add Goal View
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

struct AppLimit: Identifiable {
    let id = UUID()
    var appName: String
    var timeLimit: Double
    var iconName: String
}

struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var rewardPoints: Int
    var isCompleted: Bool = false
}

// MARK: - Tab Enum
enum Tab {
    case home
    case insights
    case accountability
}

// MARK: - Centered Text View
struct CenteredTextView: View {
    let text: String

    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.largeTitle)
                .bold()
            Spacer()
        }
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .blue : .gray)
            Text(label)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .onTapGesture {
            action()
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
