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


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}



@main
struct blackboxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let center = AuthorizationCenter.shared
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear{
                    Task {
                        do {
                            try await center.requestAuthorization(for: .individual)
                            let status = center.authorizationStatus
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
                            
                        } catch {
                            print("Unable to enroll due to error: \(error)")
                        }
                        
                        
                    }
                    
                    
                }
            
            
        }
    }
    
    
}


