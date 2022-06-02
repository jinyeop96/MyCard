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
    
    func getDatabaseController() -> DatabaseProtocol? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let databaseController = appDelegate.databaseController{
            return databaseController
        }
        return nil
    }
    
    func getCurrentUser(databaseController: DatabaseProtocol?) -> User? {
        if let firebaseController = databaseController as? FirebaseController, let currentUser = firebaseController.currentUser{
            return currentUser
        }
        return nil
    }
    
    // https://kaushalelsewhere.medium.com/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
    func setKeyboardDismiss(view: UIView){
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func setDateFormatter(dateFormatter: DateFormatter){
        // https://developer.apple.com/documentation/foundation/dateformatter
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMddyyyy")
    }
    
}
