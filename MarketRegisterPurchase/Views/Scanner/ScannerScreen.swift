//
//  ScannerScreen.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/3/25.
//

import Foundation
import SwiftUI
import AVFoundation
import FirebaseAuth
import FirebaseFirestore

struct ScannerScreen: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    @Binding var isPresented: Bool
    
    @State private var scannedProduct: Product? = nil
    @State private var isShowingCart = false
    @State private var didScan = false
    @State private var hasStartedScanning = false
    @State private var showScanFlash = false
    @State private var lastScannedBounds: CGRect?
    @State private var isShowingNotFound = false
    @State private var isShowingManualEntry = false
    @State private var enteredBarcode = ""
    
    @AppStorage("hasScannedAtLeastOnce") private var hasScannedAtLeastOnce = false
    
    
    var body: some View {
        ZStack {
            // 📸 Live camera preview
            GeometryReader { geo in
                let boxSize: CGFloat = 250
                let scanX = (geo.size.width - boxSize) / 2
                let scanY = (geo.size.height - boxSize) / 2
                let scanRect = CGRect(x: scanX, y: scanY, width: boxSize, height: boxSize)
                
                ZStack {
                    CameraPreviewView(
                        didScan: $didScan,
                        scanningEnabled: $hasStartedScanning,
                        onBarcodeScanned: { barcode in
                            hasScannedAtLeastOnce = true
                            //cartViewModel.addProduct(barcode: barcode)
                            fetchProduct(for: barcode)
                            
                            withAnimation(.easeOut(duration: 0.2)){
                                showScanFlash = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    showScanFlash = false
                                }
                            }
                            
                        },
                        lastScannedBounds: $lastScannedBounds,
                        scanRect: scanRect
                    )
                    .ignoresSafeArea()
                    
                    // ✅ Visible scan box overlay
                    ZStack {
                        
                        if let bounds = lastScannedBounds, showScanFlash {
                            Rectangle()
                                .stroke(Color.red, lineWidth: 3)
                                .frame(width: bounds.width, height: bounds.height)
                                .position(x: bounds.midX, y: bounds.midY)
                                .animation(.easeOut(duration: 0.2), value: showScanFlash)
                        }
                        
                        let cornerSize: CGFloat = 30
                        let lineWidth: CGFloat = 4
                        let boxFrame = CGRect(x: scanX, y: scanY, width: boxSize, height: boxSize)
                        
                        // Top-left corner
                        Path { path in
                            path.move(to: CGPoint(x: boxFrame.minX, y: boxFrame.minY + cornerSize))
                            path.addLine(to: CGPoint(x: boxFrame.minX, y: boxFrame.minY))
                            path.addLine(to: CGPoint(x: boxFrame.minX + cornerSize, y: boxFrame.minY))
                        }
                        .stroke(Color.white, lineWidth: lineWidth)
                        
                        // Top-right corner
                        Path { path in
                            path.move(to: CGPoint(x: boxFrame.maxX - cornerSize, y: boxFrame.minY))
                            path.addLine(to: CGPoint(x: boxFrame.maxX, y: boxFrame.minY))
                            path.addLine(to: CGPoint(x: boxFrame.maxX, y: boxFrame.minY + cornerSize))
                        }
                        .stroke(Color.white, lineWidth: lineWidth)
                        
                        // Bottom-left corner
                        Path { path in
                            path.move(to: CGPoint(x: boxFrame.minX, y: boxFrame.maxY - cornerSize))
                            path.addLine(to: CGPoint(x: boxFrame.minX, y: boxFrame.maxY))
                            path.addLine(to: CGPoint(x: boxFrame.minX + cornerSize, y: boxFrame.maxY))
                        }
                        .stroke(Color.white, lineWidth: lineWidth)
                        
                        // Bottom-right corner
                        Path { path in
                            path.move(to: CGPoint(x: boxFrame.maxX - cornerSize, y: boxFrame.maxY))
                            path.addLine(to: CGPoint(x: boxFrame.maxX, y: boxFrame.maxY))
                            path.addLine(to: CGPoint(x: boxFrame.maxX, y: boxFrame.maxY - cornerSize))
                        }
                        .stroke(Color.white, lineWidth: lineWidth)
                    }
                    
                }
            }
            
            VStack{
                TopBar(title: "Expresspay",
                       location: locationManager.currentStore?.name ?? "Loading..."
                ) {
                    isPresented = false
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            
            
            
            VStack {
                Spacer()
                
                // 🔻 Overlay de boas-vindas no fundo da tela
                if !hasStartedScanning {
                    if cartViewModel.cart.items.isEmpty {
                        WelcomeOverlay{
                            startScanning()
                        }
                    } else {
                        ContinueShoppingOverlay (
                            onScanAnother: {
                                hasStartedScanning = true
                            },
                            onGoToCart: {
                                isShowingCart = true
                            },
                            cartItemCount: cartViewModel.cart.items.reduce(0) { $0 + $1.quantity}
                        )
                    }
                }
                
                
                // 🔻 Produto escaneado? Mostra o overlay com info e botões
                else if let product = scannedProduct {
                    ScannedProductOverlay(
                        product: product,
                        onScanAnother: {
                            scannedProduct = nil
                            didScan = false
                        },
                        onGoToCart: {
                            isShowingCart = true
                        },
                        cartItemCount: cartViewModel.cart.items.reduce(0) { $0 + $1.quantity}
                    )
                }
            }
            .animation(.easeInOut, value: scannedProduct)
            .onChange(of: isShowingCart) {
                if !isShowingCart && cartViewModel.cart.items.isEmpty {
                    hasStartedScanning = false
                }
            }
            .onChange(of: cartViewModel.cart.items) { oldItems, newItems in
                if newItems.isEmpty {
                    scannedProduct = nil
                    
                }
            }
            
            if hasStartedScanning && scannedProduct == nil {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingCart = true
                        }) {
                            Image(systemName: "cart")
                                .font(.title)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.bottom, 30)
                        .padding(.trailing, 20)
                    }
                }
            }
            
            if isShowingNotFound {
                ProductNotFoundOverlay(
                    onScanAgain: {
                        isShowingNotFound = false
                        hasStartedScanning = true
                        didScan = false
                    },
                    onEnterBarcode: {
                        isShowingNotFound = false
                        isShowingManualEntry = true
                    },
                    onCancel: {
                        isShowingNotFound = false
                        hasStartedScanning = true
                        didScan = false
                    }
                )
            }
            
            if isShowingManualEntry {
                ManualBarcodeEntryOverlay(
                    barcode: $enteredBarcode,
                    onSearch: {
                        FirebaseService().fetchProduct(by: enteredBarcode) { product, error in
                            DispatchQueue.main.async {
                                if let error = error as NSError? {
                                    if error.domain == FirestoreErrorDomain,
                                       error.code == FirestoreErrorCode.unavailable.rawValue {
                                        cartViewModel.currentError = .noInternet
                                    } else {
                                        cartViewModel.currentError = .unknown(message: error.localizedDescription)
                                    }
                                    isShowingManualEntry = false
                                    enteredBarcode = ""
                                } else if let product = product {
                                    cartViewModel.addProduct(barcode: enteredBarcode)
                                    scannedProduct = product
                                    isShowingManualEntry = false
                                    enteredBarcode = ""
                                } else {
                                    // Product not found
                                    isShowingManualEntry = false
                                    isShowingNotFound = true
                                    enteredBarcode = ""
                                }
                            }
                        }
                    },
                    onCancel: {
                        isShowingManualEntry = false
                        hasStartedScanning = true
                        didScan = false
                    }
                )
            }
            if let error = cartViewModel.currentError {
                ErrorOverlay (
                    title: error.title,
                    message: error.message,
                    primaryButtonTitle: "Dismiss",
                    primaryAction: {
                        cartViewModel.currentError = nil
                    }
                )
            }
            
        }
        .fullScreenCover(isPresented: $isShowingCart) {
            NavigationStack{
                CartViewCheckout()
            }
            .environmentObject(cartViewModel)
        }
    }
    
    func startScanning() {
        scannedProduct = nil
        didScan = false
        hasStartedScanning = true
    }
    
    func fetchProduct(for barcode: String) {
        FirebaseService().fetchProduct(by: barcode) { product, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    if error.domain == FirestoreErrorDomain,
                       error.code == FirestoreErrorCode.unavailable.rawValue {
                        cartViewModel.currentError = .noInternet
                    } else {
                        cartViewModel.currentError = .unknown(message: error.localizedDescription)
                    }
                } else if let product = product {
                    cartViewModel.cart.addItem(product)
                    self.scannedProduct = product
                    self.didScan = true
                } else {
                    // This is the clean "not found" flow
                    self.isShowingNotFound = true
                    self.didScan = true
                }
            }
        }
    }
}



extension Notification.Name {
    static let returningFromCart = Notification.Name("returningFromCart")
}
