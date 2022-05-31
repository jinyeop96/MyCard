//
//  UpdateDetailsViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/31.
//

import UIKit

class UpdateDetailsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var givenNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var applyForCardsSwitch: UISwitch!
    
    var databaseController: DatabaseProtocol?
    var currentUser: User?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        
        populateDetails()
        
        setKeyboardDismiss(view: self.view)
    }
    
    // MARK: - View specific methods
    private func populateDetails(){
        if let currentUser = currentUser {
            titleTextField.text = currentUser.title
            surnameTextField.text = currentUser.surname
            givenNameTextField.text = currentUser.givenname
            dobTextField.text = currentUser.dob
            mobileTextField.text = currentUser.mobile
        }
    }

    @IBAction func onSave(_ sender: UIBarButtonItem) {
        // 1. Validate all fields
        guard let title = titleTextField.text,  let surname = surnameTextField.text,
              let givenName = givenNameTextField.text, let dob = dobTextField.text,
              let mobile = mobileTextField.text else {
                  displayMessage(title: "Invalid", message: "All fields must be filled.")
                  return
              }
        
        // 2. Insert into current user
        currentUser?.title = title
        currentUser?.surname = surname
        currentUser?.givenname = givenName
        currentUser?.dob = dob
        currentUser?.mobile = mobile
        
        // 3. Update details
        if let databaseController = databaseController, let user = currentUser, databaseController.updateUser(user: user) {
            // 4. Once sucessuful, apply changes to existing card if the user wants to
            if applyForCardsSwitch.isOn, let firebaseController = databaseController as? FirebaseController {
                for card in firebaseController.userCards {
                    card.title = title
                    card.name = surname + " " + givenName
                    card.nameLowercased = card.name?.lowercased() ?? ""
                    card.mobile = mobile
                    
                    let _ = databaseController.updateCard(card: card)
                }
            }
            
            navigationController?.popViewController(animated: true)
        }
        displayMessage(title: "Error", message: "Error while updating details. Try again.")
    }
}
