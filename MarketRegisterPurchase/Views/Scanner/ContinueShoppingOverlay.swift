//
//  ContinueShoppingOverlay.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/4/25.
//

import Foundation
import SwiftUI

struct ContinueShoppingOverlay: View {
    let onScanAnother: () -> Void
    let onGoToCart: () -> Void
    
    var cartItemCount: Int
    
    var body: some View {
        VStack(spacing: 16){
            Text("Continue Shopping")
                .font(.title3)
                .bold()
            
            Text("You have items in you cart")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 10){
                
                Button("🔄 Scan Another Item") {
                    onScanAnother()
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("🛒 Go to Cart (\(cartItemCount))") {
                    onGoToCart()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 15)
            
        }
        .padding(.vertical, 20)
        .padding(.bottom, 40) // Extra bottom padding to avoid gap
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(radius: 10)
        .ignoresSafeArea(edges: .horizontal)
    }
}
