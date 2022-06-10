//
//  QRCodoGenerationViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/03.
//

import UIKit

class QRCodoGenerationViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    var card: Card?
    

    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set QR code
        qrCodeImageView.image = generateQRCode()
        
        // Set labels below
        if let title = card?.title, let name = card?.name, let email = card?.email {
            titleNameLabel.text = title + ". " + name
            titleNameLabel.textAlignment = .center
            
            emailLabel.text = email
            emailLabel.textAlignment = .center
            
        }
    }
    
    /*
     This function incodes DocumentID of the card and generates a QR code.
     It returns the QR code image as UIImage to set on qrCodeImageView.
     
     QR Code generation is based on
     https://medium.com/codex/qr-codes-are-simple-in-swift-6d203ebc3f5b
     
     I have modified incoding data to be the DocumentID of the self.card.
     I have added codes for displaying error message if it does not properly generate QR code.
     */
    func generateQRCode() -> UIImage? {
        if let cardId = card?.id {
            let data = cardId.data(using: String.Encoding.ascii)
            
            if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
                QRFilter.setValue(data, forKey: "inputMessage")
                
                guard let QRImage = QRFilter.outputImage else {
                    displayMessage(title: "Error", message: "Unable to generate a QR code. Try again.")
                    return nil
                    
                }
                
                return UIImage(ciImage: QRImage)
            }
        }
        
        displayMessage(title: "Error", message: "Unable to generate a QR code. Try again.")
        return nil
    }

}
