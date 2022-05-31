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
        
        // Set name underneath
        if let title = card?.title, let name = card?.name, let email = card?.email {
            titleNameLabel.text = title + ". " + name
            titleNameLabel.textAlignment = .center
            
            emailLabel.text = email
            emailLabel.textAlignment = .center
            
        }
    }
    
    // This function generates a QR code using card document ID.
    // https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code
    func generateQRCode() -> UIImage? {
        if let cardId = card?.id {
            let data = cardId.data(using: String.Encoding.ascii)
            
            if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
                QRFilter.setValue(data, forKey: "inputMessage")
                
                guard let QRImage = QRFilter.outputImage else {
                    return nil
                    
                }
                
                return UIImage(ciImage: QRImage)
            }
        }
        
        return nil
    }

}
