//
//  LocationManager.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/8/25.
//

import Foundation
import CoreLocation
import Combine
import FirebaseFirestore

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
        
    var isPermissionDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var stores: [Store] = []
    @Published var currentStore: Store? = nil
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        loadStores()
    }
    
    
    func loadStores() {
        let db = Firestore.firestore()
        db.collection("stores").getDocuments{ snapshot, error in
            if let error = error {
                print("❌ Failed to fetch stores: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self.stores = documents.compactMap { doc in
                let data = doc.data()
                guard
                    let name = data["name"] as? String,
                    let lat = data["latitude"] as? Double,
                    let lon = data["longitude"] as? Double,
                    let radius = data["radius"] as? Double
                else {
                    return nil
                }
                
                return Store(id: doc.documentID, name: name, latitude: lat, longitude: lon, radius: radius)
            }
            
            print("✅ Loaded \(self.stores.count) stores")
            
            if self.userLocation != nil {
                self.updateCurrentStore()
            }
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
        //locationManager.requestLocation()
    }
    
    func refreshAuthorizationStatus() {
        print("📍 Requesting location permission...")
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("📍 Location auth changed to: \(status.rawValue)")
            self.authorizationStatus = status

            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.requestLocation()
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get user location: \(error.localizedDescription)")
    }
    
    func updateCurrentStore() {
        guard let userLoc = userLocation else { return }
        
        for store in stores {
            let distance = userLoc.distance(from: store.location)
            if distance <= store.radius {
                currentStore = store
                print("🟢 User is in store: \(store.name)")
                return
            }
        }
        
        currentStore = nil
        print("⚠️ User is not in any store")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        userLocation = location.last
            print("📍 Got location update: \(userLocation?.coordinate.latitude ?? 0), \(userLocation?.coordinate.longitude ?? 0)")
            print("🟢 User is in store? \(currentStore != nil)")
        
        if !stores.isEmpty {
            updateCurrentStore()
        }
            // ✅ Done — no need to keep updating
            locationManager.stopUpdatingLocation()
    }
    
}
