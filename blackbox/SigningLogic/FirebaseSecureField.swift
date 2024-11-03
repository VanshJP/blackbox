//
//  FirebaseSecureField.swift
//  blackbox
//
//  Created by Vansh Patel on 11/8/24.
//


import Foundation
import SwiftUI


struct FirebaseSecureField: View {
    var placeholder: String
    @Binding var showPassword: Bool
    @Binding var text: String
    
    var body: some View  {
        
        if(showPassword == false) {
            TextField("Enter Your Password", text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .frame(width: 300, height: 50)
                .padding([.leading, .trailing], 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .overlay(alignment: .trailing){
                    Button(role: .cancel){
    
                            showPassword = true
                     
                    } label: {
                        Image(systemName: "lock.open" )
                        
                            .padding()
                            .contentTransition(.symbolEffect)
                            .foregroundColor(.black)

                    }
                    
                }
            
        } else {
            
            SecureField("Enter Your Password", text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .frame(width: 300, height: 50)
                .padding([.leading, .trailing], 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .overlay(alignment: .trailing){
                    Button(role: .cancel){
                        
                        showPassword = false
                    } label: {
                        Image(systemName: "lock")
                            .padding()
                            .contentTransition(.symbolEffect)
                            .foregroundColor(.black)


                    }
                    
                }
            
            
            
        }
        
    }
    
    
    
    
}
