//
//  SignInView.swift
//  blackbox
//
//  Created by Vansh Patel on 11/8/24.
//

import Foundation
import SwiftUI



struct SignIn: View {

    @State var viewModel = SignInViewModel()
    @State private var isSignedIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("logoface")
                    .resizable()
                    .scaledToFit()
                
                FirebaseTextField(placeholder: "Email Address", text: $viewModel.email)
                
                FirebaseSecureField(placeholder: "Password", showPassword: $viewModel.showPassword, text: $viewModel.password)
                
                Button(action: {
                    viewModel.SignInWithEmail { success in
                        if success {
                            isSignedIn = true
                        }
                    }
                }) {
                    Text("Sign In")
                        .frame(width: 320, height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                
                
                
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: SignUp()) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 50)
            .background(
                NavigationLink(destination: HomeView(), isActive: $isSignedIn) {
                    EmptyView()
                }
            )
        }
    }
}

 



#Preview{
    SignIn()
}
