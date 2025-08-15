//
//  OrderHistoryView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 5/30/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Order: Identifiable {
    var id: String
    var timestamp: Date
    var items: [Product]
    var total: Double
    var storeName: String?
}

struct OrderHistoryView: View {
    @State private var orders: [Order] = []
    @State private var authListenerHandler: AuthStateDidChangeListenerHandle?
    
    var body: some View {
        NavigationStack{
            List(orders) { order in
                NavigationLink(destination: OrderDetailView(order: order)){
                    VStack(alignment: .leading) {
                        Text("🗓️ \(order.timestamp.formatted(date: .abbreviated, time: .shortened))")
                        Text("🛒 \(order.items.reduce(0) { $0 + $1.quantity }) items")
                        Text("💰 Total: $\(order.total, specifier: "%.2f")")
                        
                        if let store = order.storeName {
                            Text("🏠 Store: \(store)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("My orders")
            .onAppear {
                startListeningForAuthChanges()
            }
            .onDisappear{
                stopListeningForAuthChanges()
            }
        }
    }
    
    func startListeningForAuthChanges() {
        authListenerHandler = Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                print("✅ Logged in as \(user.uid), fetching orders...")
                fetchOrders()
            } else {
                print("🚪 Logged out, clearing orders")
                orders = []
            }
        }
    }
    
    func stopListeningForAuthChanges() {
        if let handle = authListenerHandler {
            Auth.auth().removeStateDidChangeListener(handle)
            authListenerHandler = nil
        }
    }
    
    
    func fetchOrders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                orders = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let timestamp = data["timestamp"] as? Timestamp,
                        let total = data["total"] as? Double,
                        let itemsData = data["items"] as? [[String: Any]]
                    else { return nil }
                    
                    let items = itemsData.compactMap { item in
                        Product(
                            id: item["id"] as? String ?? UUID().uuidString,
                            name: item["name"] as? String ?? "Unknown",
                            price: item["price"] as? Double ?? 0.0,
                            barcode: item["barcode"] as? String ?? "",
                            quantity: item["quantity"] as? Int ?? 1,
                            imageUrl: item["imageUrl"] as? String
                        )
                    }
                    
                    let storeName = data["storeName"] as? String
                    
                    return Order(
                        id: doc.documentID,
                        timestamp: timestamp.dateValue(),
                        items: items,
                        total: total,
                        storeName: storeName
                        )
                }
            }
        
    }
    
}
