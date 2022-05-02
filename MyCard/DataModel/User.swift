//
//  User.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/04/24.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    @DocumentID var id: String?
    var title: String?
    var surname: String?
    var givenname: String?
    var dob: String?
    var mobile: String?
    var email: String?
    var uid: String?
   
}
