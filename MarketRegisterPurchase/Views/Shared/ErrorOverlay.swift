//
//  ErrorOverlay.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 7/6/25.
//

import Foundation
import SwiftUI

struct ErrorOverlay: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    var secondaryButtonTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text(title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: primaryAction){
                        Text(primaryButtonTitle)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if let secondaryTitle = secondaryButtonTitle,
                        let secondaryAction = secondaryAction {
                            Button(action: secondaryAction) {
                                Text(secondaryTitle)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                        }
                }
                
                
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 24)
        }
    }
}
