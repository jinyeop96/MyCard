//
//  NewCardViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit
protocol NewCardDelegate: AnyObject{
    func addCard(card: Card) -> Bool
}

class NewCardViewController: UIViewController{
    // MARK: - Properties
    @IBOutlet weak var cardTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var instagramTextField: UITextField!
    @IBOutlet weak var linkedInTextField: UITextField!
    @IBOutlet weak var gitTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var suburbTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var companyNameLabel: UILabel!
    
    var user: User?
    var delegate: NewCardDelegate?
    
    
    let BUSINESS_CARD = 0
    let PERSONAL_CARD = 1
    
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set mobile detail upon view laods
        mobileTextField.text = user?.mobile ?? ""
        
        setKeyboardDismiss(view: self.view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    
    // MARK: - View specific methods
    
    // This method is invoked when the user touches 'Create Card' button.
    // It then check whether or not all required fileds are filled.
    // If so, it assigns user's details in a Card object, otherwise it displays appropriate message to fill the empty fields.

    @IBAction func onSaveCard(_ sender: UIButton) {
        let card = Card()
        card.isPersonal = true
        
        // 1. Validate check
        guard let mobile = mobileTextField.text, !mobile.isEmpty,
              let street = streetTextField.text, !street.isEmpty,
              let suburb = suburbTextField.text, !suburb.isEmpty,
              let state = stateTextField.text, !state.isEmpty,
              let postcode = postcodeTextField.text, !postcode.isEmpty
        else {
            displayMessage(title: "Invalid", message: "Empty in some required")
            return
        }
        
        // 2. Validate check for business card
        var companyName = ""
        if cardTypeSegmentedControl.selectedSegmentIndex == BUSINESS_CARD {
            guard let company = companyTextField.text, !company.isEmpty else {
                displayMessage(title: "Invalid", message: "Empty in some required")
                return
            }
            
            companyName = company
            
            card.isPersonal = false
        }
       
        // 3. Create card object
        card.title = user?.title
        if let givenname = user?.givenname, let surname = user?.surname {
            card.name = givenname + " " + surname
        }
        card.nameLowercased = card.name?.lowercased() ?? ""
        card.address = street + ", " + suburb + ", " + state + ", " + postcode
        card.email = user?.email
        card.companyName = companyName
        card.mobile = mobile
        card.instagram = instagramTextField.text ?? ""
        card.linkedIn = linkedInTextField.text ?? ""
        card.git = gitTextField.text ?? ""
    
        // 4. Add the card
        //databaseController?.addCard(card: card)
        if let delegate = delegate, delegate.addCard(card: card) {
             navigationController?.popViewController(animated: true)
        } else {
             displayMessage(title: "Error", message: "Card creation failed. Try again.")
        }
    }
    
    @IBAction func didTouchCardTypeSegementedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == BUSINESS_CARD {
            companyNameLabel.text = "* Company Name"
        } else {
            companyNameLabel.text = "Company Name"
        }
    }
}
