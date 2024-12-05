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
    @State private var dailyScreenTimeGoal: Double = 5 * 60 // Default 5 hours in minutes
    @State private var currentScreenTime: Double = 0 // Track current screen time in minutes
    @State private var appLimits: [AppLimit] = []
    @State private var goals: [Goal] = [
        Goal(title: "Hit Screen Time Goal", rewardPoints: 5),
        Goal(title: "Open Apps less than 5 times", rewardPoints: 5),
        Goal(title: "Complete Mental Check-In", rewardPoints: 5),
        Goal(title: "Hit 10 Day Streak", rewardPoints: 5)
    ]
    @State private var isAddingGoal = false
    @State private var showCompletionPopup = false
    @State private var showUserView = false
    @State private var selectedTab: Tab = .home

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    ZStack {
                        switch selectedTab {
                        case .home:
                            ScrollView {
                                VStack(spacing: 20) {
                                    Spacer(minLength: geometry.size.height * 0.02)

                                    // Circular Timer
                                    CircularTimerView(
                                        currentScreenTime: $currentScreenTime,
                                        dailyGoal: $dailyScreenTimeGoal
                                    )
                                    .frame(width: geometry.size.width * 0.6)
                                    .onAppear {
                                        requestAuthorization()
                                        startMonitoringScreenTime()
                                    }

                                    // Screen Time Info
                                    HStack {
                                        Text("Current Screen Time")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(formattedTime(currentScreenTime)) / \(formattedTime(dailyScreenTimeGoal))")
                                    }
                                    .padding()

                                    // Blocked Apps Section
                                    VStack(alignment: .leading) {
                                        Text("Blocked Apps")
                                            .font(.headline)
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(appLimits, id: \.appName) { limit in
                                                    VStack {
                                                        Image(systemName: limit.iconName)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: geometry.size.width * 0.1)
                                                        Text(limit.appName)
                                                            .font(.caption)
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
                                                Text("\(goal.rewardPoints) pts")
                                                    .font(.subheadline)
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
                                            .frame(maxWidth: .infinity)
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
                    HStack {
                        TabBarItem(
                            icon: "house",
                            label: "Home",
                            isSelected: selectedTab == .home
                        ) {
                            selectedTab = .home
                        }
                        Spacer()
                        TabBarItem(
                            icon: "chart.bar.xaxis",
                            label: "Insights",
                            isSelected: selectedTab == .insights
                        ) {
                            selectedTab = .insights
                        }
                        Spacer()
                        TabBarItem(
                            icon: "checkmark.seal",
                            label: "Accountability",
                            isSelected: selectedTab == .accountability
                        ) {
                            selectedTab = .accountability
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.04)
                    .padding(.top, geometry.size.height * 0.01)
                    .padding(.bottom, geometry.size.height * 0.02)
                    .background(Color.white)
                }
                .background(Color.white.ignoresSafeArea())
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
    }

    /// Request authorization for screen time data
    func requestAuthorization() {
        AuthorizationCenter.shared.requestAuthorization { result in
            switch result {
            case .success:
                print("Authorization granted")
            case .failure(let error):
                print("Authorization failed: \(error.localizedDescription)")
            }
        }
    }

    /// Starts monitoring screen time and updates the `currentScreenTime`.
    func startMonitoringScreenTime() {
        let activityName = DeviceActivityName("dailyActivity")

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        do {
            try DeviceActivityCenter().startMonitoring(activityName, during: schedule)
            print("Monitoring started successfully.")
            fetchScreenTime(for: activityName)
        } catch {
            print("Error starting monitoring: \(error.localizedDescription)")
        }
    }

    func fetchScreenTime() {
        let context = DeviceActivityReport.Context.family
        let report = DeviceActivityReport(for: context)

        report.data(for: Date()) { result in
            switch result {
            case .success(let reportData):
                // Process the data to calculate total screen time
                let totalScreenTime = reportData.categoryUsage.values.reduce(0, +)
                DispatchQueue.main.async {
                    self.currentScreenTime = totalScreenTime / 60 // Convert seconds to minutes
                }
            case .failure(let error):
                print("Error fetching screen time: \(error.localizedDescription)")
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

// MARK: - Accountability View
import MessageUI

struct AccountabilityView: View {
    @State private var contacts: [Contact] = []
    @State private var showContactPicker = false
    @State private var contactToRemove: Contact?
    @State private var showConfirmationDialog = false
    @State private var errorMessage: String?

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
            MultipleContactPicker(contacts: $contacts, onContactSelected: sendMessageToContact)
        }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    errorMessage = nil
                }
            )
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

    func sendMessageToContact(_ contact: Contact) {
        if MFMessageComposeViewController.canSendText() {
            let messageBody = "You've been added as an accountability contact!"
            let messageSender = MessageSender(message: messageBody, recipient: contact.phoneNumber)
            UIApplication.shared.windows.first?.rootViewController?.present(
                UIHostingController(rootView: messageSender),
                animated: true
            )
        } else {
            errorMessage = "This device cannot send text messages."
        }
    }

    func removeContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
    }
}

// MARK: - Multiple Contact Picker
struct MultipleContactPicker: UIViewControllerRepresentable {
    @Binding var contacts: [Contact]
    var onContactSelected: (Contact) -> Void // Callback when a contact is selected
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

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? "No Phone"
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
            let newContact = Contact(phoneNumber: phoneNumber, name: name)
            parent.contacts.append(newContact)
            parent.onContactSelected(newContact) // Trigger the callback
            parent.presentationMode.wrappedValue.dismiss()
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct MessageSender: UIViewControllerRepresentable {
    var message: String
    var recipient: String

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = message
        controller.recipients = [recipient] // Individual recipient
        controller.messageComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            switch result {
            case .cancelled:
                print("Message cancelled by the user.")
            case .failed:
                print("Message sending failed.")
            case .sent:
                print("Message sent successfully.")
            @unknown default:
                print("An unknown error occurred.")
            }
            controller.dismiss(animated: true)
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
                .animation(.easeInOut, value: currentScreenTime)
            Text(formattedTime(currentScreenTime))
                .font(.title)
                .bold()
        }
        .aspectRatio(1, contentMode: .fit)
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



