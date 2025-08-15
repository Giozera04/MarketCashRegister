//
//  OrderDetailLoaderView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 07/23/25.
//

import SwiftUI
import FirebaseFirestore
import Foundation

struct OrderDetailLoaderView: View {
    let orderId: String
    @State private var order: Order?
    @State private var isLoading = true
    @State private var loadError: Error?
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading order…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let order = order {
                OrderDetailView(order: order)
                    .environmentObject(locationManager)
            } else {
                VStack(spacing: 12) {
                    Text("❌ Failed to load order")
                        .font(.headline)
                    if let err = loadError {
                        Text(err.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear(perform: fetchOrder)
        .navigationBarHidden(true)
    }

    private func fetchOrder() {
        let db = Firestore.firestore()
        db.collection("orders").document(orderId).getDocument { snap, err in
            if let err = err {
                self.loadError = err
                self.isLoading = false
                return
            }
            guard let data = snap?.data(),
                  let ts = data["timestamp"] as? Timestamp,
                  let total = data["total"] as? Double,
                  let itemsData = data["items"] as? [[String: Any]]
            else {
                self.loadError = NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Malformed order data"]
                )
                self.isLoading = false
                return
            }

            let items = itemsData.compactMap { dict -> Product? in
                guard
                    let id = dict["id"] as? String,
                    let name = dict["name"] as? String,
                    let price = dict["price"] as? Double,
                    let barcode = dict["barcode"] as? String,
                    let qty = dict["quantity"] as? Int
                else { return nil }
                return Product(
                    id: id,
                    name: name,
                    price: price,
                    barcode: barcode,
                    quantity: qty,
                    imageUrl: dict["imageUrl"] as? String
                )
            }

            let storeName = data["storeName"] as? String
            self.order = Order(
                id: orderId,
                timestamp: ts.dateValue(),
                items: items,
                total: total,
                storeName: storeName
            )
            self.isLoading = false
        }
    }
}
