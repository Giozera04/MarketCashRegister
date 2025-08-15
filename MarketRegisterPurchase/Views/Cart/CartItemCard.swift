//
//  CartItemCard.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/26/25.
//

import Foundation
import SwiftUI

struct CartItemCard: View {
    let item: Product
    @ObservedObject var cart: Cart

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = URL(string: item.imageUrl ?? "") {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .bold()

                Text("$\(item.price, specifier: "%.2f") each")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 10) {
                    Button(action: {
                        cart.decreaseQuantity(for: item)
                    }) {
                        Image(systemName: "minus.circle")
                    }

                    Text("\(item.quantity)")
                        .frame(minWidth: 24)

                    Button(action: {
                        cart.increaseQuantity(for: item)
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }

            Spacer()

            Text("$\(Double(item.quantity) * item.price, specifier: "%.2f")")
                .bold()
                .frame(minWidth: 60, alignment: .trailing)
        }
        .padding()
        .frame(height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
        
    }
}
