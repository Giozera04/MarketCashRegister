//
//  ManualBarcodeEntryOverlay.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 7/1/25.
//

import Foundation
import SwiftUI

struct ManualBarcodeEntryOverlay: View {
    @Binding var barcode: String
    
    var onSearch: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .transition(.opacity)
        
        VStack {
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
            
            Text("Enter all numbers\n beneath the product barcode")
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            Image(systemName: "barcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.gray)
            
            TextField("Barcode", text: $barcode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                onSearch()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 20)
        .padding()
    }
}
