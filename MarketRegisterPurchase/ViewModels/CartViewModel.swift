//
//  CartViewModel.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 3/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class CartViewModel: ObservableObject {
    @Published var cart = Cart.shared
    private let firebaseService = FirebaseService()
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    @Published var totalQuantity: Int = 0
    @Published var currentError: AppError? = nil
    
    init(locationManager: LocationManager){
        self.locationManager = locationManager
        loadCartFromFirestore()
        
        cart.$items
            .sink { [weak self] items in
                self?.syncCartToFirestore()
                self?.totalQuantity = items.reduce(0) { $0 + $1.quantity }
            }
            .store(in: &cancellables)
        
    }
    
    func addProduct(barcode: String){
        firebaseService.fetchProduct(by: barcode) { [weak self] product, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    if error.domain == FirestoreErrorDomain,
                       error.code == FirestoreErrorCode.unavailable.rawValue {
                        self?.currentError = .noInternet
                    } else {
                        self?.currentError = .unknown(message: error.localizedDescription)
                    }
                } else if let product = product {
                    self?.cart.addItem(product)
                } else {
                    self?.currentError = .notFound(item: "Product")
                }
            }
        }
    }
    
    func loadCartFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("carts").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let items = data["items"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    self.cart.items = items.map { dict in
                        Product(
                            id: dict["id"] as? String ?? UUID().uuidString,
                            name: dict["name"] as? String ?? "Unkown",
                            price: dict["price"] as? Double ?? 0.0,
                            barcode: dict["barcode"] as? String ?? "",
                            quantity: dict["quantity"] as? Int ?? 1,
                            imageUrl: dict["imageUrl"] as? String
                        )
                    }
                    print("✅ Cart loaded from Firestore.")
                }
            } else {
                print("ℹ️ No cart found for user. Starting fresh.")
            }
        }
    }
    
    func syncCartToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        print("📦 Syncing cart to Firestore with items:")
            cart.items.forEach { item in
                print("• \(item.name) - \(item.quantity)x - $\(item.price)")
            }
        
        let itemsData = cart.items.map{ item in
            return [
                "id": item.id,
                "name": item.name,
                "price": item.price,
                "barcode": item.barcode,
                "quantity": item.quantity,
                "imageUrl": item.imageUrl ?? ""
            ]
        }
        
        let cartData: [String: Any] = [
            "items": itemsData,
            "updateAt": Timestamp(date: Date())
        ]
        
        Firestore.firestore().collection("carts").document(userId).setData(cartData) { error in
            if let error = error {
                print("❌ Failed to sync cart: \(error.localizedDescription)")
            } else {
                print("✅ Cart synced successfully")
            }
        }
        
    }
    
    func checkout(completion: @escaping (String?) -> Void) {
        
        print("🛒 Starting checkout...")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user signed in.")
            return
        }
        
        print("👤 User ID (checkout):", userId)
        
        let db = Firestore.firestore()
        
        
        let orderItems = cart.items.map { item in
            return [
                "id": item.id,
                "name": item.name,
                "price": item.price,
                "barcode": item.barcode,
                "quantity": item.quantity,
                "imageUrl": item.imageUrl ?? ""
            ]
        }
        
        var order: [String: Any] = [
            "userId": userId,
            "timestamp": Timestamp(date: Date()),
            "items": orderItems,
            "total": cart.totalCost(),
            "status": "created"
        ]
        
        if let store = locationManager.currentStore {
            order["storeId"] = store.id
            order["storeName"] = store.name
        } else {
            print("⚠️ No store found during checkout")
        }
        
        let ref = db.collection("orders").document()
        let orderId = ref.documentID
        ref.setData(order) { error in
            if let error = error {
                print("❌ Failed to save order: \(error.localizedDescription)")
                completion(nil)
            } else {
                print("✅ Order saved successfully. Order ID: \(orderId)")
                
                self.cart.clear()
                UserDefaults.standard.set(false, forKey: "hasScannedAtLeastOnce")
                completion(orderId)
            }
        }
    }
    
}
