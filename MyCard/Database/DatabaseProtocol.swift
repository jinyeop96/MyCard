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
    case newCard
    case cardDetail
    case contacts
    case all
    case update
    case signUp
    case signIn
    case searchCards
    case scanner
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    //func onContactsChange(change: DatabaseChange, teamHeroes: [Superhero])
    func didSucceedSignUp()
    func didSucceedSignIn()
    func didNotSucceedSignUp()
    func didNotSucceedSignIn()
    func didSucceedCreateCard()
    func didNotSucceedCreateCard()
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
    func signUp(user: User, email: String, password: String)
    func signIn(email: String, password: String)
    func logOut()
    
    // Cards
    func addCard(card: Card)
    func removeCard(card: Card)
    func searchCards(searchText: String)
    func addToContact(card: Card)
    func removeFromContact(card: Card)
    

}

