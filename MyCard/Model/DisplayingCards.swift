//
//  DisplayingCards.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/06/02.
//

import Foundation

class DisplayingCards: NSObject {
    private var businessCards = [Card]()
    private var personalCards = [Card]()
    
    func appendCard(card: Card, isPersonal: Bool){
        if isPersonal {
            personalCards.append(card)
        } else {
            businessCards.append(card)
        }
    }
    
    func getBusinessCardsCount() -> Int {
        return businessCards.count
    }
    
    func getPersonalCardsCount() -> Int {
        return personalCards.count
    }
    
    func getBusinessCardAt(row: Int) -> Card {
        return businessCards[row]
    }
    
    func getPersonalCardAt(row: Int) -> Card {
        return personalCards[row]
    }
    
    func getDeletingCardAt(indexPath: IndexPath) -> Card {
        if indexPath.section == 0 { // From businessCards
            return getBusinessCardAt(row: indexPath.row)
        } else {
            return getPersonalCardAt(row: indexPath.row)
        }
    }
    
    func removeAllCards() {
        businessCards.removeAll()
        personalCards.removeAll()
    }
    
}
