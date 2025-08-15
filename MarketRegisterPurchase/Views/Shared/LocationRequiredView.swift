//
//  LocationRequiredView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/9/25.
//

import Foundation
import SwiftUI

struct LocationRequiredView: View {
    var onTryAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "location.slash")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Allow precise location access to use")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("In-Store Features")
                .font(.title2)
                .bold()
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("ALLOW ACCESS")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Text("Location access is required to use Expresspay features. \nPlease enable precise location in Settings.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
