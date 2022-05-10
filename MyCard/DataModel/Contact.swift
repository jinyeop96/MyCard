//
//  Contact.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/10.
//

import UIKit
import FirebaseFirestoreSwift

class Contact: NSObject, Codable {
    @DocumentID var id: String?
    var contacts = [Card]()
}
