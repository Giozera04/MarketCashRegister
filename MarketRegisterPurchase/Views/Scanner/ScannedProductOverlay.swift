//
//  ScannedProductOverlay.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/3/25.
//

import SwiftUI
import Foundation

struct ScannedProductOverlay: View {
    let product: Product
    let onScanAnother: () -> Void
    let onGoToCart: () -> Void
    var cartItemCount: Int
    var confirmationMessage: String? = "✅ Added to cart"
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                
                if let message = confirmationMessage {
                    Text(message)
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .padding(.top, 8)
                        .transition(.opacity)
                    
                }
                
                Spacer().frame(height: 30)
                
                HStack(alignment: .top, spacing: 16) {
                    if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 80, height: 80)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("💲 $\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(Color.green)
                            .bold()
                    }
                    
                    Spacer()
                }
                
                
                Spacer().frame(height: 50)
                
                VStack(spacing: 10) {
                    
                    Button("🔄 Scan Another Item") {
                        onScanAnother()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)

                    Button("🛒 Go to Cart (\(cartItemCount))") {
                        onGoToCart()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .padding()
            .frame(width: geometry.size.width,
                   height: geometry.size.height * 0.45)
            .background(Color.white)
            
            .shadow(radius: 10)
            .position(x: geometry.size.width / 2,
                      y: geometry.size.height - (geometry.size.height * 0.225))
            .transition(.move(edge: .bottom))
        }
        .ignoresSafeArea()
    }
}
