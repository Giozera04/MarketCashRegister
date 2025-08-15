    //
    //  CameraPreviewView.swift
    //  MarketRegisterPurchase
    //
    //  Created by Giovane Junior on 6/3/25.
    //



    import Foundation
    import SwiftUI
    import AVFoundation

    struct CameraPreviewView: UIViewControllerRepresentable {
        @Binding var didScan: Bool
        @Binding var scanningEnabled: Bool // <- NOVO: controle vindo de SwiftUI
        var onBarcodeScanned: (String) -> Void
        @Binding var lastScannedBounds: CGRect?
        
        var scanRect: CGRect?

        class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
            var parent: CameraPreviewView
            var session: AVCaptureSession?
            var previewLayer: AVCaptureVideoPreviewLayer?

            init(parent: CameraPreviewView) {
                self.parent = parent
            }

            func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                guard !parent.didScan, parent.scanningEnabled else { return } // <- escaneia só se permitido

                if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                   let code = object.stringValue,
                   let previewLayer = previewLayer {
                    
                    if let transformedObject = previewLayer.transformedMetadataObject(for: object){
                        DispatchQueue.main.async {
                            self.parent.lastScannedBounds = transformedObject.bounds
                        }
                    }
                    parent.didScan = true
                    parent.onBarcodeScanned(code)
                    
                }
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        func makeUIViewController(context: Context) -> UIViewController {
            let vc = UIViewController()
            let session = AVCaptureSession()
            context.coordinator.session = session

            // 1. Setup input (camera)
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                return vc
            }
            session.addInput(input)

            // 2. Setup preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = UIScreen.main.bounds
            previewLayer.videoGravity = .resizeAspectFill
            vc.view.layer.addSublayer(previewLayer)
            
            context.coordinator.previewLayer = previewLayer

            // 3. Setup output (barcode scanner)
            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
                output.metadataObjectTypes = [.ean13, .ean8, .upce, .code128]

                // ✅ 4. Apply scan area (if provided)
                if let scanRect = self.scanRect {
                    let convertedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
                    output.rectOfInterest = convertedRect
                }
            }

            // 5. Start session
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }

            return vc
        }


        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }

