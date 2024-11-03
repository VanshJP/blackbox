//
//  AuthService.swift
//  blackbox
//
//  Created by Vansh Patel on 11/8/24.
//


import Foundation
import Firebase
import FirebaseAuth

final class AuthService {
    
    private let auth = Auth.auth()
    static let shared = AuthService()
    private init() { }
    
    
    func registerWithEmail(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        print(result)
    }
        
        
    func signInWithEmail(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        print(result)
    }

}
