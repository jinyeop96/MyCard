//
//  MenuViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/27.
//

import UIKit

class MenuViewController: UIViewController, ResetPasswordProtocol {
    // MARK: - Properties
    var databaseController: DatabaseProtocol?
    
    let RESET_PASSWORD_SEGUE = "resetPasswordSegue"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get database controller
        databaseController = getDatabaseController()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    

    @IBAction func onSignOut(_ sender: Any) {
        databaseController?.signOut()
        if let signInViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            present(signInViewController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == RESET_PASSWORD_SEGUE{
            let destination = segue.destination as! ResetPasswordViewController
            destination.delegate = self
            destination.databaseController = databaseController
        }
    }
    
    // MARK: - Delegation
    func updateNewPassword(password: String) {
        databaseController?.updatePassword(password: password)
    }
    
}

