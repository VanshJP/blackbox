//
//  SignUpView.swift
//  blackbox
//
//  Created by Vansh Patel on 11/8/24.
//



import Foundation
import SwiftUI

import FirebaseAuth


struct SignUp: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""  
    
    var body: some View {
        VStack(spacing: 20) {
            Image("logoface")
                .resizable()
                .scaledToFit()
            
            CustomTextField(placeholder: "Enter Your Name", text: $name)
            CustomTextField(placeholder: "Enter Your Email", text: $email)
            CustomSecureField(placeholder: "Enter Your Password", text: $password)
            CustomSecureField(placeholder: "Confirm Your Password", text: $confirmPassword)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                // Call signUp only if passwords match
                if password == confirmPassword {
                    signUp()  // Call signUp function to create Firebase user
                } else {
                    errorMessage = "Passwords do not match"
                }
            }) {
                Text("Sign Up")
                    .frame(width: 320, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 50)
        .background(Color(UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1.0)).ignoresSafeArea())
    }
    
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Account created successfully!"
                // Additional actions on success can go here
            }
        }
    }
}


struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .frame(width: 300, height: 50)
            .padding([.leading, .trailing], 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .frame(width: 300, height: 50)
            .padding([.leading, .trailing], 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}


#Preview {
    SignUp()
}
