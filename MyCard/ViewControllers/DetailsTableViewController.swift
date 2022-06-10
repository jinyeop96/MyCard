//
//  DetailsTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/06/02.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailedDescriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class DetailTableViewController: UITableViewController {
    // MARK: - Properties
    var card: Card?
    
    // Google Knowledge Graph API Key
    let API_KEY = "AIzaSyAA4vtL6kDKCeSxWnGuMmVhE9n61UWNol8"
    let DETAILS_CELL = "detailsCell"
    
    // Used for decoding company details, if navigated from Card detail view
    var details: [CompanyDetail] = []
    
    // Used for displaying third-party aknowledgement, for About page.
    let libraries = [
        ["Firebase  (FIrebaseAuth, Firestore)",
         "Copyright 2017-2022 Google",
         "Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at \n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License."],
        ["Google Knowledge Graph Search API",
         "Copyright 2022 Google",
         "Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at \n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License."]
    ]
    
    var displayCompanyDetails = false
    var indicator = UIActivityIndicatorView()
    

    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Set loading indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Only if it needs to get company details from Google Knowledge graph API
        if displayCompanyDetails {
            
            if let card = card, let company = card.companyName {
                navigationItem.title = "\(company) details" // Set company description title
            }
            
            getCompanyDetails() // API Request
            indicator.startAnimating()
        } else {
            navigationItem.title = "About" // Set About title
        }
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayCompanyDetails {
            return details.count
        }
        return libraries.count
    }

    /*
     Displaying company details and About have the same cell structure.
     So dependin on where it was navigated from, it assigns company details or third-party library aknowlements
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DETAILS_CELL, for: indexPath) as! DetailsTableViewCell
        
        var name: String?
        var description: String?
        var detailedDescription: String?
        
        // Depending on where it was navigated from, it assigns company details or third-party library aknowlements
        if displayCompanyDetails {
            let detail = details[indexPath.row].detail
            name = detail.name
            description = detail.description
            detailedDescription = detail.detailedDescription?.articleBody ?? "No detailed description."
            
        } else {
            name = libraries[indexPath.row][0]
            description = libraries[indexPath.row][1]
            detailedDescription = libraries[indexPath.row][2]
        }
        
        // Populate data
        if let name = name {
            cell.nameLabel.text = name
            cell.nameLabel.numberOfLines = 0
        }
        
        if let description = description {
            cell.descriptionLabel.text = description
            cell.descriptionLabel.numberOfLines = 0
        }
        
        if let detailedDescription = detailedDescription {
            cell.detailedDescriptionLabel.text = detailedDescription
            cell.detailedDescriptionLabel.numberOfLines = 0
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    /*
     This function makes API Request for retrieving company details.
     It decodes the retrieved JSON object into Company object and populate them into the table view.
     It displays an error message if any errors occur.
     
     The URL is from
     https://developers.google.com/knowledge-graph
     
     I only acquired the request URL and search scope(Corporation and Organization).
     */
    private func getCompanyDetails(){
        if let card = card, let companyName = card.companyName?.lowercased(){
            // 1. Construct URL query with the company name
            var searchURLComponents = URLComponents()
            searchURLComponents.scheme = "https"
            searchURLComponents.host = "kgsearch.googleapis.com"
            searchURLComponents.path = "/v1/entities:search"
            searchURLComponents.queryItems = [
                URLQueryItem(name: "query", value: companyName),
                URLQueryItem(name: "types", value: "Corporation"),
                URLQueryItem(name: "types", value: "Organization"),
                URLQueryItem(name: "key", value: API_KEY)
            ]
            
            // 2. Check for correctness
            guard let requestURL = searchURLComponents.url else {
             displayMessage(title: "Invalid API Request URL", message: "Invalid URL detected! Try again.")
             return
            }
            
            let urlRequest = URLRequest(url: requestURL)
            Task{
                do {
                    // 3. Get data
                    let (data, _) = try await URLSession.shared.data(for: urlRequest)
                    
                    // 4. Decode data
                    let decoder = JSONDecoder()
                    let company = try decoder.decode(Company.self, from: data)
                    
                    // 5. reload the table view again
                    self.details = company.companyDetails
                    self.indicator.stopAnimating()
                    self.tableView.reloadData()
                } catch {
                    displayMessage(title: "Error", message: "Error occured while getting the company details. Try again.")
                }
            }
        }
    }

}
