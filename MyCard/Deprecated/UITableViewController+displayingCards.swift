//
//  UITableViewController+displayingCards.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/03.
//

import Foundation
import UIKit

extension UITableViewController{
//    var BUSINESS_CARD_SECTION: Int {
//        get {
//            return 0
//        }
//    }
//
//    var PERSONAL_CARD_SECTION: Int {
//        get {
//            return 1
//        }
//    }
//    
//    var INFO_SECTION: Int {
//        get {
//            return 2
//        }
//    }
//
//    var BUSINESS_CARD_CELL: String {
//        get {
//            return "businessCardCell"
//        }
//    }
//
//    var PERSONAL_CARD_CELL: String {
//        get {
//            return "personalCardCell"
//        }
//    }
//
//    var INFO_CELL: String {
//        get {
//            return "infoCell"
//        }
//    }
//
//
//    func assignCardOnCell(tableView: UITableView, indexPath: IndexPath, displayingCards: DisplayingCards) -> UITableViewCell {
//        var cell: UITableViewCell?
//        var card: Card?
//
//        if indexPath.section == BUSINESS_CARD_SECTION {
//            cell = tableView.dequeueReusableCell(withIdentifier: BUSINESS_CARD_CELL, for: indexPath)
//            card = displayingCards.getBusinessCardAt(row: indexPath.row)
//        } else {
//            cell = tableView.dequeueReusableCell(withIdentifier: PERSONAL_CARD_CELL, for: indexPath)
//            card = displayingCards.getPersonalCardAt(row: indexPath.row)
//        }
//
//        if let cell = cell, let card = card {
//            var content = cell.defaultContentConfiguration()
//
//            if indexPath.section == BUSINESS_CARD_SECTION {
//                content.text = card.companyName ?? ""
//                content.secondaryText = card.name ?? ""
//            }
//
//            if indexPath.section == PERSONAL_CARD_SECTION {
//                content.text = card.name ?? ""
//                content.secondaryText = card.address ?? ""
//            }
//
//            cell.contentConfiguration = content
//        }
//
//       return cell! // Since the cell is surely assigned, we can safely force unwrap
//    }
//
//    func assignInfoCell(tableView: UITableView, indexPath: IndexPath, displayingCards: DisplayingCards) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL, for: indexPath)
//        var content = cell.defaultContentConfiguration()
//        content.text = "\(displayingCards.getBusinessCardsCount()) business and \(displayingCards.getPersonalCardsCount()) personal cards in the list."
//        cell.contentConfiguration = content
//        return cell
//    }
    
    
}
