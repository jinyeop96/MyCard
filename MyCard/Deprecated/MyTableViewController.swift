////
////  MyTableViewController.swift
////  MyCard
////
////  Created by JINYEOP OH on 2022/04/24.
////
//
//import UIKit
//
//class MyTableViewController: UITableViewController, DatabaseListener {
//    // MARK: - Properties
//    let displayingCards = DisplayingCards() // Cards model
//    var listenerType: ListenerType = .my
//    var databaseController: DatabaseProtocol?
//
//
//    // MARK: - On view loads
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        databaseController = getDatabaseController()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        databaseController?.addListener(listener: self)
//        tabBarController?.tabBar.isHidden = false
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        databaseController?.removeListener(listener: self)
//        displayingCards.removeAllCards()
//    }
//
//
//    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 3    // For business cards, personal cards and info section
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
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == BUSINESS_CARD_SECTION || indexPath.section == PERSONAL_CARD_SECTION {
//            return assignCardOnCell(tableView: tableView, indexPath: indexPath, displayingCards: displayingCards)
//        } else {
//            return assignInfoCell(tableView: tableView, indexPath: indexPath, displayingCards: displayingCards)
//        }
//
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
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == BUSINESS_CARD_SECTION || indexPath.section == PERSONAL_CARD_SECTION {
//            return true
//        }
//        return false
//    }
//
//
//
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let card = displayingCards.getDeletingCardAt(indexPath: indexPath)
//            databaseController?.removeCard(card: card)
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == INFO_SECTION {
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }
//
//
//
//    // MARK: - Database specific methods
//    func onUserCardsChanges(userCards: [Card]) {
//        displayingCards.removeAllCards()
//
//        for card in userCards {
//            if let isPersonal = card.isPersonal {
//                displayingCards.appendCard(card: card, isPersonal: isPersonal)
//            }
//        }
//
//        tableView.reloadData()
//    }
//
//
//    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "cardDetailSegue" {
//            let destination = segue.destination as! CardDetailViewController
//
//            // Set card object in CardDetailViewController editable since is is navigated from 'My' section
//            destination.isEditable = true
//            destination.isAddable = false
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
//        if segue.identifier == "newCardSegue" {
//            let destination = segue.destination as! NewCardViewController
//            destination.user = getCurrentUser(databaseController: databaseController)
//        }
//    }
//
//
//    // MARK: - Unnecessary inherited methods
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
//    func didSearchCards(cards: [Card]) {
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
//}
