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
    let UPDATE_DETAILS_SEGUE = "updateDetailsSegue"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get database controller
        databaseController = getDatabaseController()
        print("Menu")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    

    @IBAction func onSignOut(_ sender: Any) {
        // create the alert
        let alertController = UIAlertController(title: "Sign Out?", message: "You can always sign back in later.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.databaseController?.signOut()
        }))
        
        // Prompt user
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == RESET_PASSWORD_SEGUE{
            let destination = segue.destination as! ResetPasswordViewController
            destination.delegate = self
            destination.databaseController = databaseController
        }
        
        if segue.identifier == UPDATE_DETAILS_SEGUE {
            let destination = segue.destination as! UpdateDetailsViewController
            destination.databaseController = databaseController
            destination.currentUser = getCurrentUser(databaseController: databaseController)
        }
        
    }
    @IBAction func onDeleteAccount(_ sender: Any) {
        // create the alert
        let alertController = UIAlertController(title: "Warning", message: "Would you like to delete account? All cards will also be deleted.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.databaseController?.deleteUser()
        }))
        
        // Prompt user
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Delegation
    func updateNewPassword(password: String) {
        databaseController?.updatePassword(password: password)
    }
    
}

