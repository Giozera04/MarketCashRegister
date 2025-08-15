//
//  Store.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/10/25.
//

import Foundation
import CoreLocation

struct Store: Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let radius: Double
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
