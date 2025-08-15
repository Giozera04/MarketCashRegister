//
//  ReceiptView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/17/25.
//

import Foundation
import SwiftUI

struct ReceiptView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager

    let orderId: String
    
    @State private var showDetails = false

    var body: some View {
        VStack(spacing: 0) {
            
            NavigationLink(
                            destination: OrderDetailLoaderView(orderId: orderId),
                            isActive: $showDetails
                        ) {
                            EmptyView()
                        }
            
            // Top bar pinned at top
            TopBar(
                title: "Receipt",
                location: locationManager.currentStore?.name ?? "Your Store",
                useSafeAreaPadding: true
            ) {
                dismiss()
            }

            // Scrollable content below
            VStack {
            
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 72))
                                .foregroundColor(.green)
                                .padding(.top, 24)
                    
                    Text("You are almost there!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                       

                    Text("Show this barcode at the exit.")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                    
                      
                    
                    
                    VStack(spacing: 4) {
                        Text("🧾 Order ID")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(orderId)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if let barcode = generateBarcode(from: orderId) {
                        barcode
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    } else {
                        Text("⚠️ Failed to generate barcode")
                            .foregroundColor(.red)
                    }

                    

                    Button("Scanned? See your order details") {
                        showDetails = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }

    func generateBarcode(from string: String) -> Image? {
        let data = string.data(using: .ascii)

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            if let outputImage = filter.outputImage {
                let context = CIContext()
                if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    let uiImage = UIImage(cgImage: cgImage)
                    return Image(uiImage: uiImage)
                }
            }
        }
        return nil
    }
}
