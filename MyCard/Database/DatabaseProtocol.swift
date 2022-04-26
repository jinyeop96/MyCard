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
    case contacts
    case all
    case update
    case signUp
    case signIn
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
    
    func onUserCardsChanges(change: ListenerType, userCards: [Card])
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
    

}

