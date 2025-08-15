//
//  MainTabView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/3/25.
//

/*import Foundation
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State private var isShowingScanner = false

    var body: some View {
        ZStack {
            TabView {
                HomeView(showScanner: $isShowingScanner)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                OrderHistoryView()
                    .tabItem {
                        Label("My Orders", systemImage: "cart")
                    }

                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
            }

            if isShowingScanner {
                
                ScannerScreen(isPresented: $isShowingScanner)
                    .environmentObject(cartViewModel)
                    .environmentObject(locationManager)
                    .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                            .zIndex(1)
                            .ignoresSafeArea()
            }
        }
        .animation(.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.4), value: isShowingScanner)
    }
}*/



import SwiftUI

// ① Define your tabs
private enum Tab { case home, orders, account }

extension Notification.Name {
  static let goHome = Notification.Name("goHome")
}

struct MainTabView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var locationManager: LocationManager

    // ② Add a selection binding
    @State private var selectedTab: Tab = .home
    @State private var isShowingScanner = false

    var body: some View {
        ZStack {
            // ③ Drive the TabView with selection:
            TabView(selection: $selectedTab) {
                HomeView(showScanner: $isShowingScanner)
                    .tag(Tab.home)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                OrderHistoryView()
                    .tag(Tab.orders)
                    .tabItem {
                        Label("My Orders", systemImage: "cart")
                    }

                AccountView()
                    .tag(Tab.account)
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
            }

            if isShowingScanner {
                ScannerScreen(isPresented: $isShowingScanner)
                    .environmentObject(cartViewModel)
                    .environmentObject(locationManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
                    .zIndex(1)
                    .ignoresSafeArea()
            }
        }
        .animation(.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.4), value: isShowingScanner)
        // ④ Listen for the “go home” broadcast:
        .onReceive(NotificationCenter.default.publisher(for: .goHome)) { _ in
            selectedTab    = .home       // switch back to Home tab
            isShowingScanner = false     // dismiss the entire scanner/cart/payment flow
        }
    }
}
