//
//  ResetPasswordViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/31.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var newPassword1TextField: UITextField!
    @IBOutlet weak var newPassword2TextField: UITextField!
    
    var databaseController: DatabaseProtocol?
    

    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        
        setKeyboardDismiss(view: self.view)
    }

    
    // MARK: - View specific methods
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        if let newPassword1 = newPassword1TextField.text, let newPassword2 = newPassword2TextField.text {
            // 1. Check given passwords are the same
            if newPassword1 != newPassword2 {
                displayMessage(title: "Invalid", message: "Please check the passwords again.")
                return
            }
            
            if newPassword1.count < 6 {
                displayMessage(title: "Invalid", message: "Password must be at least 6 characters.")
                return
            }
            
            // 2. Prompt user to double check for updating the password
            let alertController = UIAlertController(title: "Update password?", message: "Are you sure for updating a new password?.", preferredStyle: .alert)
            
            // 2.1 Add cancel and ok buttons
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                // 2.2 Update a new password and return to the previous page
                if let databaseController = self.databaseController {
                    databaseController.updatePassword(password: newPassword1)
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            
            // Prompt user
            self.present(alertController, animated: true, completion: nil)

        }
    }
}
