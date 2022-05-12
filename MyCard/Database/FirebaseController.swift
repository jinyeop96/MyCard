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
    
    var currentUser: User?  // holidng signed in user's details inclduing documentID of documents in 'contacts' and 'userCards'
    var usersRef: CollectionReference?      // reference to the users collection
    var contactsRef: CollectionReference?   // each of documents in contacts collection holds documentIDs of card documents
    var individualCardsRef: CollectionReference?  // each of documents in individualCards collection holds documentIDs of card documents
    var cardsRef: CollectionReference?
    
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
    func signUp(user: User, email: String, password: String) {
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
                
                // 4. Add user detail
                user.uid = authResut.user.uid
                user.contactId = contactRef?.documentID
                user.individualCardId = individualCardRef?.documentID
                
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
                    self.alertListener(listenerType: .signIn, successful: true)
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
            // 1. Add new document in cards collection
            let cardRef = try cardsRef?.addDocument(from: card)
            
            // 2. Update userCards collection for the current user
            if let individualCardId = currentUser?.individualCardId, let cardRef = cardRef {
                individualCardsRef?.document(individualCardId).updateData(["individualCardIds" : FieldValue.arrayUnion([cardRef])])
            }
            
            alertListener(listenerType: .newCard, successful: true)
        } catch {
            alertListener(listenerType: .newCard, successful: false)
        } // do-catch ends
    }
    
    func removeCard(card: Card) {
        if let cardId = card.id {
            cardsRef?.document(cardId).delete()
        }
    }
    
    func deleteUser(user: User) {
        //
    }
    
    func searchCards(searchText: String){
        var filteredCards: [Card] = []
        
        // Filter out searched cards out of allCards list
        filteredCards = allCards.filter( { card in
            return card.nameLowercased?.contains(searchText) ?? false && card.email != currentUser?.email
        })
            
        // Pass parsed card objects back to serach table view controller
        self.listeners.invoke{ (listener) in
            if listener.listenerType == .searchCards {
                listener.didSearchCards(cards: filteredCards)
            }
        }
        
    }
    
    func addToContact(card: Card) {
        if let cardId = card.id {
            // 1. Check given document id exists in collection
            if let cardRef = cardsRef?.document(cardId), let contactId = currentUser?.contactId {
                contactsRef?.document(contactId).updateData(["contactCardIds" : FieldValue.arrayUnion([cardRef])])
            }
        }
        
    }
    
    func removeFromContact(card: Card) {
        // 1. check if the input card exists, then remove from user's contact list.
        if let cardId = card.id, let contactId = currentUser?.contactId,
            let cardRef = cardsRef?.document(cardId) {
            contactsRef?.document(contactId).updateData(["contactCardIds" : FieldValue.arrayRemove([cardRef])])
        }
    }
    
    
    // MARK: - FirebaseController specific methods
    private func alertListener(listenerType: ListenerType, successful: Bool){
        listeners.invoke { (listener) in
            if listenerType == .signUp && successful {
                listener.didSucceedSignUp()
            }
            
            if listenerType == .signUp && !successful {
                listener.didNotSucceedSignUp()
            }
            
            if listenerType == .signIn && successful{
                listener.didSucceedSignIn()
            }
            
            if listenerType == .signIn && !successful{
                listener.didNotSucceedSignIn()
            }
            
            if listenerType == .newCard && successful{
                listener.didSucceedCreateCard()
            }
            
            if listenerType == .newCard && !successful{
                listener.didNotSucceedCreateCard()
            }
            
            if listenerType == .my && successful{
                listener.onUserCardsChanges(change: .update, userCards: userCards)
            }
            
            if listenerType == .contacts && successful{
                listener.onContactCardsChange(change: .update, contactCards: contactsCards)
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
                
                // 2. retrieve all cards
                self.setUpCardsListener()
                
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
        
        // After having user's card and all cards, also get contacts and user's cards
        setUpContactsListener()
        setUpIndividualCardsListener()
        self.alertListener(listenerType: .my, successful: true)
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
        
//        // If not found, target id is removed from cards collection
//        if let contactId = currentUser?.contactId, let cardRef = cardsRef?.document(id) {
//            contactsRef?.document(contactId).updateData(["contactCardIds" : FieldValue.arrayRemove([cardRef])])
//        }
        
        return nil
    }
}
