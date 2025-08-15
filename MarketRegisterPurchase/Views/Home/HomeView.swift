//
//  HomeView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/3/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var didOpenScannerManually = false
    
    @State private var goToLocationRequired = false
    @Binding var showScanner: Bool
    @State private var showCheckPriceScanner = false
    @State private var showLoginSheet = false

    var body: some View {
        NavigationStack {
            ZStack{
                VStack(spacing: 20) {
                    
                    NavigationLink(
                        destination: LoginPromptView(
                            onLogin: { showLoginSheet = false},
                            onSignup: { showLoginSheet = false},
                            onCancel: { showLoginSheet = false}
                        ),
                        isActive: $showLoginSheet
                    ){
                        EmptyView()
                    }
                    
                    Text("Welcome to Express Checkout")
                        .font(.title2)
                        .padding(.top)
                    
                    
                    //Express pay button
                    Button(action: {
                        print("🔵 ExpressPay tapped")
                        
                        if Auth.auth().currentUser != nil {
                            print("✅ User is logged in")
                            
                            switch locationManager.authorizationStatus {
                            case .notDetermined:
                                print("🟡 Location not determined")
                                locationManager.requestLocationPermission()
                                return
                            case .authorizedWhenInUse, .authorizedAlways:
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        showScanner = true
                                        didOpenScannerManually = true
                                    }
                                }
                                
                                
                                
                            case .denied, .restricted:
                                print("🔴 Location access denied")
                                goToLocationRequired = true  // Trigger navigation instead of .sheet
                            default:
                                break
                            }
                        } else {
                            print("🔴 User not logged in")
                            showLoginSheet = true
                        }
                        
                    }) {
                        HStack {
                            Image(systemName: "barcode.viewfinder")
                            Text("ExpressPay")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        showCheckPriceScanner = true
                    }) {
                        HStack {
                            Image(systemName: "tag")
                            Text("Check a Price")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showCheckPriceScanner){
                        CheckPriceScannerView()
                    }
                    
                    NavigationLink(
                        destination: LocationRequiredView {
                            goToLocationRequired = false
                            locationManager.requestLocationPermission()
                        },
                        isActive: $goToLocationRequired,
                        label: { EmptyView() }
                    )
                    .hidden()
                    
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(.all)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)){ _ in
            locationManager.refreshAuthorizationStatus()
                
            
                // Only open scanner if store has been detected
            if didOpenScannerManually,
                (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways),
                   locationManager.currentStore != nil {
                    showScanner = true
                }
        }
        .onChange(of: showScanner) { oldValue, newValue in
            if !newValue {
                didOpenScannerManually = false
            }
        }
    }
}
