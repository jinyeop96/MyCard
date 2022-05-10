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
    var contactsRef: CollectionReference?
    
    var userCards: [Card]
    var allCards: [Card]
    var contactsCards: [Card]
    
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
                
                user.uid = authResut.user.uid
                user.contactId = contactRef?.documentID
                
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
            // Assign owner(current user) 's UID for input card, then add it into Cards collection
            card.ownerUid = currentUser?.uid ?? ""
            let _ = try cardsRef?.addDocument(from: card)
            
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
        // Filter out searched cards out of allCards list
        var filteredCards = allCards.filter( { card in
            return card.nameLowercased?.contains(searchText) ?? false
        })
        
        // Filter out user's own cards
        filteredCards = filteredCards.filter({ card in
            return card.ownerUid != currentUser?.uid
        })
        
            
        // Pass parsed card objects back to serach table view controller
        self.listeners.invoke{ (listener) in
            if listener.listenerType == .searchCards {
                listener.didSearchCards(cards: filteredCards)
            }
        }
        
    }
    
    func addToContact(documentId: String) {
        // 1. Check given document id exists in collection
        if let cardRef = cardsRef?.document(documentId), let userContactId = currentUser?.contactId {
            contactsRef?.document(userContactId).updateData(["contacts" : FieldValue.arrayUnion([cardRef])])
            
            setUpContactsListener()
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
            
            self.parseUserSnapshot(snapshot: userSnapshot)            
            self.setUpCardsListener(uid: self.currentUser?.uid)
        }
    }
    
    private func parseUserSnapshot(snapshot: QueryDocumentSnapshot){
        // Parse user snapshot
        currentUser = User()
        do {
            // 1. Set it as current user
            currentUser = try snapshot.data(as: User.self)
        } catch {
            print(error)
        }
    }
    
    private func setUpCardsListener(uid: String?) {
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
            
            
            // Assign cards into userCards
            if let uid = currentUser?.uid, card.ownerUid == uid {
                if change.type == .added {
                    //userCards.insert(card, at: Int(change.newIndex))
                    userCards.append(card)
                } else if change.type == .modified {
                    userCards[Int(change.oldIndex)] = card
                } else if change.type == .removed {
                    userCards.remove(at: Int(change.oldIndex))
                }
            }
            
            
        } // forEach ends
        
        // After having user's card and all cards, also get cards in contact
        setUpContactsListener()
        self.alertListener(listenerType: .my, successful: true)
    }
    
    private func setUpContactsListener(){
        if let contactId = currentUser?.contactId{
            contactsRef?.document(contactId).addSnapshotListener{ querySnapshot, error in
                guard let querySnapshot = querySnapshot, error == nil else {
                    print("Failed to fetch documents with error: \(String(describing: error))")
                    return
                }
                
                self.parseContactsSnapshot(snapshot: querySnapshot)
            }
        }
        
    }
    
    private func parseContactsSnapshot(snapshot: DocumentSnapshot){
        contactsCards.removeAll()
        
        if let contacts = snapshot.data()?["contacts"] as? [DocumentReference]{
            for contact in contacts {
                if let card = getCardById(id: contact.documentID) {
                    contactsCards.append(card)
                }
            }
        }
        self.alertListener(listenerType: .contacts, successful: true)
    }
    
    private func getCardById(id: String) -> Card?{
        for card in allCards {
            if let cardId = card.id, cardId == id{
                return card
            }
        }
        
        return nil
    }
}
