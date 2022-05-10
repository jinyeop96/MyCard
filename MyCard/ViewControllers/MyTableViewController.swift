//
//  MyTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit

class MyTableViewController: UITableViewController, DatabaseListener {
    // MARK: - Properties
    let CARD_DETAIL_SEGUE = "cardDetailSegue"
    
    var businessCards = [Card]()
    var personalCards = [Card]()
    
    var listenerType: ListenerType = .my
    var databaseController: DatabaseProtocol?
    
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case BUSINESS_CARD_SECTION :
            return businessCards.count
        case PERSONAL_CARD_SECTION:
            return personalCards.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Helper methods are declared in UITableViewController+displayingCards file
        if indexPath.section == BUSINESS_CARD_SECTION {
            return assignBusinessCards(tableView: tableView, indexPath: indexPath, businessCards: businessCards)
        } else {
            return assignPersonalCards(tableView: tableView, indexPath: indexPath, personalCards: personalCards)
        }
    }
    
    // Setting Section names
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case BUSINESS_CARD_SECTION:
            return "Business cards"
        case PERSONAL_CARD_SECTION:
            return "Personal cards"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var card = Card()
            if indexPath.section == BUSINESS_CARD_SECTION {
                card = businessCards[indexPath.row]
            } else {
                card = personalCards[indexPath.row]
            }
            
            databaseController?.removeCard(card: card)
        }
    }
    

    
    // MARK: - Database specific methods
    func onUserCardsChanges(change: ListenerType, userCards: [Card]) {
        businessCards.removeAll()
        personalCards.removeAll()
        
        for card in userCards {
            if let isPersonal = card.isPersonal {
                if isPersonal {
                    personalCards.insert(card, at: personalCards.count)
                }
                
                if !isPersonal {
                    businessCards.insert(card, at: businessCards.count)
                }
            }
            
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CARD_DETAIL_SEGUE {
            let destination = segue.destination as! CardDetailViewController
            
            // Set card object in CardDetailViewController editable since is is navigated from 'My' section
            destination.isEditable = true
            
            if let indexPath = tableView.indexPathForSelectedRow{
                if indexPath.section == BUSINESS_CARD_SECTION {
                    destination.card = businessCards[indexPath.row]
                }
                
                if indexPath.section == PERSONAL_CARD_SECTION {
                    destination.card = personalCards[indexPath.row]
                }
            }
            
            
            
        }
    }
    
    // MARK: - Unnecessary inherited methods
    func didSucceedSignUp() {
        // Do Nothing
    }
    
    func didSucceedSignIn() {
        // Do Nothing
    }
    
    func didNotSucceedSignUp() {
        // Do Nothing
    }
    
    func didNotSucceedSignIn() {
        // Do Nothing
    }
    
    func didSucceedCreateCard() {
        // Do Nothing
    }
    
    func didNotSucceedCreateCard() {
        // Do Nothing
    }
    
    func didSearchCards(cards: [Card]) {
        // Do Nothing
    }
    
    func onContactCardsChange(change: ListenerType, contactCards: [Card]) {
        // Do Nothing
    }
    


}
