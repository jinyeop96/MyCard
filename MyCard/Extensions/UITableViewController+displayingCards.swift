//
//  UITableViewController+displayingCards.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/03.
//

import Foundation
import UIKit

extension UITableViewController{
    var BUSINESS_CARD_SECTION: Int {
        get {
            return 0
        }
    }
    
    var PERSONAL_CARD_SECTION: Int {
        get {
            return 1
        }
    }
    
    var BUSINESS_CARD_CELL: String {
        get {
            return "businessCardCell"
        }
    }
    
    var PERSONAL_CARD_CELL: String {
        get {
            return "personalCardCell"
        }
    }
    
    // functions for assigning cards in each table cell
    func assignBusinessCards(tableView: UITableView, indexPath: IndexPath, businessCards: [Card]) -> UITableViewCell {
        // Create resuable cell for business card
        let businessCardCell = tableView.dequeueReusableCell(withIdentifier: BUSINESS_CARD_CELL, for: indexPath)
        
        var content = businessCardCell.defaultContentConfiguration()
        let businessCard = businessCards[indexPath.row]
        
        // Set title to company name and secondaryName to user's name
        if let companyName = businessCard.companyName{
            content.text = companyName
        }
        
        if let name = businessCard.name {
            content.secondaryText = name
        }
        
        businessCardCell.contentConfiguration = content

        return businessCardCell
    }
    
    // functions for assigning cards in each table cell
    func assignPersonalCards(tableView: UITableView, indexPath: IndexPath, personalCards: [Card]) -> UITableViewCell {
        // Create resuable cell for business card
        let personalCardCell = tableView.dequeueReusableCell(withIdentifier: PERSONAL_CARD_CELL, for: indexPath)
        
        var content = personalCardCell.defaultContentConfiguration()
        let personalCard = personalCards[indexPath.row]
        
        // Set title to user's name and secondaryName to user's email
        if let name = personalCard.name {
            content.text = name
        }
        
        if let address = personalCard.address{
            content.secondaryText = address
        }
        
        personalCardCell.contentConfiguration = content

        return personalCardCell
    }
    
}
