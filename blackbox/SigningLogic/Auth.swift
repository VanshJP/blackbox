//
//  Auth.swift
//  blackbox
//
//  Created by Vansh Patel on 11/8/24.
//
import Foundation
import Observation

@Observable
class SignInViewModel {
    var email = ""
    var password = ""
    var showPassword = true
    
    func SignInWithEmail(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await AuthService.shared.signInWithEmail(email: email, password: password)
                completion(true)
            } catch {
                print("Error signing in: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
