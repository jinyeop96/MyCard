//
//  UIViewController+getReferences.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/31.
//

import Foundation
import UIKit

extension UIViewController {
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
    
    func getCardById(databaseController: DatabaseProtocol?, cardId: String) -> Card? {
        if let firebaseController = databaseController as? FirebaseController {
            return firebaseController.getCardById(id: cardId)
        }
        return nil
    }
    
}
