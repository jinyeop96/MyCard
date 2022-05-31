//
//  SearchTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener, CardDetailDelegate, ScannerDelegate {
    // MARK: - Properties
    let CARD_DETAIL_SEGUE = "cardDetailSegue"
    let SCANNER_SEGUE = "scannerSegue"
    
    var businessCards = [Card]()
    var personalCards = [Card]()
    
    var listenerType: ListenerType = .searchCards
    var databaseController: DatabaseProtocol?
    
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set database controller
        databaseController = getDatabaseController()

        // Set search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search By Name"
        navigationItem.searchController = searchController
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
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case BUSINESS_CARD_SECTION :
            return businessCards.count
        case PERSONAL_CARD_SECTION:
            return personalCards.count
        default:
            return 0
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Helper methods are declared in UITableViewController+displayingCards file
        if indexPath.section == BUSINESS_CARD_SECTION {
            return assignBusinessCards(tableView: tableView, indexPath: indexPath, businessCards: businessCards)
        } else {
            return assignPersonalCards(tableView: tableView, indexPath: indexPath, personalCards: personalCards)
        }
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    

    
    // MARK: - Search result updating
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0{
            databaseController?.searchCards(searchText: searchText)
        }
    }
    
    
    // MARK: - Database specific methods
    func didSearchCards(cards: [Card]){
        businessCards.removeAll()
        personalCards.removeAll()
        
        for card in cards{
            if let isPersonal = card.isPersonal{
                if !isPersonal {
                    businessCards.append(card)
                }
                
                if isPersonal {
                    personalCards.append(card)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CARD_DETAIL_SEGUE {
            let destination = segue.destination as! CardDetailViewController
            destination.isEditable = false
            destination.isAddable = true
            destination.delegate = self
            
            if let indexPath = tableView.indexPathForSelectedRow {
                if indexPath.section == BUSINESS_CARD_SECTION {
                    destination.card = businessCards[indexPath.row]
                }
                
                if indexPath.section == PERSONAL_CARD_SECTION {
                    destination.card = personalCards[indexPath.row]
                    
                }
            }
        }
        
        if segue.identifier == SCANNER_SEGUE {
            let destination = segue.destination as! ScannerViewController
            destination.delegate = self
        }
    }
    
    
    // MARK: - Delegation
    func addToContact(card: Card) -> Bool {
        if let databaseController = databaseController {
            return databaseController.addToContact(card: card)
        }
        return false
    }
    
    func addScannedCardToContact(card: Card) -> Bool {
        addToContact(card: card)
    }
    
    func getCardById(cardId: String) -> Card? {
        return getCardById(databaseController: databaseController, cardId: cardId)
    }
    
    // MARK: - Unneccesary inherited methods
    func didSucceedSignUp() {
        // Do Nothing
    }
  
    func didNotSucceedSignUp() {
        // Do Nothing
    }
    
    func didNotSucceedSignIn() {
        // Do Nothing
    }
    
    func onUserCardsChanges(userCards: [Card]) {
        // Do Nothing
    }
    
    func onContactCardsChange(contactCards: [Card]) {
        // Do Nothing
    }

}
