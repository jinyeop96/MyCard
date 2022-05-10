//
//  SearchTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    // MARK: - Properties
    let CARD_DETAIL_SEGUE = "cardDetailSegue"
    var businessCards = [Card]()
    var personalCards = [Card]()
    
    var listenerType: ListenerType = .searchCards
    var databaseController: DatabaseProtocol?
    
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Search controller
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
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
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
                    businessCards.insert(card, at: businessCards.count)
                }
                
                if isPersonal {
                    personalCards.insert(card, at: personalCards.count)
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
            
            if let indexPath = tableView.indexPathForSelectedRow {
                if indexPath.section == BUSINESS_CARD_SECTION {
                    destination.card = businessCards[indexPath.row]
                }
                
                if indexPath.section == PERSONAL_CARD_SECTION {
                    destination.card = personalCards[indexPath.row]
                    
                }
            }
            
        }
    }
    
    // MARK: - Unneccesary inherited methods
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
    
    func onUserCardsChanges(change: ListenerType, userCards: [Card]) {
        // Do Nothing
    }
    
    func onContactCardsChange(change: ListenerType, contactCards: [Card]) {
        // Do Nothing
    }

}
