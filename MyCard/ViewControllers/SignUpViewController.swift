//
//  SignUpViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit

class SignUpViewController: UIViewController, DatabaseListener {
    // MARK: - Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var givennameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .signUp
    
    
    // MARK: - On view load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get reference to the Firestore database upon the view load
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the listener
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove the listener
        databaseController?.removeListener(listener: self)
    }
    
    
    // MARK: - Database specific methods
    func didSucceedSignUp() {
        navigationController?.popViewController(animated: true)
    }
    
    func didNotSucceedSignUp() {
        displayMessage(title: "Error", message: "Sign Up failed. Try again.")
    }
    
    
    // MARK: - View specific methods
    @IBAction func didTouchSignUp(_ sender: UIButton) {
        // 1. Filter any invalid data
        guard let title = titleTextField.text,
              let surname = surnameTextField.text,
              let givenname = givennameTextField.text,
              let dob = dobTextField.text,
              let mobile = mobileTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text, password.count >= 6 else {
                  displayMessage(title: "Invalid", message: "All details must be provided.")
                  return
              }
        
        // 2. Create a new User object and try siging up
        let user = User()
        user.title = title
        user.surname = surname
        user.givenname = givenname
        user.dob = dob
        user.mobile = mobile
        user.email = email
        
        databaseController?.signUp(user: user, email: email, password: password)
    }
    
    
    // MARK: - Unnecessary inherited methods
    func didSucceedSignIn() {
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
    
}
