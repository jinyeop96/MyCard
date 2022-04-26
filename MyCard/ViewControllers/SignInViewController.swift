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
    
    let TAB_BAR_CONTROLLER_SEGUE = "tabBarControllerSegue"
    let SIGN_UP_SEGUE = "signUpSegue"
    var listenerType: ListenerType = .signIn
    var databaseController: DatabaseProtocol?
    
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get reference to the Firebase controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
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
    func didSucceedSignIn() {
        // Hide the navigation bar when entering the main
        navigationController?.navigationBar.isHidden = true
        performSegue(withIdentifier: TAB_BAR_CONTROLLER_SEGUE, sender: self)
    }
    
    func didNotSucceedSignIn() {
        displayMessage(title: "Error", message: "Sign in failed. Try again.")
    }

    // MARK: - This view specific methods
    @IBAction func onSignIn(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              password.count >= 6 else {
                  displayMessage(title: "Invalid", message: "Provided detail(s) invalid.")
                  return
              }
        
        databaseController?.signIn(email: email, password: password)
    }
    
    
    // MARK: - Unnecessary inherited methods
    func didSucceedSignUp() {
        // Do Nothing
    }
    
    func didNotSucceedSignUp() {
        // Do Nothing
    }
    
    
    func didSucceedCreateCard() {
        // Do Nothing
    }
    
    func didNotSucceedCreateCard() {
        // Do Nothing
    }

}
