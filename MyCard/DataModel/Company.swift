//
//  Company.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/16.
//

import UIKit

class Company: NSObject, Decodable {
    var companyDetails: [CompanyDetail]
    
    private enum CodingKeys: String, CodingKey{
        case companyDetails = "itemListElement"
    }
}

class CompanyDetail: Decodable{
    var detail: Detail
    
    private enum CodingKeys: String, CodingKey{
        case detail = "result"
    }
}

class Detail: Decodable{
    var description: String?
    var detailedDescription: DetailedDescription?
    var name: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try? container.decode(String.self, forKey: .description)
        self.name = try? container.decode(String.self, forKey: .name)
        self.detailedDescription = try? container.decode(DetailedDescription.self, forKey: .detailedDescription)
    }
    
    private enum CodingKeys: String, CodingKey{
        case description = "description"
        case detailedDescription = "detailedDescription"
        case name = "name"
    }
}

struct DetailedDescription: Decodable{
    var articleBody: String
}
