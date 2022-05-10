//
//  CardDetailViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/27.
//

import UIKit

class CardDetailViewController: UIViewController, DatabaseListener {
    // MARK: - Properties
    var card: Card?
    var isEditable = false; // set true segued from 'My' Section only
    var isAddable = false;
    var listenerType: ListenerType = .cardDetail
    var databaseController: DatabaseProtocol?
    let MAP_SEGUE = "mapSegue"
    let QR_CODE_GENERATION_SEGUE = "qrCodeGenerationSegue"
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var departmentNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Accessed from owner
        if isEditable {
            
            optionButton.setTitle("Generate QR Code", for: .normal)
        }
        
        // Accessed from others but searching
        if isAddable {
            optionButton.setTitle("Add to Contact", for: .normal)
            navigationItem.rightBarButtonItem = nil
        }
        
        // Accessed from others
        if !isEditable && !isAddable {
            optionButton.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
        
        // Set user details
        if let card = card, let title = card.title, let name = card.name{
            titleNameLabel.text = title + ". " + name
            companyNameLabel.text = card.companyName ?? ""
            departmentNameLabel.text = card.department ?? ""
            addressLabel.text = card.address ?? ""
            emailLabel.text = card.email ?? ""
            mobileLabel.text = card.mobile ?? ""
            
        }
        
        // Let adderss and company name detail touchable
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardDetailViewController.tapFunction))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(tap)
        
//        companyNameLabel.isUserInteractionEnabled = true
//        companyNameLabel.addGestureRecognizer(tap)
        
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

    
    //MARK: - This view specific methods
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: MAP_SEGUE, sender: self)
    }
    
    @IBAction func didTouchOptionButton(_ sender: Any) {
        // editable means the user is viewing the card, so it can generate the QR code
        if isEditable {
            performSegue(withIdentifier: QR_CODE_GENERATION_SEGUE, sender: self)
        }
        
        if isAddable, let card = card{
            databaseController?.addToContact(card: card)
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MAP_SEGUE {
            let destination = segue.destination as! MapViewController
            destination.card = self.card
        }
        
        if segue.identifier == QR_CODE_GENERATION_SEGUE {
            let destination = segue.destination as! QRCodoGenerationViewController
            destination.card = self.card
        }
        
    }
    

    // MARK: - Unnecessary inherited methods
    func didSucceedSignUp() {
        // Do Nothing
    }
    
    func didSucceedSignIn() {
        // Do Nothing
    }
    
    func didNotSucceedSignUp() {
        // Do Nothing
    }
    
    func didNotSucceedSignIn() {
        // Do Nothing
    }
    
    func didSucceedCreateCard() {
        // Do Nothing
    }
    
    func didNotSucceedCreateCard() {
        // Do Nothing
    }
    
    func onUserCardsChanges(change: ListenerType, userCards: [Card]) {
        // Do Nothing
    }
    func didSearchCards(cards: [Card]) {
        // Do Nothing
    }
    func onContactCardsChange(change: ListenerType, contactCards: [Card]) {
        // Do Nothing
    }

}
