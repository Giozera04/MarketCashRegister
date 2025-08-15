    //
    //  LoginFormView.swift
    //  MarketRegisterPurchase
    //
    //  Created by Giovane Junior on 6/5/25.
    //

    import Foundation
    import SwiftUI
    import FirebaseAuth

    struct LoginFormView: View {
        @Binding var email: String
        @Binding var password: String
        @Binding var errorMessage: String
        
        var onSignIn: (@escaping () -> Void) -> Void
        var onSignUp: (@escaping () -> Void) -> Void
        
        @State private var isLoading = false
        @State private var showAlert = false
        @State private var alertMessage = ""
        
        var body: some View {
            VStack(spacing: 16){
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                Button("Forgot Password?"){
                    handleForgotPassword()
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 8)
                
                if isLoading{
                    ProgressView()
                        .padding()
                }
                
                Button("Sign In"){
                    isLoading = true
                    onSignIn {
                        isLoading = false
                        if !errorMessage.isEmpty {
                            showAlert = true
                        }
                    }
                }
                .disabled(isLoading)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Sign Up"){
                    isLoading = true
                    onSignUp{
                        isLoading = false
                        if !errorMessage.isEmpty {
                            showAlert = true
                        }
                    }
                }
                .disabled(isLoading)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .alert("Error", isPresented: $showAlert){
                Button("OK", role: .cancel) {
                    alertMessage = ""
                }
            } message: {
                Text(alertMessage)
            }
        }
        
        func handleForgotPassword(){
            guard !email.isEmpty else {
                alertMessage = "Please enter your email."
                showAlert = true
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    alertMessage = "Failed to send reset email: \(error.localizedDescription)"
                } else {
                    alertMessage = "Password reset email sent sent to \(email)"
                }
                showAlert = true
            }
        }
    }
