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
    
}

protocol DatabaseProtocol: AnyObject {
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    //func addUser(name: String, abilities:String, universe: Universe) -> User
    func deleteUser(user: User)
    
//    var userTeam: Team {get}
//    func addTeam(teamName: String) -> Team
//    func deleteTeam(team: Team)
//    func addHeroToTeam(hero: Superhero, team: Team) -> Bool
//    func removeHeroFromTeam(hero: Superhero, team: Team)

    
    func signUp(user: User, email: String, password: String)
    func signIn(email: String, password: String)
    func logOut()
}
