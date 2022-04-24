//
//  SignInViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit

class SignInViewController: UIViewController {
    // MARK: - Properties
    let TAB_BAR_CONTROLLER_SEGUE = "tabBarControllerSegue"
    let SIGN_UP_SEGUE = "signUpSegue"

    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    
    // MARK: - Navigation
    @IBAction func onSignIn(_ sender: UIButton) {
        // Hide the navigation bar when entering the main
        navigationController?.navigationBar.isHidden = true
        performSegue(withIdentifier: TAB_BAR_CONTROLLER_SEGUE, sender: sender)
    }
    

}
