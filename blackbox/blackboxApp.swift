//
//  blackboxApp.swift
//  blackbox
//
//  Created by Vansh Patel on 11/3/24.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings
import Firebase

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Main App
@main
struct BlackboxApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var familyControlsManager = FamilyControlsManager()
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .environmentObject(familyControlsManager)
            }
            .onAppear {
                requestFamilyControlsAuthorization()
            }
        }
    }
    
    // MARK: - Authorization
    private func requestFamilyControlsAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                familyControlsManager.handleAuthorizationChange()
            } catch {
                print("Failed to authorize Family Controls: \(error)")
            }
        }
    }
}

// MARK: - Family Controls Manager
class FamilyControlsManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    
    @MainActor
    func handleAuthorizationChange() {
        let status = AuthorizationCenter.shared.authorizationStatus
        authorizationStatus = status
        isAuthorized = status == .approved
        
        switch status {
        case .notDetermined:
            print("Authorization Status: Not Determined")
        case .denied:
            print("Authorization Status: Denied")
        case .approved:
            print("Authorization Status: Approved")
        @unknown default:
            print("Authorization Status: Unknown")
        }
    }
}

// MARK: - Helper Extensions
extension DeviceActivityName {
    static let daily = Self("daily")
}

extension DeviceActivitySchedule {
    static let daily = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: 0, minute: 0),
        intervalEnd: DateComponents(hour: 23, minute: 59),
        repeats: true
    )
}
