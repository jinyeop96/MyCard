//
//  MyTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit

class MyTableViewController: UITableViewController, DatabaseListener {
    // MARK: - Properties
    let BUSINESS_CARD_SECTION = 0
    let PERSONAL_CARD_SECTION = 1
    let BUSINESS_CARD_CELL = "businessCardCell"
    let PERSONAL_CARD_CELL = "personalCardCell"
    
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
        if indexPath.section == BUSINESS_CARD_SECTION {
            // Create resuable cell for business card
            let businessCardCell = tableView.dequeueReusableCell(withIdentifier: BUSINESS_CARD_CELL, for: indexPath)
            
            var content = businessCardCell.defaultContentConfiguration()
            let businessCard = businessCards[indexPath.row]
            
            // Set title to company name and secondaryName to user's name
            if let companyName = businessCard.companyName{
                content.text = companyName
            }
            
            if let surname = businessCard.surname, let givenname = businessCard.givenname {
                content.secondaryText = surname + " " + givenname
            }
            
            businessCardCell.contentConfiguration = content

            return businessCardCell
        } else {
            // Create resuable cell for business card
            let personalCardCell = tableView.dequeueReusableCell(withIdentifier: PERSONAL_CARD_CELL, for: indexPath)
            
            var content = personalCardCell.defaultContentConfiguration()
            let personalCard = personalCards[indexPath.row]
            
            // Set title to user's name and secondaryName to user's email
            if let surname = personalCard.surname, let givenname = personalCard.givenname {
                content.text = surname + " " + givenname
            }
            
            if let email = personalCard.email{
                content.secondaryText = email
            }
            
            personalCardCell.contentConfiguration = content

            return personalCardCell
        }

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
    
    // MARK: - Database specific methods
    
    
    
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
    


}
