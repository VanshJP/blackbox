//
//  FirebaseTextField.swift
//  blackbox
//
//  Created by Vansh Patel on 11/8/24.
//


import Foundation
import SwiftUI


struct FirebaseTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View  {
        TextField("Enter Your Email", text: $text)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .frame(width: 300, height: 50)
            .padding([.leading, .trailing], 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
            )
        
        
    }

}
