//
//  Individual.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/10.
//

import UIKit
import FirebaseFirestoreSwift

class Individual: NSObject, Codable {
    @DocumentID var id: String?
    var individualCardIds:[Card] = []
}
