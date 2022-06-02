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
    
    var currentUser: User?  // Holidng signed-in user's details inclduing documentIDs of 'contacts' and 'individualCards' collection
    var usersRef: CollectionReference?  // Reference to the 'users' collection
    var contactsRef: CollectionReference?   // Holding document references to other users' cards
    var individualCardsRef: CollectionReference?  // Holding document references to current user's card
    var cardsRef: CollectionReference?  // Reference to the 'cards' collection
    
    var userCards: [Card]
    var contactsCards: [Card]
    var allCards: [Card]
    
    
    override init(){
        FirebaseApp.configure() // must first call the configure method of FirebaseApp
        authController = Auth.auth()
        database = Firestore.firestore()
        userCards = [Card]()
        allCards = [Card]()
        contactsCards = [Card]()
        
        super.init()
        
        // References to users and team collections are required for the siging up process.
        // Signing up will immediately proceed to adding user details to the database.
        usersRef = database.collection("users")
        cardsRef = database.collection("cards")
        contactsRef = database.collection("contacts")
        individualCardsRef = database.collection("individualCards")
    }
    
    // MARK: - DatabaseProtocol specific methods
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .my {
            alertListener(listenerType: .my, successful: true)
        }
        
        if listener.listenerType == .contacts {
            alertListener(listenerType: .contacts, successful: true)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // MARK: - Authentication
    // This function attempts to create a new account with input email and password, then it creates documents in 'users', 'contacts' and 'individualCards' collections.
    func signUp(user: User, email: String, password: String){
        Task{
            do {
                // 1. Try creating a new account
                let authResut = try await authController.createUser(withEmail: email, password: password)

                // 2. Try creating a new contact document for this user
                let contact = Contact()
                let contactRef = try contactsRef?.addDocument(from: contact)

                // 3.Try creating a new userCard document for this user
                let individualCard = Individual()
                let individualCardRef = try individualCardsRef?.addDocument(from: individualCard)

                // 4. Add additional details, then create a document
                user.uid = authResut.user.uid
                user.contactId = contactRef?.documentID
                user.individualCardId = individualCardRef?.documentID

                let _ = try usersRef?.addDocument(from: user)
                
                await MainActor.run {
                    alertListener(listenerType: .signUp, successful: true)
                }

            } catch {
                await MainActor.run {
                    alertListener(listenerType: .signUp, successful: false)
                }
            } // do-catch ends
        } // Task ends
    }
    
    // This fuction attempts to sign in with input email and password.
    func signIn(email: String, password: String) {
        Task {
            do {
                // 1. Try siging in with email and password
                let _ = try await authController.signIn(withEmail: email, password: password)
                
                // 2. Access to the user document with provided email and set currentUser
                setUpUserListener(email: email)
                
                // 3. After Signing in is successful, switch the root view controller to the MainTabBarController
                self.switchRootViewController(identifier: "MainTabBarController")
                
            } catch {
                await MainActor.run {
                    alertListener(listenerType: .signIn, successful: false)
                }
            } // do-catch ends
        } // Task ends
    }
    
    func signOut() {
        
        Task {
            do {
                // 1. Try Sign out
                try authController.signOut()
                
                // 2. Remove all cards
                allCards.removeAll()
                userCards.removeAll()
                contactsCards.removeAll()
               
                // 3. Switch root view controller to Sign In Controller
                self.switchRootViewController(identifier: "SignInNavigationController")
                
            } catch  {
                print("Error signing out: \(error)")
            }
        }
        
    }
    
    // It deletes all individual cards first, and from users collection.
    // It then deletes from Google authentication
    func deleteUser() {
        // 1. Remove all user's cards
        for card in userCards {
            removeCard(card: card)
        }

        if let individualCardId = currentUser?.individualCardId, let contactId = currentUser?.contactId, let userId = currentUser?.id {
            // 2. Remove individual card document
            individualCardsRef?.document(individualCardId).delete()
            
            // 3. Remove contact document
            contactsRef?.document(contactId).delete()
            
            // 4. Remove user detail document
            usersRef?.document(userId).delete()
        }

        // 5. Delete user authentication
        authController.currentUser?.delete(completion: { error in
            if let error = error {
                print(error)
            } else {
                print("deleted")
            }
        })

        // 6. Back to Sign In page
        switchRootViewController(identifier: "SignInNavigationController")
    }
    
    func updateUser(user: User) -> Bool {
        if let userId = user.id, let userRef = usersRef?.document(userId) {
            userRef.updateData(["title": user.title ?? ""])
            userRef.updateData(["surname": user.surname ?? ""])
            userRef.updateData(["givenname": user.givenname ?? ""])
            userRef.updateData(["dob": user.dob ?? ""])
            userRef.updateData(["mobile": user.mobile ?? ""])
            
            return true
        }
        
        return false
    }
    
    func updatePassword(password: String) {
        authController.currentUser?.updatePassword(to: password) {error in
            return
        }
    }
    
    
    
    // MARK: - Documents sources methods
    // This function is called only by current user for adding a new card.
    // This create a new document in 'cards' collection, then the new document ID is stored in user's indivisual card list.
    func addCard(card: Card) -> Bool{
        do {
            // 1. Add a new document in 'cards' collection
            let newCardRef = try cardsRef?.addDocument(from: card)
            
            // 2. Add reference to the new document to user's individual card list
            if let individualCardId = currentUser?.individualCardId, let individualCardList = individualCardsRef?.document(individualCardId), let newCardRef = newCardRef {
                individualCardList.updateData(["individualCardIds" : FieldValue.arrayUnion([newCardRef])])
            }
            
            //alertListener(listenerType: .newCard, successful: true)
            return true
        } catch {
            //alertListener(listenerType: .newCard, successful: false)
            return false
        } // do-catch ends
    }
    
    // This function removes the card ID from all referencing contact lists, owner's indivisual card list and the card itself
    func removeCard(card: Card) {
        if let cardId = card.id, let individualCardsId = currentUser?.individualCardId, let removingCardRef = cardsRef?.document(cardId) {
            Task {
                do {
                    // 1. Remove card ID from all referencing contact lists
                    for referencingList in card.referencedBy {
                        try await referencingList.updateData(["contactCardIds" : FieldValue.arrayRemove([removingCardRef])])
                    }
                    
                    // 2. Remove the card itself from 'cards' collection
                    try await removingCardRef.delete()

                    // 3. Remove the card ID from the owner's individual card list
                    try await individualCardsRef?.document(individualCardsId).updateData(["individualCardIds" : FieldValue.arrayRemove([removingCardRef])])
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func updateCard(card: Card) -> Bool {
        if let cardId = card.id, let cardRef = cardsRef?.document(cardId){
            cardRef.updateData(["mobile": card.mobile ?? ""])
            cardRef.updateData(["instagram": card.instagram ?? ""])
            cardRef.updateData(["git": card.git ?? ""])
            cardRef.updateData(["companyName": card.companyName ?? ""])
            cardRef.updateData(["address": card.address ?? ""])
            cardRef.updateData(["name": card.name ?? ""])
            cardRef.updateData(["nameLowercased": card.nameLowercased ?? ""])
            cardRef.updateData(["title": card.title ?? ""])
            
                
            return true
        }
        return false
    }
    
    func searchCards(searchText: String) -> [Card]{
        var filteredCards: [Card] = []
        
        // Filter out searched cards out of allCards list
        filteredCards = allCards.filter( { card in
            return card.nameLowercased?.contains(searchText) ?? false && card.email != currentUser?.email
        })
        
        return filteredCards
    }
    
    // This function adds the input card ID to user's contact list
    func addToContact(card: Card) -> Bool {
        // 1. Check given card exists in collection
        if let cardId = card.id, let cardRef = cardsRef?.document(cardId), let contactId = currentUser?.contactId, let userContactList = contactsRef?.document(contactId) {
            
            // 2. Add to current user's contact list
            userContactList.updateData(["contactCardIds" : FieldValue.arrayUnion([cardRef])])
            
            // 3. Set this user as referenced user to the card
            cardRef.updateData(["referencedBy" : FieldValue.arrayUnion([userContactList])])
            
            return true
        }
        
        return false
    }
    
    // This function removes card ID from user's contact list
    func removeFromContact(card: Card) {
        // 1. check if the input card exists
        if let cardId = card.id, let contactId = currentUser?.contactId, let cardRef = cardsRef?.document(cardId), let userContactList = contactsRef?.document(contactId) {
            // 2.  remove the card ID from user's contact list.
            userContactList.updateData(["contactCardIds" : FieldValue.arrayRemove([cardRef])])
        }
    }
    
    func switchRootViewController(identifier: String) {
        // Switch root view controller between Sign In page and Main pages
        // https://fluffy.es/how-to-transition-from-login-screen-to-tab-bar-controller/
        Task {
            let storyboard = await UIStoryboard(name: "Main", bundle: nil)
            let switchingNavigationController = await storyboard.instantiateViewController(identifier: identifier)
            
            await (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(switchingNavigationController)
        }
    }
    
    
    // MARK: - FirebaseController specific methods
    // This delivers the appropriate signs to the corresponding listeners
    private func alertListener(listenerType: ListenerType, successful: Bool){
        listeners.invoke { (listener) in
            if listenerType == .signUp && successful {
                listener.didSucceedSignUp()
            }
            
            if listenerType == .signUp && !successful {
                listener.didNotSucceedSignUp()
            }
            
            if listenerType == .signIn && !successful{
                listener.didNotSucceedSignIn()
            }

            if listenerType == .my && successful{
                listener.onCardsListChange(cards: userCards)
            }
            
            if listenerType == .contacts && successful{
                listener.onCardsListChange(cards: contactsCards)
            }
        }
    }
    
    private func setUpUserListener(email: String) {
        usersRef?.whereField("email", isEqualTo: email).addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first, error == nil else {
                if let error = error {
                    print("Error fetching teams: \(error)")
                }
                return
            }
            
            // Parse user snapshot
            self.currentUser = User()
            do {
                // 1. Set it as current user
                self.currentUser = try userSnapshot.data(as: User.self)
                
                // 2. retrieve all cards, contact cards, personal cards
                self.setUpCardsListener()
                self.setUpContactsListener()
                self.setUpIndividualCardsListener()
                
            } catch {
                print(error)
            }
        }
    }
    
    private func setUpCardsListener() {
        // Retrieves all card documents
        cardsRef?.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }

            self.parseCardsSnapshot(snapshot: querySnapshot)
        }
        
    }
    
    private func parseCardsSnapshot(snapshot: QuerySnapshot){
        var parsedCard: Card?
      
        snapshot.documentChanges.forEach{ (change) in
            // 1. For each document, parse into card object
            do {
                parsedCard = try change.document.data(as: Card.self)
            } catch {
                print("Error : \(error)")
                return
            }

            guard let card = parsedCard else {
                print("card does not exist")
                return
            }
            
            // Assign cards into allCards
            if change.type == .added {
                //allCards.insert(card, at: Int(change.newIndex))
                allCards.append(card)
            } else if change.type == .modified {
                allCards[Int(change.oldIndex)] = card
            } else if change.type == .removed {
                allCards.remove(at: Int(change.oldIndex))
            }
        } // forEach ends

        //self.alertListener(listenerType: .my, successful: true)
    }
    
    private func setUpContactsListener(){
        if let contactId = currentUser?.contactId{
            // 1. Add snapshot listener to curent user's contact list
            contactsRef?.document(contactId).addSnapshotListener{ documentSnapshot, error in
                guard let contactsSnapshot = documentSnapshot, error == nil else {
                    print("Failed to fetch documents with error: \(String(describing: error))")
                    return
                }
                
                
                // 2. If no error made, append corresponding cards
                self.contactsCards.removeAll()

                if let contacts = contactsSnapshot.data()?["contactCardIds"] as? [DocumentReference]{
                    for contact in contacts {
                        if let card = self.getCardById(id: contact.documentID) {
                            self.contactsCards.append(card)
                        }
                    }
                }
                self.alertListener(listenerType: .contacts, successful: true)
            }
        }
    }

    private func setUpIndividualCardsListener(){
        
        if let individualCardId = currentUser?.individualCardId{
            // 1. Get reference to user's individual cards list,
            individualCardsRef?.document(individualCardId).addSnapshotListener{ documentSnapshot, error in
                guard let individualCardsSnapshot = documentSnapshot, error == nil else {
                    print("Failed to fetch documents with error: \(String(describing: error))")
                    return
                }
                
                // 2. If no error, get corresponding cards
                self.userCards.removeAll()

                if let cards = individualCardsSnapshot.data()?["individualCardIds"] as? [DocumentReference] {
                    for card in cards {
                        if let indiCard = self.getCardById(id: card.documentID) {
                            self.userCards.append(indiCard)
                        }
                    }
                }

                // 3. alert changes have been made
                self.alertListener(listenerType: .my, successful: true)
            } // addSnapshotListener ends
        } // if-let ends
    }
    
    // This checks whether given card id exists
    // If so, it returns the card object, else nil
    func getCardById(id: String) -> Card?{
        for card in allCards {
            if let cardId = card.id, cardId == id{
                return card
            }
        }
        
        return nil
    }
    
    

}
