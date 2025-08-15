//
//  AccountView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/3/25.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            if isLoggedIn {
                Text("Logged in as: \(Auth.auth().currentUser?.email ?? "Unknown")")
                    .font(.headline)
                
                Button("Logout") {
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        errorMessage = "Sign out failed: \(error.localizedDescription)"
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(8)
                .padding(.horizontal)
                
            } else {
                Text("Sign In or Create an Account")
                    .font(.headline)
                
                // Login form SubView
                
                LoginFormView(
                    email: $email,
                    password: $password,
                    errorMessage: $errorMessage,
                    onSignIn: { completion in
                        Auth.auth().signIn(withEmail: email, password: password){ result, error in
                            if let error = error {
                                self.errorMessage = "Sign in error: \(error.localizedDescription)"
                            } else {
                                errorMessage = ""
                            }
                            completion()
                        }
                    },
                    onSignUp: { completion in
                        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                            if let error = error {
                                self.errorMessage = "Sign up error: \(error.localizedDescription)"
                            } else {
                                errorMessage = ""
                            }
                            completion()
                        }
                    }
                )
            }
        }
        .padding()
        .onAppear{
            // Live update whenever the state changes
            
            _ = Auth.auth().addStateDidChangeListener { auth, user in
                isLoggedIn = user != nil
            }
            
        }
    }
}
