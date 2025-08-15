//
//  AppError.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 7/6/25.
//

import Foundation

enum AppError: Identifiable {
    var id: String { UUID().uuidString }
    
    case noInternet
    case permissionDenied(feature : String)
    case notFound(item: String)
    case paymentFailed(reason: String)
    case unknown(message: String)
}

extension AppError {
    var title: String {
        switch self {
        case .noInternet:
            return "No Internet Connection"
        case .permissionDenied:
            return "Permission Denied"
        case .notFound:
            return "Not Found"
        case .paymentFailed:
            return "Payment Failed"
        case .unknown:
            return "Oops!"
        }
    }

    var message: String {
        switch self {
        case .noInternet:
            return "Please check your connection and try again."
        case .permissionDenied(let feature):
            return "The app does not have permission to access \(feature). Please enable it in Settings."
        case .notFound(let item):
            return "\(item) could not be found."
        case .paymentFailed(let reason):
            return "Your payment could not be completed: \(reason)"
        case .unknown(let message):
            return message
        }
    }
}

