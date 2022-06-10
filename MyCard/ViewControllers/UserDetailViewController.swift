//
//  UserDetailViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/06/02.
//

import UIKit

class UserDetailViewController: UIViewController, DatabaseListener {
    
    // MARK: - Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var givennameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    let dateFormatter = DateFormatter()
    
    var currentUser: User?
    var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .signUp
    var isSigningUp = false
    
    var indicator = UIActivityIndicatorView()
    
    // MARK: - On view load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // It sets the DateFormatter object for British date style
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMddyyyy")
        
    
        // Add loading indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])

        //Since the date picker is used for setting birthday, it sets the UIDatePicker max as today.
        dobPicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        
        setKeyboardDismiss(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If this view appears for signing up, it should enable entering email and password
        if isSigningUp {
            navigationItem.title = "Sign Up"
            
            // Set the listener
            databaseController?.addListener(listener: self)
            
        }
        
        if !isSigningUp { // Editing user detail
            navigationItem.title = "Update Details"
            
            // If it is for editing user detail, hide email and password part
            emailLabel.isHidden = true
            emailTextField.isHidden = true
            passwordLabel.isHidden = true
            passwordTextField.isHidden = true
            
            // populate user's detail
            if let currentUser = currentUser, let dob = currentUser.dob {
                titleTextField.text = currentUser.title
                surnameTextField.text = currentUser.surname
                givennameTextField.text = currentUser.givenname
                mobileTextField.text = currentUser.mobile
                
                if let date = dateFormatter.date(from: dob) {
                    dobPicker.date = date
                }
            }
        }
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove the listener if sigining up
        if isSigningUp {
            databaseController?.removeListener(listener: self)
        }

    }
    
    
    // MARK: - Database specific methods
    // This is invoked when the user successfully created a new account to be navigated Sign In view.
    func didSucceedSignUp() {
        navigationController?.popViewController(animated: true)
    }
    
    // This is invoked when the user failed to created a new account, it will display a message.
    func didNotSucceedSignUp() {
        indicator.stopAnimating()
        displayMessage(title: "Error", message: "Sign Up failed. Try again.")
    }
    
    
    // MARK: - View specific methods
    // This will be called when the uesr touches Save button, it then checks whether all required fields are provided up.
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        // 1. Filter any invalid data
        guard let title = titleTextField.text, let surname = surnameTextField.text,
              let givenname = givennameTextField.text, let mobile = mobileTextField.text else {
                  displayMessage(title: "Invalid", message: "All details must be provided.")
                  return
              }
        
        if isSigningUp {
            guard let email = emailTextField.text, let password = passwordTextField.text, password.count >= 6 else {
                displayMessage(title: "Invalid", message: "All details must be provided.")
                return
            }
            
            // 2. Create a new User object and try siging up
            let user = User()
            user.title = title
            user.surname = surname
            user.givenname = givenname
            user.dob = dateFormatter.string(from: dobPicker.date)
            user.mobile = mobile
            user.email = email
            
            indicator.startAnimating()
            
            databaseController?.signUp(user: user, email: email, password: password)
        }
        
        if !isSigningUp { // Update user's detail
            // 2. Insert into current user
            currentUser?.title = title
            currentUser?.surname = surname
            currentUser?.givenname = givenname
            currentUser?.dob = dateFormatter.string(from: dobPicker.date)
            currentUser?.mobile = mobile
            
            // 3. Create alter controller
            let alertController = UIAlertController(title: "Apply for all cards?", message: "Do you want to update for all existing cards?", preferredStyle: .alert)
            
            // 3.1 Button for altering user and all existing cards
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                // 3.1.1 Update details
                if let databaseController = self.databaseController, let user = self.currentUser, databaseController.updateUser(user: user) {
                    
                    // 3.3. Once sucessuful, apply changes to existing cards
                    if let firebaseController = databaseController as? FirebaseController {
                        for card in firebaseController.userCards {
                            card.title = title
                            card.name = givenname + " " + surname
                            card.nameLowercased = card.name?.lowercased() ?? ""
                            card.mobile = mobile
                            
                            let _ = databaseController.updateCard(card: card)
                        }
                    }
                    // 3.1.2 pop view if all sucessful
                    self.navigationController?.popViewController(animated: true)
                }
                
                // alert an error occurred
                self.displayMessage(title: "Error", message: "Error while updating details. Try again.")
            }))
            
            // 3.2 Button for altering current user's detail only
            alertController.addAction(UIAlertAction(title: "Only for my details", style: .default, handler: {_ in
                
                if let currentUser = self.currentUser, let databaseController = self.databaseController, databaseController.updateUser(user: currentUser) {
                    
                    // 3.2.1 Pop view if sucessful
                    self.navigationController?.popViewController(animated: true)
                }
                self.displayMessage(title: "Error", message: "Error while updating details. Try again.")
            }))
            
            // 3.3 Cancel button
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            // Prompt user
            self.present(alertController, animated: true, completion: nil)

        }
    }
    
    
    // MARK: - Unnecessary inherited methods
    func didNotSucceedSignIn() {
        // Do Nothing
    }
    
    func onCardsListChange(cards: [Card]) {
        //
    }
}
