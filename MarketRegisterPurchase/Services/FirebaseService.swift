//
//  FirebaseService.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 3/1/25.
//

import Foundation
import FirebaseFirestore

class FirebaseService {
    private let db = Firestore.firestore()
    
    func fetchProduct(by barcode: String, completion: @escaping (Product?, Error?) -> Void){
        db.collection("products").whereField("barcode", isEqualTo: barcode).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error)")
                completion(nil, error)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(nil, nil)
                return
            }
            
            let data = document.data()
            let product = Product(
                id: document.documentID,
                name: data["name"] as? String ?? "Unknown",
                price: data["price"] as? Double ?? 0.0,
                barcode: data["barcode"] as? String ?? "",
                imageUrl: data["imageUrl"] as? String
            )
            completion(product, nil)
        }
    }
}
