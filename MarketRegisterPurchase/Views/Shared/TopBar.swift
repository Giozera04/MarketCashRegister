//
//  TopBar.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/4/25.
//

import Foundation
import SwiftUI

struct TopBar: View {
    let title: String
    let location : String
    let onBack: () -> Void
    var useSafeAreaPadding: Bool = true
    
    var body: some View {
        HStack {
            
            Button(action: onBack){
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
            }
            
            VStack(alignment: .leading){
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(location)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    // Favorite or info action
                }) {
                    Image(systemName: "star")
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    // Help action
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing)
        }
        .frame(height: 60)
        .background(Color.blue)
        .padding(.top, useSafeAreaPadding ? topInset : 0)
    }
    private var topInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.safeAreaInsets.top ?? 20
    }
}
