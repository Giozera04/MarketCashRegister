//
//  LoginPromptView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/4/25.
//

import Foundation
import SwiftUI

struct LoginPromptView: View {
    var onLogin: () -> Void
    var onSignup: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20){
            Text("🔒 Account Required")
                .font(.title2)
                .bold()
            
            Text("You need to sign in or create an account to use ExpressPay")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Sign In"){
                onLogin()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Button("Create an Account"){
                onSignup()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Button("Cancel"){
                onCancel()
            }
            .padding(.top)
        }
        .padding(.bottom)
    }
}
