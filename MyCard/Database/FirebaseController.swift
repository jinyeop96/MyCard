//
//  FirebaseController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/26.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseController: NSObject, DatabaseProtocol {

    
    // MARK: - Properties
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var authController: Auth
    var database: Firestore
    
    var currentUser: User?
    var usersRef: CollectionReference?
    var cardsRef: CollectionReference?
    
    
    
    override init(){
        FirebaseApp.configure() // must first call the configure method of FirebaseApp
        authController = Auth.auth()
        database = Firestore.firestore()
        
        super.init()
        
        // References to users and team collections are required for the siging up process.
        // Signing up will immediately proceed to adding user details to the database.
        usersRef = database.collection("users")
        cardsRef = database.collection("cards")
    }
    
    // MARK: - DatabaseProtocol specific methods
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // MARK: - Authentication
    func signUp(user: User, email: String, password: String) {
        <#code#>
    }
    
    func signIn(email: String, password: String) {
        <#code#>
    }
    
    func logOut() {
        <#code#>
    }
    
    func addCard(card: Card) {
        <#code#>
    }
    
    func deleteUser(user: User) {
        //
    }

}
