//
//  CardsListTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/06/02.
//

import UIKit

class CardsListTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    // MARK: - Properties
    
    // Lists of cards for displaynig in this table view
    let displayingCards = DisplayingCards()
    
    let MY_TAB = "My"
    let CONTACTS_TAB = "Contacts"
    let SEARCH_TAB = "Search"
    var currentTab: String?     // This will be updated when user switches to another tab
    
    // Contants
    let BUSINESS_CARD_SECTION = 0
    let PERSONAL_CARD_SECTION = 1
    let INFO_SECTION = 2
    let BUSINESS_CARD_CELL = "businessCardCell"
    let PERSONAL_CARD_CELL = "personalCardCell"
    let INFO_CELL = "infoCell"
    let NEW_CARD_SEGUE = "newCardSegue"
    let SCANNER_SEGUE = "scannerSegue"
    let CARD_DETAIL_SEGUE = "cardDetailSegue"
    
    var listenerType: ListenerType = .my    // This will be updated when user switches to another tab
    var databaseController: DatabaseProtocol?
    var currentUser: User?
    var searchController: UISearchController?

    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get Reference to the database controller and current user
        databaseController = getDatabaseController()
        currentUser = getCurrentUser(databaseController: databaseController)
        
        // Set searchController properties
        searchController = UISearchController(searchResultsController: nil)
        if let searchController = searchController {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search By Name"
        }
    }

    // This function will be invoked whenever the user switches to another tab.
    // Depending on the current tab, it adds new listener to the databaseController, update the navigation bar title and enable/disable the BarButtonItem.
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unhide tab bar below
        tabBarController?.tabBar.isHidden = false
        
        // 1. Update the current tab
        currentTab = tabBarController?.tabBar.selectedItem?.title
        
        if let currentTab = currentTab {
            // 2. Update listener type, BarButtonItem depending on the tab and navigation title
            // Set BarButtonItem programmatically: https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-bar-button-to-a-navigation-bar
            switch currentTab {
            case CONTACTS_TAB:
                listenerType = .contacts
                navigationItem.rightBarButtonItem = nil
                navigationController?.navigationBar.topItem?.title = CONTACTS_TAB
                navigationItem.searchController = nil   // Disable the search controller
                
            case SEARCH_TAB:
                listenerType = .searchCards
                // Asscociated function navigates to the ScannerViewController
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(barButtonTapped))
                navigationController?.navigationBar.topItem?.title = SEARCH_TAB
                
                // 2.1 Also enable serach bar if it is on Searching tab
                if let searchController = searchController {
                    navigationItem.searchController = searchController
                }
                
            default: // MY_TAB
                listenerType = .my
                // Asscociated function navigates to the NewCardViewController
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(barButtonTapped))
                navigationController?.navigationBar.topItem?.title = MY_TAB
                navigationItem.searchController = nil   // Disable the search controller
            }
        }
        // 5. Add updated listener to the databaseController
        databaseController?.addListener(listener: self)
    }
    
    // This is invoked prior to the viewDidAppear(). It removes current listener and removes all cards in DisplayingCards object model
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case BUSINESS_CARD_SECTION :
            return displayingCards.getBusinessCardsCount()
        case PERSONAL_CARD_SECTION:
            return displayingCards.getPersonalCardsCount()
        default:
            return 1 // for info section
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
            return "Information"
        }
    }

    // Assign appropriate cards for sections
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If the section needs cards details, call assignCardOnCell()
        if indexPath.section == BUSINESS_CARD_SECTION || indexPath.section == PERSONAL_CARD_SECTION {
            return assignCardOnCell(indexPath: indexPath)
        }
        
        // Otherwise populate information
        return assignInfoCell(indexPath: indexPath)
        
    }
    
    // It removes the card from 'My' or 'Contact' list. If the user is on searching tab, this function will do nothing.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let currentTab = currentTab {
            
            // Get the deleting card
            let card = displayingCards.getDeletingCardAt(indexPath: indexPath)
            
            if currentTab == MY_TAB {
                databaseController?.removeCard(card: card)
            }
            
            if currentTab == CONTACTS_TAB {
                databaseController?.removeFromContact(card: card)
            }
            
        }
    }
    
    // This only enables the business and personal card section editable. Info section is disabled.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == BUSINESS_CARD_SECTION || indexPath.section == PERSONAL_CARD_SECTION {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == INFO_SECTION {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    // MARK: - This view specific methods
    // BarButtonItem appears iff user is on 'My' or 'Search' tab. If it is tapped, it performs a segue
    @objc func barButtonTapped(sender: Any) {
        if let currentTab = currentTab {
            if currentTab == MY_TAB {
                performSegue(withIdentifier: NEW_CARD_SEGUE, sender: self)
            }
            
            if currentTab == SEARCH_TAB {
                performSegue(withIdentifier: SCANNER_SEGUE, sender: self)
            }
        }
    }
    
    private func assignCardOnCell(indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        var card: Card?
    
        if indexPath.section == BUSINESS_CARD_SECTION {
            cell = tableView.dequeueReusableCell(withIdentifier: BUSINESS_CARD_CELL, for: indexPath)
            card = displayingCards.getBusinessCardAt(row: indexPath.row)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: PERSONAL_CARD_CELL, for: indexPath)
            card = displayingCards.getPersonalCardAt(row: indexPath.row)
        }
         
        if let cell = cell, let card = card {
            var content = cell.defaultContentConfiguration()
            
            if indexPath.section == BUSINESS_CARD_SECTION {
                content.text = card.companyName ?? ""
                content.secondaryText = card.name ?? ""
            }
            
            if indexPath.section == PERSONAL_CARD_SECTION {
                content.text = card.name ?? ""
                content.secondaryText = card.address ?? ""
            }
            
            cell.contentConfiguration = content
        }
        
       return cell! // Since the cell is surely assigned, we can safely force unwrap
    }
    
    private func assignInfoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "\(displayingCards.getBusinessCardsCount()) business and \(displayingCards.getPersonalCardsCount()) personal cards in the list."
        cell.contentConfiguration = content
        return cell
    }
    
    
    // MARK: - Database specific methods
    // This is invoked by snapshot listener in databaseController when card or contact lists changes, or called from Search tab
    func onCardsListChange(cards: [Card]) {
        displayingCards.removeAllCards()
        
        // Iterate for all input cards and append them into displayingCards model
        for card in cards {
            if let isPersonal = card.isPersonal {
                displayingCards.appendCard(card: card, isPersonal: isPersonal)
            }
        }
        
        // Distribute them into correct cells.
        tableView.reloadData()
    }
    
    
    // MARK: - Search result updating
    func updateSearchResults(for searchController: UISearchController) {
        // If nothing is typed on the search bar, just terminate it.
        guard let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 else {
            return
        }
        
        if let filteredCards = databaseController?.searchCards(searchText: searchText) {
            onCardsListChange(cards: filteredCards)
        }
        
    }


    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set properties depending on the current tab when navigating to CardDetailViewController
        if segue.identifier == CARD_DETAIL_SEGUE, let currentTab = currentTab {
            
            let destination = segue.destination as! CardDetailViewController
            destination.databaseController = databaseController
            
            // Set properties depending on the current tab
            switch currentTab {
                case CONTACTS_TAB :
                    destination.isEditable = false
                    destination.isAddable = false
                case SEARCH_TAB:
                    destination.isEditable = false
                    destination.isAddable = true
                default:
                    destination.isEditable = true
                    destination.isAddable = false
            }
            
            // Set card property depening on the section( business or personal section )
            if let indexPath = tableView.indexPathForSelectedRow{
                if indexPath.section == BUSINESS_CARD_SECTION {
                    destination.card = displayingCards.getBusinessCardAt(row: indexPath.row)
                }
                
                if indexPath.section == PERSONAL_CARD_SECTION {
                    destination.card = displayingCards.getPersonalCardAt(row: indexPath.row)
                }
            }
        } // End of navigation to CardDetailViewController
        
        if segue.identifier == NEW_CARD_SEGUE {
            let destination = segue.destination as! NewCardViewController
            destination.databaseController = databaseController
            destination.user = currentUser
        }
        
        if segue.identifier == SCANNER_SEGUE {
            let destination = segue.destination as! ScannerViewController
            destination.databaseController = databaseController
        }
    }
    
    
    // MARK: - Unneccessary inherited methods
    func didSucceedSignUp() {
        // Do nothing
    }
    
    func didNotSucceedSignUp() {
        // Do nothing
    }
    
    func didNotSucceedSignIn() {
        // Do nothing
    }

}
