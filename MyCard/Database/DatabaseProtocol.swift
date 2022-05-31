//
//  DatabaseProtocol.swift
//  FIT3178-W02-Lab
//
//  Created by Jason Haasz on 20/3/2022.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case my
    case contacts
    case update
    case signUp
    case signIn
    case searchCards
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func didSucceedSignUp()
    func didNotSucceedSignUp()
    func didNotSucceedSignIn()
    func didSearchCards(cards: [Card])
    func onUserCardsChanges(change: ListenerType, userCards: [Card])
    func onContactCardsChange(change: ListenerType, contactCards: [Card])
}

protocol DatabaseProtocol: AnyObject {
    // Listeners
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // Users
    func deleteUser(user: User)
    func updatePassword(password: String) 
    func signUp(user: User, email: String, password: String) 
    func signIn(email: String, password: String)
    func signOut()
    
    // Cards
    func addCard(card: Card) -> Bool
    func removeCard(card: Card)
    func updateCard(card: Card) -> Bool
    func searchCards(searchText: String)
    func addToContact(card: Card) -> Bool
    func removeFromContact(card: Card)
    

}

