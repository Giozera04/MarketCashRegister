//
//  WelcomeOverlay.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/4/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct WelcomeOverlay: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("👋 Olá, \(Auth.auth().currentUser?.email?.components(separatedBy: "@").first ?? "Cliente")!")
                    .font(.title3)
                    .bold()

                Text("Use a câmera para escanear o código de barras e adicionar ao carrinho.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Button("START SCANNING") {
                onStart()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.top, 8)
        
        }
        
        .padding(.vertical, 20)
        .padding(.bottom, 40) // Extra bottom padding to avoid gap
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(radius: 10)
        .ignoresSafeArea(edges: .horizontal)
        
    }
}

