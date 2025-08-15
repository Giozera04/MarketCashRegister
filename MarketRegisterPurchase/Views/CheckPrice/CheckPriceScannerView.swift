//
//  CheckPriceScannerView.swift
//  MarketRegisterPurchase
//
//  Created by Giovane Junior on 6/3/25.
//

import Foundation
import AVFoundation
import SwiftUI
import BLTNBoard

struct CheckPriceScannerView: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CheckPriceScannerView
        var captureSession: AVCaptureSession?
        var viewController: UIViewController?
        var bulletinManager: BLTNItemManager?
        var didScan = false
        var lastScanTime: Date?
        let service = FirebaseService()
        
        init(parent: CheckPriceScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            let now = Date()
            if let last = lastScanTime, now.timeIntervalSince(last) < 2 {
                return
            }
            lastScanTime = now
            if didScan { return }
            
            guard
                let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                let code = metadataObject.stringValue
                    else { return }
            
            didScan = true
            captureSession?.stopRunning()
            fetchProductInfo(for: code)
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
        
        func fetchProductInfo(for code: String) {
            service.fetchProduct(by: code) { product, error in
                DispatchQueue.main.async {
                    if let product = product {
                        self.showProductInfo(product)
                    } else {
                        self.showError("Product not found.")
                    }
                }
            }
        }
        
        func showProductInfo(_ product: Product){
            let page = BLTNPageItem(title: product.name)
            page.descriptionText = "💲 Price: $\(product.price)"
            page.actionButtonTitle = "Scan Another"
            page.isDismissable = true
            
            page.actionHandler = { item in
                self.didScan = false
                self.captureSession?.startRunning()
                item.manager?.dismissBulletin()
            }

            
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl){
                //Asynchronous
                
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
                            page.image = resizedImage
                            page.imageAccessibilityLabel = "Product Image"
                            
                            
                            let manager = BLTNItemManager(rootItem: page)
                            self.bulletinManager = manager
                            if let vc = self.viewController {
                                manager.showBulletin(above: vc)
                            }
                        }
                    }
                }.resume()
            } else {
                let manager = BLTNItemManager(rootItem: page)
                self.bulletinManager = manager
                if let vc = self.viewController {
                    manager.showBulletin(above: vc)
                }
            }
        }
        
        func showError(_ message: String) {
            let page = BLTNPageItem(title: "❌ Error")
            page.descriptionText = message
            page.actionButtonTitle = "Try Again"
            page.isDismissable = true
            
            page.actionHandler = { item in
                self.didScan = false
                self.captureSession?.startRunning()
                item.manager?.dismissBulletin()
            }
            
            let manager = BLTNItemManager(rootItem: page)
            self.bulletinManager = manager
            if let vc = self.viewController {
                manager.showBulletin(above: vc)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }

        func makeUIViewController(context: Context) -> UIViewController {
            let vc = UIViewController()
            context.coordinator.viewController = vc

            let session = AVCaptureSession()
            context.coordinator.captureSession = session

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return vc }

            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
                output.metadataObjectTypes = [.ean13, .ean8, .code128, .upce]
            }

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.frame = vc.view.bounds
            preview.videoGravity = .resizeAspectFill
            vc.view.layer.addSublayer(preview)

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }

            return vc
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
