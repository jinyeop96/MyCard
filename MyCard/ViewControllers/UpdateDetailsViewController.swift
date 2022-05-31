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
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var applyForCardsSwitch: UISwitch!
    
    let dateFormatter = DateFormatter()
    
    var databaseController: DatabaseProtocol?
    var currentUser: User?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set DateFormatter
        setDateFormatter(dateFormatter: dateFormatter)
        // Set datePicker max
        // https://stackoverflow.com/questions/10494174/minimum-and-maximum-date-in-uidatepicker
        dobPicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())

        tabBarController?.tabBar.isHidden = true
        
        populateDetails()
        
        setKeyboardDismiss(view: self.view)
    }
    
    // MARK: - View specific methods
    private func populateDetails(){
        if let currentUser = currentUser, let dob = currentUser.dob {
            titleTextField.text = currentUser.title
            surnameTextField.text = currentUser.surname
            givenNameTextField.text = currentUser.givenname
            mobileTextField.text = currentUser.mobile
            
            if let date = dateFormatter.date(from: dob) {
                dobPicker.date = date
            }
        }
    }

    @IBAction func onSave(_ sender: UIBarButtonItem) {
        // 1. Validate all fields
        guard let title = titleTextField.text,  let surname = surnameTextField.text,
              let givenName = givenNameTextField.text,
              let mobile = mobileTextField.text else {
                  displayMessage(title: "Invalid", message: "All fields must be filled.")
                  return
              }
        
        // 2. Insert into current user
        currentUser?.title = title
        currentUser?.surname = surname
        currentUser?.givenname = givenName
        currentUser?.dob = dateFormatter.string(from: dobPicker.date)
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
