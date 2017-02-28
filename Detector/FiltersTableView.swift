//
//  FiltersTableView.swift
//  Detector
//
//  Created by Brandon on 2/27/17.
//  Copyright © 2017 Gregg Mojica. All rights reserved.
//

import UIKit

protocol filterDelegate {
    func filterSelected(button: UIButton, filter: String, filterIndex: Int)
}

class FiltersTableView: UITableViewController {
    
    let filtersArray = ["extraLight", "light", "dark", "regular", "prominent"]
    
    var delegate: filterDelegate? = nil
    var referencedButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filtersArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            delegate?.filterSelected(button: referencedButton, filter: filtersArray[indexPath.row], filterIndex: indexPath.row)
        }
        dismiss(animated: true, completion: nil)
    }

}
