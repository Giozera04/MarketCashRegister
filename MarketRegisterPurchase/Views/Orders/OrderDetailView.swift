//
//  OrderDetailView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 5/31/25.
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order               // assumes: total: Double, paymentMethod: String, items: [Product], storeName: String?
    //@Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    private var totalQuantity: Int {
        order.items.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                title: "Order #\(order.id)",
                location: locationManager.currentStore?.name ?? "Your Store",
                useSafeAreaPadding: true
            ) {
                NotificationCenter.default.post(name: .goHome, object: nil)
            }
            
            List {
                summarySection
                itemsSection
            }
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
    
    // MARK: – Summary Card
    private var summarySection: some View {
        Section {
            VStack(spacing: 12) {
                
                
                HStack {
                    Text(order.timestamp, format: .dateTime.year().month().day().hour().minute())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    // (we’ll skip the green “scanned at” for now)
                }
                Divider()
                
                
                // Order Total
                HStack {
                    Text("Order Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(order.total, specifier: "%.2f")")
                        .font(.headline)
                }
                
                Divider()
                
                // Order Count
                HStack {
                    Text("Order Count")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalQuantity)") // ✅ agora usa o total de unidades
                        .font(.headline)
                }
                
                Divider()
                
                // Club Location
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Market Club Location")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(order.storeName ?? "—")
                            .font(.body)
                    }
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // Payment Method
                HStack {
                    Text("Payment Method")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Cartao")
                        .font(.headline)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .listRowBackground(Color.clear)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .textCase(nil)
    }
    
    // MARK: – Purchased Items
    private var itemsSection: some View {
        Section(header:
                    Text("Purchased (\(totalQuantity) Items)") // ✅ total unity
            .font(.headline)
            .padding(.top, 8)
        ) {
            ForEach(order.items) { product in
                HStack(alignment: .top, spacing: 12) {
                    
                    
                    
                    // Product image (or placeholder)
                    if let urlString = product.imageUrl,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(6)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 60, height: 60)
                        }
                        .onAppear {
                            print("🖼️ DetailView attempting to load image URL:", urlString)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .cornerRadius(6)
                            .onAppear {
                                print("🖼️ DetailView: no imageUrl for product", product.id)
                            }
                    }
                    
                    // Product details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Qty: \(product.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(
                            "Price: $\(String(format: "%.2f", product.price))  |  Total: $\(String(format: "%.2f", Double(product.quantity) * product.price))"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .textCase(nil)
    }
}
