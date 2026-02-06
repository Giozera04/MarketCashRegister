//
//  MarketRegisterPurchaseApp.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 3/1/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import StripeCore

@main
struct MarketRegisterPurchaseApp: App {
    @StateObject private var cartViewModel: CartViewModel
    @StateObject private var locationManager: LocationManager
    
    init() {
        FirebaseApp.configure()
        print("Configuring Firebase...")
        
        StripeAPI.defaultPublishableKey = "pk_test_51SwTz7LiEbqyWjZMs7ipljdANxJnake4dmh5K6hkuSwvRJhDp5xbEhjvAlYE2EtkXizzZAUpgqym93OFCfoNT5kr00vAAldsJO"
        
        let locManager = LocationManager()
        _locationManager = StateObject(wrappedValue: locManager)
        _cartViewModel = StateObject(wrappedValue: CartViewModel(locationManager: locManager))
    }
    
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
                .environmentObject(cartViewModel)
                .environmentObject(locationManager)
        }
    }
}
