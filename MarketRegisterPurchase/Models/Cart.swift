//
//  Cart.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 3/1/25.
//

import Foundation

class Cart: ObservableObject {
    static var shared = Cart()
    var totalQuantity: Int {
        let total = items.reduce(0) { $0 + $1.quantity }
        print("🟢 Total quantity now: \(total)")
        return total
    }
    
    @Published var items: [Product] = [] {
        didSet {
            saveCart()
        }
    }
    
    private let cartKey = "SavedCartItems"
    
    init () {
        loadCart()
    }
    
    func addItem(_ product: Product) {
        if let index = items.firstIndex(where: {$0.id == product.id}) {
            items[index].quantity += 1
        } else {
            items.append(product)
        }
    }
    
    func removeItem(at product: Product) {
        items.removeAll { $0.id == product.id }
    }
    
    func totalCost() -> Double {
        items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }
    
    func clear(){
        items.removeAll()
    }
    
    func increaseQuantity(for product: Product) {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].quantity += 1
            items = items
            print("➕ Increased \(product.name) to \(items[index].quantity)")
        }
    }
    
    func decreaseQuantity(for product: Product) {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
                items = items
            } else {
                items.remove(at: index)
            }
        }
    }
    
    
    //Persistence
    
    private func saveCart() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: cartKey)
            print("✅ Cart saved: \(items.map { $0.name })")
        } catch {
            print("❌ Failed to encode cart:", error)
        }
    }
    
    
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey) {
            do {
                let decoded = try JSONDecoder().decode([Product].self, from: data)
                items = decoded
                print("✅ Cart loaded from storage: \(items.map { $0.name })")
            } catch {
                print("❌ Failed to decode saved cart:", error)
            }
        } else {
            print("ℹ️ No saved cart found.")
        }
    }
}
