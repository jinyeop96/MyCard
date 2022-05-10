//
//  Card.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/25.
//

import UIKit
import FirebaseFirestoreSwift

class Card: NSObject, Codable {
    @DocumentID var id: String?
    var isPersonal: Bool?
    var title: String?
    var name: String?
    
    // This is used for searching
    var nameLowercased: String?
    var companyName: String?
    var department: String?
    var address: String?
    var mobile: String?
    var email: String?
    var ownerUid: String?
    
}
