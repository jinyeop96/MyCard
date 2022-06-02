//
//  EditViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/26.
//

import UIKit

protocol EditCardDelegate: AnyObject{
    func updateCard(card: Card)
}

class EditViewController: UIViewController{
    // MARK: - Properties
    var card: Card?
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var instagramTextField: UITextField!
    @IBOutlet weak var linkedInTextField: UITextField!
    @IBOutlet weak var gitTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var suburbTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var companyLabel: UILabel!
    
    weak var delegate: EditCardDelegate?
    var isCardPersonal = false
    var databaseController: DatabaseProtocol?
    
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the card details onto the fields
        if let card = card, let isPersonal = card.isPersonal{
            if isPersonal {
                companyLabel.text = "Company"
                isCardPersonal = true
            }
            
            
            mobileTextField.text = card.mobile ?? ""
            instagramTextField.text = card.instagram ?? "Not provided"
            linkedInTextField.text = card.linkedIn ?? "Not provided"
            gitTextField.text = card.git ?? "Not provided"
            companyTextField.text = card.companyName ?? ""
            
            // Split address into street, suburb, state and postcode
            let address = card.address?.components(separatedBy: ", ")
            if let address = address {
                streetTextField.text = address[0]
                suburbTextField.text = address[1]
                stateTextField.text = address[2]
                postcodeTextField.text = address[3]
            }
        }
        
        // Enabling keyboard dismisses when the user taps else where
        setKeyboardDismiss(view: self.view)
    }
    
    
    // MARK: - View specific methods
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        // 1. Check validation
        guard let mobile = mobileTextField.text, !mobile.isEmpty,
              let street = streetTextField.text, !street.isEmpty,
              let suburb = suburbTextField.text, !suburb.isEmpty,
              let state = stateTextField.text, !state.isEmpty,
              let postcode = postcodeTextField.text, !postcode.isEmpty
        else {
            displayMessage(title: "Invalid", message: "Empty in some required field(s).")
            return
        }
        
        // 1.1 Validation for business card
        var companyName = ""
        if !isCardPersonal {
            // 1. Validate check
            guard let company = companyTextField.text, !company.isEmpty else {
                displayMessage(title: "Invalid", message: "Empty in some required field(s).")
                return
            }
            companyName = company
        }
        
        // 2. After the validation, set them into the card again
        if let card = card {
            card.mobile = mobile
            card.instagram = instagramTextField.text ?? ""
            card.linkedIn = linkedInTextField.text ?? ""
            card.git = gitTextField.text ?? ""
            card.companyName = companyName
            card.address = street + ", " + suburb + ", " + state + ", " + postcode
        }
        
        // 3. Try updating the card
        if let databaseController = databaseController, let card = card, databaseController.updateCard(card: card) {
            delegate?.updateCard(card: card)
            navigationController?.popViewController(animated: true)
        } else {
            displayMessage(title: "Error", message: "Unable to edit the card. Please try again.")
        }
    }
}
