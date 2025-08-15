//
//  Product.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 3/1/25.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable, Equatable {
    var id: String
    let name: String
    let price: Double
    let barcode: String
    var quantity: Int = 1
    let imageUrl: String?
}
