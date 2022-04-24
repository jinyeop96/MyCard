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
    var givenname: String?
    var nickname: String?
    var dob: String?
    var mobile: String?
    var email: String?
    var uid: String?
}
