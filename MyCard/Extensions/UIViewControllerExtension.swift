//
//  UIViewControllerExtension.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/06/02.
//

import Foundation
import UIKit

extension UIViewController {
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     This returns the reference to the Database Controller
     */
    func getDatabaseController() -> DatabaseProtocol? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let databaseController = appDelegate.databaseController{
            return databaseController
        }
        return nil
    }
    
    /*
     This returns the reference to the current user
     */
    func getCurrentUser(databaseController: DatabaseProtocol?) -> User? {
        if let firebaseController = databaseController as? FirebaseController, let currentUser = firebaseController.currentUser{
            return currentUser
        }
        return nil
    }
    
    /*
     This is called from the views where it needs to dismiss the keyboard after typing.
     It enables to dismiss the keyboard when user taps other than the keyboard.
     
     Dismissing the keyboard is from
     https://kaushalelsewhere.medium.com/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
     
     This is the original code.
     */
    func setKeyboardDismiss(view: UIView){
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
