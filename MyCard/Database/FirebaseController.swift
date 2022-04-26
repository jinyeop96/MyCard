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
        Task{
            do {
                // 1. Try creating a new account
                let authResut = try await authController.createUser(withEmail: email, password: password)
                
                // 2. Create a new user and add a new document
                let user = User()
                user.uid = authResut.user.uid
                
                let _ = try usersRef?.addDocument(from: user)
                
                
                await MainActor.run{
                    alertListener(listenerType: .signUp, successful: true)
                }
                
            } catch {
                await MainActor.run{
                    alertListener(listenerType: .signUp, successful: false)
                }
                
            } // do-catch ends
            
        } // Task ends
    }
    
    func signIn(email: String, password: String) {
        Task {
            do {
                // 1. Try siging in with email and password
                let _ = try await authController.signIn(withEmail: email, password: password)
                
                // 2. Access to the user document with provided email and set currentUser
                setUpUserListener(email: email)
                
                // 3. Alert listener
                await MainActor.run {
                    alertListener(listenerType: .signIn, successful: true)
                }
            } catch {
                await MainActor.run {
                    alertListener(listenerType: .signIn, successful: false)
                }
                print("Error : \(error)" )
                
            } // do-catch ends
        } // Task ends
    }
    
    func logOut() {
        //
    }
    
    
    // MARK: - Documents sources methods
    func addCard(card: Card) {
        do {
            let _ = try cardsRef?.addDocument(from: card)
            
            alertListener(listenerType: .newCard, successful: true)
        } catch {
            alertListener(listenerType: .newCard, successful: false)
        } // do-catch ends
    }
    
    func deleteUser(user: User) {
        //
    }
    
    
    // MARK: - FirebaseController specific methods
    private func alertListener(listenerType: ListenerType, successful: Bool){
        listeners.invoke { (listener) in
            if listenerType == .signUp && successful == true {
                listener.didSucceedSignUp()
            }
            
            if listenerType == .signUp && successful == false {
                listener.didNotSucceedSignUp()
            }
            
            if listenerType == .signIn && successful == true {
                listener.didSucceedSignIn()
            }
            
            if listenerType == .signIn && successful == false {
                listener.didNotSucceedSignIn()
            }
            
            if listenerType == .newCard && successful == true {
                listener.didSucceedCreateCard()
            }
            
            if listenerType == .newCard && successful == false {
                listener.didNotSucceedCreateCard()
            }
        }
    }
    
    private func setUpUserListener(email: String){
        usersRef?.whereField("email", isEqualTo: email).addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first, error == nil else {
                print("Error fetching teams: \(error!)")
                return
            }
            
            self.currentUser = User()
            
            self.currentUser?.id = userSnapshot.data()["id"] as? String ?? ""
            self.currentUser?.title = userSnapshot.data()["title"] as? String ?? ""
            self.currentUser?.surname = userSnapshot.data()["surname"] as? String ?? ""
            self.currentUser?.givenname = userSnapshot.data()["givenname"] as? String ?? ""
            self.currentUser?.nickname = userSnapshot.data()["nickname"] as? String ?? ""
            self.currentUser?.dob = userSnapshot.data()["dob"] as? String ?? ""
            self.currentUser?.mobile = userSnapshot.data()["mobile"] as? String ?? ""
            self.currentUser?.email = userSnapshot.data()["email"] as? String ?? ""
            self.currentUser?.uid = userSnapshot.data()["uid"] as? String ?? ""
        }
    }
}
