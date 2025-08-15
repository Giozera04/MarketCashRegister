//
//  MarketRegisterPurchaseApp.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 3/1/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth


@main
struct MarketRegisterPurchaseApp: App {
    @StateObject private var cartViewModel: CartViewModel
    @StateObject private var locationManager: LocationManager
    
    init() {
        FirebaseApp.configure()
        print("Configuring Firebase...")
        
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
