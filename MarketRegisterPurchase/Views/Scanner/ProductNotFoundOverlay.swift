//
//  ProductNotFoundOverlay.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/30/25.
//

import Foundation
import SwiftUI

struct ProductNotFoundOverlay: View {
    var onScanAgain: () -> Void
    var onEnterBarcode: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .transition(.opacity)
        
        VStack(spacing: 20){
            
            HStack {
                    Spacer()
                    Button(action: {
                        onCancel()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            
            Text("Sorry, we can’t find that product.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            Text("Please scan the barcode on the product, not the shelf barcode.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                onScanAgain()
            }) {
                Text("Scan Again")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.gray)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
            }
            .padding(.horizontal)
            
            Text("Search item by typing the product barcode.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                onEnterBarcode()
            }) {
                Text("Enter Barcode")
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 20)
        .padding()
    }
    
}
