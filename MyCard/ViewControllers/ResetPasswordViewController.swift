//
//  ResetPasswordViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/31.
//

import UIKit

protocol ResetPasswordProtocol: AnyObject{
    func updateNewPassword(password: String)
}

class ResetPasswordViewController: UIViewController {

    
    // MARK: - Properties
    @IBOutlet weak var newPassword1TextField: UITextField!
    @IBOutlet weak var newPassword2TextField: UITextField!
    
    weak var delegate: ResetPasswordProtocol?
    var databaseController: DatabaseProtocol?
    

    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        
        setKeyboardDismiss(view: self.view)
    }

    

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
            
            
            // 2. Proceed to update passwords 
            delegate?.updateNewPassword(password: newPassword1)
            navigationController?.popViewController(animated: true)
        }
    }
}
