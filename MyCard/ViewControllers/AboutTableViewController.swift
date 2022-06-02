//
//  AboutTableViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/06/02.
//

import UIKit

class AboutTableViewCell: UITableViewCell {
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class AboutTableViewController: UITableViewController {
    // MARK: - Properties
    let libraries = [
        ["Firebase  (FIrebaseAuth, Firestore)",
         "Copyright 2017-2022 Google",
         "Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at \n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License."]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aboutTableCell", for: indexPath) as! AboutTableViewCell

        let library = libraries[indexPath.row][0]
        let copyright = libraries[indexPath.row][1]
        let description = libraries[indexPath.row][2]

        cell.libraryLabel.text = library
        cell.libraryLabel.numberOfLines = 0
        
        cell.copyrightLabel.text = copyright
        cell.copyrightLabel.numberOfLines = 0
        
        cell.descriptionLabel.text = description
        cell.descriptionLabel.numberOfLines = 0

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
