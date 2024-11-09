import Foundation
import SwiftUI

struct UserView: View {
    @State private var userName: String = "User" // Default name; replace with actual data from Firebase or user input
    @State private var isSignedOut = false // State to control navigation to SignIn

    var body: some View {
        VStack {
            // Display user's name dynamically as the title
            Text("(userName)'s Profile")
                .font(.largeTitle)
                .padding()

            // User name input field
            VStack(alignment: .leading) {
                Text("Name:")
                    .font(.headline)
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            .padding(.horizontal)

            // Sign Out button
            Button(action: {
                signOut()
            }) {
                Text("Sign Out")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .padding()
        .background(
            NavigationLink(destination: SignIn().navigationBarBackButtonHidden(true), isActive: $isSignedOut) {
                EmptyView()
            }
        )
    }

    // Sign out function
    private func signOut() {
        // Add Firebase sign-out logic here if using Firebase Authentication
        // e.g., try? Auth.auth().signOut()

        isSignedOut = true // Navigate to SignIn view after sign-out
    }
}
