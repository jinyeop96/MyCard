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
    var listenerType: ListenerType = .cardDetail
    var databaseController: DatabaseProtocol?
    let MAP_SEGUE = "mapSegue"
    let QR_CODE_GENERATION_SEGUE = "qrCodeGenerationSegue"
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var titleDetailLabel: UILabel!
    @IBOutlet weak var nameDetailLabel: UILabel!
    @IBOutlet weak var companyDetailLabel: UILabel!
    @IBOutlet weak var departmentDetailLabel: UILabel!
    @IBOutlet weak var addressDetailLabel: UILabel!
    @IBOutlet weak var mobileDetailLabel: UILabel!
    @IBOutlet weak var emailDetailLabel: UILabel!
    @IBOutlet weak var generateQRButton: UIButton!
    

    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        if !isEditable {
            navigationItem.rightBarButtonItem = nil
            generateQRButton.isHidden = true
        }
        
        // Set user details
        if let card = card {
            titleDetailLabel.text = card.title ?? ""
            nameDetailLabel.text = card.name ?? ""
            companyDetailLabel.text = card.companyName ?? ""
            departmentDetailLabel.text = card.department ?? ""
            addressDetailLabel.text = card.address ?? ""
            mobileDetailLabel.text = card.mobile ?? ""
            emailDetailLabel.text = card.email ?? ""
        }
        
        // Let adderss detail touchable
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardDetailViewController.tapFunction))
        addressDetailLabel.isUserInteractionEnabled = true
        addressDetailLabel.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        isEditable = false;
    }

    
    //MARK: - This view specific methods
    @IBAction func didTouchGenerateQRButton(_ sender: Any) {
    }
    
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: MAP_SEGUE, sender: self)
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
    
}
