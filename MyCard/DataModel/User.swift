//
//  User.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    var id: String?
    var title: String?
    var surname: String?
    var givenName: String?
    var nickName: String?
    var dob: Date?
    var mobile: String?
    var email: String?
}
