//
//  CompanyDetailTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/16.
//

import UIKit

class CompanyDetailTableViewController: UITableViewController {
    // MARK: - Properties
    var card: Card?
    let API_KEY = "AIzaSyAA4vtL6kDKCeSxWnGuMmVhE9n61UWNol8"
    let CARD_DETAIL_CELL_IDENTIFIER = "cardDetailCell"
    var details: [CompanyDetail] = []
    var indicator = UIActivityIndicatorView()
    

    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add loading
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        
        indicator.startAnimating()
        getCompanyDetails()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CARD_DETAIL_CELL_IDENTIFIER, for: indexPath) as! CompanyDetailTableViewCell

        let detail = details[indexPath.row].detail
        
        cell.nameLabel.text = detail.name ?? ""
        cell.nameLabel.numberOfLines = 0
        
        cell.descriptionLabel.text = detail.description ?? ""
        cell.descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        cell.detailedDescriptionLabel.text = detail.detailedDescription?.articleBody ?? "No detailed description."
        cell.detailedDescriptionLabel.numberOfLines = 0
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // MARK: - View specific methods
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
             print("Invalid URL.")
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
                    print(error)
                }
            }
        }
    }

}
