//
//  CartView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 3/1/25.
//

import SwiftUI

struct CartView: View {
    @ObservedObject var cart: Cart
    let onBack: () -> Void
    let storeName: String
    
    
    
    var body: some View {
        
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                
                if cart.items.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray.opacity(0.6))
                        Text("Your cart is empty")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(cart.items) { item in
                                CartItemCard(item: item, cart: cart)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 0)
                    }
                }

            }
        }
    }
}
