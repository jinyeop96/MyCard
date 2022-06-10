//
//  SignInViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit



class SignInViewController: UIViewController, DatabaseListener {
    // MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkBoxOutlet: UIButton!

    let SIGN_UP_SEGUE = "signUpSegue"
    var listenerType: ListenerType = .signIn
    var databaseController: DatabaseProtocol?
    
    // Local storage
    let userDefaults = UserDefaults.standard
    let USER_EMAIL = "userEmail"
    let USER_PASSWORD = "userPassword"
    let REMEMBER_DETAILS = "rememberDetails"
    
    var indicator = UIActivityIndicatorView()
    
   
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get stored details from userDefaults
        emailTextField.text = userDefaults.string(forKey: "email")
        passwordTextField.text = userDefaults.string(forKey: "password")
        if userDefaults.bool(forKey: "rememberDetail") {
            checkBoxOutlet.isSelected = true
        } else {
            checkBoxOutlet.isSelected = false
        }
        
        
        // Add loading indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Get reference to the Firebase controller
        databaseController = getDatabaseController()
        
        setKeyboardDismiss(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    //MARK: - Database specific methods
    func didNotSucceedSignIn() {
        indicator.stopAnimating()
        displayMessage(title: "Sign In failed", message: "Please check email and/or password again.")
    }

    // MARK: - This view specific methods
    @IBAction func onSignIn(_ sender: UIButton) {
        // 1. Validity check
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            displayMessage(title: "Invalid", message: "Email and password must not be empty.")
            return
        }
        
        guard password.count >= 6 else {
            displayMessage(title: "Invalid", message: "Password must be at least 6 characters long.")
            return
        }
        
        // Signing in
        indicator.startAnimating()
        databaseController?.signIn(email: email, password: password, rememberDetail: checkBoxOutlet.isSelected)
    }
    
    @IBAction func checkBox(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSegue" {
            let destination = segue.destination as! UserDetailViewController
            destination.databaseController = databaseController
            destination.isSigningUp = true
        }
    }
    
    // MARK: - Unnecessary inherited methods
    func didSucceedSignUp() {
        // Do Nothing
    }
    
    func didNotSucceedSignUp() {
        // Do Nothing
    }
    
    
    func onCardsListChange(cards: [Card]) {
        //
    }
}
