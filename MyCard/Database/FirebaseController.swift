//
//  FirebaseController.swift
//  FIT3178-W02-Lab
//
//  Created by JINYEOP OH on 2022/04/08.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseController: NSObject, DatabaseProtocol {
 
    // MARK: - Properties
    var listeners = MulticastDelegate<DatabaseListener>()
    var heroList: [Superhero]
    var userTeam: Team
    
    var authController: Auth
    var currentUser: FirebaseAuth.User?
    var database: Firestore
    
    var heroesRef: CollectionReference?
    var teamsRef: CollectionReference?
    var usersRef: CollectionReference?
    
    
    
    override init(){
        FirebaseApp.configure() // must first call the configure method of FirebaseApp
        authController = Auth.auth()
        database = Firestore.firestore()
        heroList = [Superhero]()
        userTeam = Team()

        super.init()
        
        // References to users and team collections are required for the siging up process.
        // Signing up will immediately proceed to adding user details to the database.
        usersRef = database.collection("users")
        teamsRef = database.collection("teams")
        
        
//        // for anonymous authentication
//        // Signing in process is done in the back thread!
//        Task {
//            do {
//                let authDataResult = try await authController.signInAnonymously()
//                currentUser = authDataResult.user
//             }
//             catch {
//                 fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
//             }
//
//             self.setupHeroListener()
//        }
    }
    
    // MARK: - DatabaseProtocol specific methods
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        if listener.listenerType == .team || listener.listenerType == .all {
            listener.onTeamChange(change: .update, teamHeroes: userTeam.heroes)
        }
        
        if listener.listenerType == .heroes || listener.listenerType == .all {
            listener.onAllHeroesChange(change: .update, heroes: heroList)
        }
        
        
    }
    
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    
    func addSuperhero(name: String, abilities: String, universe: Universe) -> Superhero {
        let hero = Superhero()
        hero.name = name
        hero.abilities = abilities
        hero.universe = universe.rawValue
        
        do {
            if let heroRef = try heroesRef?.addDocument(from: hero) {
                hero.id = heroRef.documentID
            }
        } catch {
            print("Failed to serialize hero")
        }
        
        return hero
    }
    
    func addTeam(teamName: String) -> Team {
        let team = Team()
        team.name = teamName
        
        if let teamRef = teamsRef?.addDocument(data: ["name" : teamName]) {
            team.id = teamRef.documentID
        }
        
        return team
    }
    
    func addHeroToTeam(hero: Superhero, team: Team) -> Bool{
        guard let heroID = hero.id, let teamID = team.id, team.heroes.count < 6 else {
            return false
        }
        
        // get documentReference of hero and add to the team
        if let newHeroRef = heroesRef?.document(heroID) {
            teamsRef?.document(teamID).updateData(["heroes" : FieldValue.arrayUnion([newHeroRef])] )
        }
        
        return true
    }
    
    func deleteSuperhero(hero: Superhero){
        if let heroID = hero.id {
            heroesRef?.document(heroID).delete()
        }
    }
    
    func deleteTeam(team: Team){
        if let teamID = team.id {
            teamsRef?.document(teamID).delete()
        }
    }
    
    func removeHeroFromTeam(hero: Superhero, team: Team){
        if team.heroes.contains(hero), let teamID = team.id, let heroID = hero.id {
            if let removedHeroRef = heroesRef?.document(heroID) {
             teamsRef?.document(teamID).updateData(["heroes": FieldValue.arrayRemove([removedHeroRef])])
            }
        }
    }
    
    func cleanup(){
        // Do nothing
    }
    
    // MARK: - Authentication
    func signUp(email: String, password: String) {
        Task {
            do {
                // 1.Try creating an account with given email and password
                let authResult = try await authController.createUser(withEmail: email, password: password)
                
                // User account successfully created
                self.currentUser = authResult.user
                
      
                // 2. Add new team for this new user
                let newTeam = Team()
                newTeam.userEmail = authResult.user.email
                
                // Add a new document to teams collection
                let addedTeam = try self.teamsRef?.addDocument(from: newTeam)
                
                
                // 3. Create new user object
                let newUser = User()
                newUser.id = authResult.user.uid
                newUser.email = authResult.user.email
                if let teamDocumentId = addedTeam?.documentID {
                    newUser.teamId = teamDocumentId
                }
                
                // Add a new user detail with the team document ID
                let _ = try self.usersRef?.addDocument(from: newUser)
   
                
                // 4. If successfully run the following in main thread
                await MainActor.run {
                    // Let LoginViewController know and set heroes snapshot listener
                    // If successful to sign up, let the listener know so that it can segue
                    listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.auth {
                            listener.onLogInOrSignUpSucceed()
                        }
                    }
            
                    // Then setup the listener
                    setupHeroListener()
                    setupTeamListener()
                    
                } // MainActor.run
   
            } catch {
                print("Sign up failed : \(error)")
            } // Outer do
            
        } // Task
    } // End of signUp method
    
    func logIn(email: String, password: String){
        Task {
            do {
                // signIn method takes a bit of time. It needs await
                // If login fails, the error will be caught in catch block, otherwise it returns auth result.
                let authResult = try await authController.signIn(withEmail: email, password: password)
                    
                // set current user
                self.currentUser = authResult.user
                
                // Run methods in main thread
                await MainActor.run {
                    // Let LoginViewController know the loggin in was successful
                    listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.auth {
                            listener.onLogInOrSignUpSucceed()
                        }
                    }

                    // Then setup the listener
                    setupHeroListener()
                    setupTeamListener()
                }
            } catch {
                print("login failed")
                print(error)
            }
        }
    }
    
    func logOut(){
        do {
            try authController.signOut()
            
            // Also removec all heroes and team heroes
            heroList.removeAll()
            userTeam.heroes.removeAll()
        } catch {
            print("Sign out error : \(error)")
        }
        
    }
    
    // MARK: - Firebase Controller Specific Methods
    func getHeroByID(_ id: String) -> Superhero? {
        for hero in heroList {
            if hero.id == id {
                return hero
            }
        }
        return nil
    }
    
    func setupHeroListener(){
        heroesRef = database.collection("superheroes")
        
        heroesRef?.addSnapshotListener(){  (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            
            self.parseHeroesSnapshot(snapshot: querySnapshot)
        }
        
    }
    
    func setupTeamListener() {
        if let userEmail = currentUser?.email{
            teamsRef?.whereField("userEmail", isEqualTo: userEmail).addSnapshotListener { (querySnapshot, error) in
                guard let querySnapshot = querySnapshot, let teamSnapshot = querySnapshot.documents.first, error == nil else {
                    print("Error fetching teams: \(error!)")
                    return
                }

                self.parseTeamSnapshot(snapshot: teamSnapshot)
            }
        }
    }

    func parseHeroesSnapshot(snapshot: QuerySnapshot) {
        // documentChanges : An array of the documents that changed since the last snapshot. If this is the first snapshot, all documents will be in the list as Added changes.
        snapshot.documentChanges.forEach { (change) in
            var parsedHero: Superhero?

            do {
                // Superhero is Codable object, so decoding should be done in do-catch
                parsedHero = try change.document.data(as: Superhero.self)
            } catch {
                print("Unable to decode hero. Is the hero malformed?")
                return
            }
            
            guard let hero = parsedHero else {
                 print("Document doesn't exist")
                 return;
            }
            
            // Execute appropriate logics for each change.type
            if change.type == .added {
                // newIndex : The index of the changed document in the result set immediately after this DocumentChange (i.e. supposing that all prior DocumentChange objects and the current DocumentChange object have been applied).
                heroList.insert(hero, at: Int(change.newIndex))
            } else if change.type == .modified {
                // oldIndex : The index of the changed document in the result set immediately prior to this DocumentChange (i.e. supposing that all prior DocumentChange objects have been applied)
                heroList[Int(change.oldIndex)] = hero
            } else if change.type == .removed {
                heroList.remove(at: Int(change.oldIndex))
            }
            
            // Finally let listener know the changes with updated heroList
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.heroes || listener.listenerType == ListenerType.all {
                    listener.onAllHeroesChange(change: .update, heroes: heroList)
                }
            }
        }
    }
    
    func parseTeamSnapshot(snapshot: QueryDocumentSnapshot){
        userTeam = Team()
        userTeam.id = snapshot.documentID

        if let heroReferences = snapshot.data()["heroes"] as? [DocumentReference] {
            for reference in heroReferences {
                 if let hero = getHeroByID(reference.documentID) {
                     userTeam.heroes.append(hero)
                 }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.team || listener.listenerType == ListenerType.all {
                listener.onTeamChange(change: .update, teamHeroes: userTeam.heroes)
            }
        }
    }
    
    
    
}
