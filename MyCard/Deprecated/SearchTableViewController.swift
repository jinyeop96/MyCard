////
////  SearchTableViewController.swift
////  MyCard
////
////  Created by JINYEOP OH on 2022/04/24.
////
//
//import UIKit
//
//class SearchTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
//    // MARK: - Properties
//    let displayingCards = DisplayingCards() // Cards model
//    var listenerType: ListenerType = .searchCards
//    var databaseController: DatabaseProtocol?
//
//
//    // MARK: - On view loads
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set database controller
//        databaseController = getDatabaseController()
//
//        // Set search controller
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search By Name"
//        navigationItem.searchController = searchController
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        databaseController?.addListener(listener: self)
//        tabBarController?.tabBar.isHidden = false
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        databaseController?.removeListener(listener: self)
//        displayingCards.removeAllCards()
//
//    }
//
//
//    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//            case BUSINESS_CARD_SECTION:
//                return displayingCards.getBusinessCardsCount()
//            case PERSONAL_CARD_SECTION:
//                return displayingCards.getPersonalCardsCount()
//            default:
//                return 1
//        }
//    }
//
//    // Setting Section names
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//            case BUSINESS_CARD_SECTION:
//                return "Business cards"
//            case PERSONAL_CARD_SECTION:
//                return "Personal cards"
//            default:
//                return "Information"
//        }
//    }
//
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == BUSINESS_CARD_SECTION || indexPath.section == PERSONAL_CARD_SECTION {
//            return assignCardOnCell(tableView: tableView, indexPath: indexPath, displayingCards: displayingCards)
//        } else {
//            return assignInfoCell(tableView: tableView, indexPath: indexPath, displayingCards: displayingCards)
//        }
//    }
//
//
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == INFO_SECTION {
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }
//
//
//    // MARK: - Search result updating
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let searchText = searchController.searchBar.text?.lowercased() else {
//            return
//        }
//
//        if searchText.count > 0{
//            databaseController?.searchCards(searchText: searchText)
//        }
//    }
//
//
//    // MARK: - Database specific methods
//    func didSearchCards(cards: [Card]){
//        displayingCards.removeAllCards()
//
//        for card in cards{
//            if let isPersonal = card.isPersonal {
//                displayingCards.appendCard(card: card, isPersonal: isPersonal)
//            }
//        }
//
//        tableView.reloadData()
//    }
//
//    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "cardDetailSegue" {
//            let destination = segue.destination as! CardDetailViewController
//            destination.isEditable = false
//            destination.isAddable = true
//            destination.databaseController = databaseController
//
//            if let indexPath = tableView.indexPathForSelectedRow{
//                if indexPath.section == BUSINESS_CARD_SECTION {
//                    destination.card = displayingCards.getBusinessCardAt(row: indexPath.row)
//                }
//
//                if indexPath.section == PERSONAL_CARD_SECTION {
//                    destination.card = displayingCards.getPersonalCardAt(row: indexPath.row)
//                }
//            }
//        }
//
//        if segue.identifier == "scannerSegue" {
//            let destination = segue.destination as! ScannerViewController
//            destination.databaseController = databaseController
//        }
//    }
//
//
//    // MARK: - Unneccesary inherited methods
//    func didSucceedSignUp() {
//        // Do Nothing
//    }
//
//    func didNotSucceedSignUp() {
//        // Do Nothing
//    }
//
//    func didNotSucceedSignIn() {
//        // Do Nothing
//    }
//
//    func onUserCardsChanges(userCards: [Card]) {
//        // Do Nothing
//    }
//
//    func onContactCardsChange(contactCards: [Card]) {
//        // Do Nothing
//    }
//
//    func onCardsListChange(cards: [Card]) {
//        //
//    }
//
//}
