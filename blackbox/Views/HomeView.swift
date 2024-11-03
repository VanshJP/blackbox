import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings
import Firebase

struct HomeView: View {
    @State private var selectedApps = FamilyActivitySelection()
    @State private var isAppPickerPresented = false

    var body: some View {
        VStack {
            Text("Select Apps to Block")
                .font(.title)
                .padding()

            Button(action: {
                isAppPickerPresented = true
            }) {
                Text("Choose Apps to Block")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

        }
        .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $selectedApps)
    }
}

#Preview {
    HomeView()
}
