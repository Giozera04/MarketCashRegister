//
//  PaymentPlaceholderView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/16/25.
//

import Foundation
import SwiftUI

struct PaymentPlaceholderView: View {
    let onSimulatePayment: () -> Void
    let orderId: String
    
    @State private var showReceipt = false
   
    
    var body: some View {
        VStack(spacing: 24) {
            Text("💳 Payment")
                .font(.largeTitle)
                .bold()
            
            Text("This is where the real payment (pix or card) would happen")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            NavigationLink(
                destination: ReceiptView(orderId: orderId),
                isActive: $showReceipt
            ) {
                EmptyView()
            }
            
            Button(action: {
                onSimulatePayment()
                self.showReceipt = true
            }) {
                Text("Simulate payment")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Payment")
    }
}
