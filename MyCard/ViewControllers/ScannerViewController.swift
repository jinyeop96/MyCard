//
//  ScannerViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/03.
//

import UIKit
import AVFoundation


class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, DatabaseListener {
    // MARK: - Properties
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var listenerType: ListenerType = .scanner
    var databaseController: DatabaseProtocol?

    // MARK: - On View loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // begin detecting QR codes
        beginQRScanning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    // MARK: - View specific methods
    private func beginQRScanning(){
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            // If no camera detected, display a message and navigate to the previous view
            displayMessage(title: "Error", message: "No camera detected on device")
            navigationController?.popViewController(animated: true)
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession.startRunning()
            
            qrCodeFrameView = UIView()

            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 5
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            print("No QR code is detected")
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            // Attemp to any into contact
            if let scannedData = metadataObj.stringValue {
                // 1. First check if scanned data exitst in database
                if let firebaseController = databaseController as? FirebaseController {
                    if let scannedCard = firebaseController.getCardById(id: scannedData) {
                        // 2. If so, add it to the contact
                        databaseController?.addToContact(card: scannedCard)
                        
                        // 3. Then navigate back to the previous view
                        navigationController?.popViewController(animated: true)
                    } else {
                        displayMessage(title: "Error", message: "No cards found in database. Please try again.")
                    }
                }
            }
        }
    }
    
    
    // MARK: - Unnecessary inherited methods
    func didSucceedSignUp() {
        // Do nothing
    }
    
    func didSucceedSignIn() {
        // Do nothing
    }
    
    func didNotSucceedSignUp() {
        // Do nothing
    }
    
    func didNotSucceedSignIn() {
        // Do nothing
    }
    
    func didSucceedCreateCard() {
        // Do nothing
    }
    
    func didNotSucceedCreateCard() {
        // Do nothing
    }
    
    func didSearchCards(cards: [Card]) {
        // Do nothing
    }
    
    func onUserCardsChanges(change: ListenerType, userCards: [Card]) {
        // Do nothing
    }
    
    func onContactCardsChange(change: ListenerType, contactCards: [Card]) {
        // Do nothing
    }



}
