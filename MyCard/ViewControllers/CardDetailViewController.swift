//
//  CardDetailViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/27.
//

import UIKit

class CardDetailViewController: UIViewController, EditCardDelegate {
    // MARK: - Properties
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var instagramLabel: UILabel!
    @IBOutlet weak var linkedInLabel: UILabel!
    @IBOutlet weak var gitHubLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    let MAP_SEGUE = "mapSegue"
    let QR_CODE_GENERATION_SEGUE = "qrCodeGenerationSegue"
    let COMPANY_DETAIL_SEGUE = "companyDetailSegue"
    let EDIT_SEGUE = "editSegue"
    
    var card: Card?
    var databaseController: DatabaseProtocol?
    
    var isEditable = false; // set true if segued from 'My' Section only
    var isAddable = false;  // set true if segued from 'Searching' Section only
 
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Restructure the page depending on where it navigated from.
        // 1.1 Navigated from 'My' tab
        if isEditable {
            optionButton.setTitle("Generate QR Code", for: .normal)
        }
        
        // 1.1 Navigated from 'Search' tab
        if isAddable {
            optionButton.setTitle("Add to Contact", for: .normal)
            navigationItem.rightBarButtonItem = nil
        }
        
        // 1.1 Navigated from 'Contact' tab
        if !isEditable && !isAddable {
            optionButton.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
        
        // 2. Populate card details where appropriate
        setCardDetails()
        
        /*
         3. Enable the adderss and company details touchable
         
         Enabling UILabel touchable is based on
         https://stackoverflow.com/questions/33658521/how-to-make-a-uilabel-clickable
         
         The examples in the source code provides how to implement UILabel touchable.
         I simply modified to have my own functions and enabled to addressLabel and companyNameLabel.
         */
        let toMap = UITapGestureRecognizer(target: self, action: #selector(segueToMap))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(toMap)
        
        let toCompanyInfo = UITapGestureRecognizer(target: self, action: #selector(segueToCompanyInfo))
        companyNameLabel.isUserInteractionEnabled = true
        companyNameLabel.addGestureRecognizer(toCompanyInfo)
        
        // 4. Hide tab below
        tabBarController?.tabBar.isHidden = true
    }
    
    
    //MARK: - This view specific methods
    /*
     This is based on
     https://stackoverflow.com/questions/33658521/how-to-make-a-uilabel-clickable
     */
    @objc func segueToMap(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: MAP_SEGUE, sender: self)
    }
    
    /*
     This is based on
     https://stackoverflow.com/questions/33658521/how-to-make-a-uilabel-clickable
     */
    @objc func segueToCompanyInfo(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: COMPANY_DETAIL_SEGUE, sender: self)
    }
    
    /*
     Depending on where it was navigated from, the optionButton performs different operation.
     If it is from 'My' tab, it navigates to QR generation page.
     else if is from 'Search' tab, it performs adding self.card into the contact list.
     */
    @IBAction func didTouchOptionButton(_ sender: Any) {
        // If navigated from 'My' tab
        if isEditable {
            performSegue(withIdentifier: QR_CODE_GENERATION_SEGUE, sender: self)
        } else {
            // Attempt adding this card to contact list.
            // Pop this view controller if it is successful, otherwise display appropriate message
            if let card = card, let databaseController = databaseController, databaseController.addToContact(card: card) {
                navigationController?.popViewController(animated: true)
            } else {
                displayMessage(title: "Failed adding card", message: "Fail to add the card to contact list. Try again.")
            }
        }
    }
    
    private func setCardDetails(){
        if let card = card, let title = card.title, let name = card.name{
            titleNameLabel.text = title + ". " + name
            companyNameLabel.text = card.companyName ?? ""
            addressLabel.text = card.address ?? ""
            emailLabel.text = card.email ?? ""
            mobileLabel.text = card.mobile ?? ""
            instagramLabel.text = card.instagram ?? "Not provided"
            linkedInLabel.text = card.linkedIn ?? "Not provided"
            gitHubLabel.text = card.git ?? "Not provided"
            
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
        
        if segue.identifier == COMPANY_DETAIL_SEGUE {
            let destination = segue.destination as! DetailTableViewController
            destination.card = self.card
            destination.displayCompanyDetails = true
        }
        
        if segue.identifier == EDIT_SEGUE {
            let destination = segue.destination as! EditViewController
            destination.card = self.card
            destination.databaseController = databaseController
            destination.delegate = self
        }
    }
    
    // MARK: - Delegation
    /*
     This is invoked when the user sucessfully edits the card. The updated card will be passed and populated again.
     */
    func updateCard(card: Card) {
        self.card = card
        setCardDetails()
    }
}
