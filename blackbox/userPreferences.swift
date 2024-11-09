// userPreferences.swift
// Logic surrounding user preferences and saving those settings locally

import SwiftUI
import Combine

class UserPreferences: ObservableObject {
    // Published properties that automatically trigger UI updates
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var fontSize: Double {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    
    init() {
        // Initialize with stored values or defaults
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.fontSize = UserDefaults.standard.double(forKey: "fontSize")
        
        // Set default fontSize if not previously set
        if self.fontSize == 0 {
            self.fontSize = 14.0
        }
    }
    
    func resetToDefaults() {
        username = ""
        isDarkMode = false
        notificationsEnabled = true
        fontSize = 14.0
    }
}

// Example View using UserPreferences
struct SettingsView: View {
    @StateObject private var preferences = UserPreferences()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Username", text: $preferences.username)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $preferences.isDarkMode)
                    
                    VStack(alignment: .leading) {
                        Text("Font Size: \(Int(preferences.fontSize))")
                        Slider(value: $preferences.fontSize,
                               in: 10...24,
                               step: 1)
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $preferences.notificationsEnabled)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        preferences.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// Preview Provider
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
