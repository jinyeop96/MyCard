//
//  NewCardViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit

class NewCardViewController: UIViewController, DatabaseListener {
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
    
    var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .newCard
    
    let BUSINESS_CARD = 0
    let PERSONAL_CARD = 1
    
    var user: User?
    

    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get reference to Firebase
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Get current user detatil
        if let databaseController = databaseController {
            self.user = (databaseController as! FirebaseController).currentUser
            mobileTextField.text = self.user?.mobile ?? ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - View specific methods
    
    // This method is invoked when the user touches 'Create Card' button.
    // It then check whether or not all required fileds are filled.
    // If so, it assigns user's details in a Card object, otherwise it displays appropriate message to fill the empty fields.
    @IBAction func didTouchCreateCard(_ sender: UIButton) {
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
        databaseController?.addCard(card: card)
    }
    
    @IBAction func didTouchCardTypeSegementedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == BUSINESS_CARD {
            companyNameLabel.text = "* Company Name"
        } else {
            companyNameLabel.text = "Company Name"
        }
    }
    
    
    // MARK: - Database specific methods
    func didSucceedCreateCard() {
        navigationController?.popViewController(animated: true)
    }
    
    func didNotSucceedCreateCard() {
        displayMessage(title: "Error", message: "Card creation failed. Try again.")
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
