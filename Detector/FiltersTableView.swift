//
//  FiltersTableView.swift
//  Detector
//
//  Created by Brandon on 2/27/17.
//  Copyright © 2017 Gregg Mojica. All rights reserved.
//

import UIKit

protocol optionsDelegate {
    var blurIndex: Int {get set}
    var isSquared: Bool {get set}
}

class FiltersTableView: UITableViewController {
    
    let optionsArray = ["extraLight", "light", "dark", "regular", "prominent", "square blurs", "circular blurs", "Camera", "Photo Album", "Save"]
    //let optionsArray = ["FILTERS","extraLight", "light", "dark", "regular", "prominent", "SHAPE", "square blurs", "circular blurs", "PHOTOS", "Camera", "Photo Album", "Save"]
    
    var delegate: optionsDelegate? = nil
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
        return optionsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = optionsArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0, 1, 2, 3, 4:
            if delegate != nil {
                delegate?.blurIndex = indexPath.row - 1}
        case 5:
            if delegate != nil {
                delegate?.isSquared = true}
        case 6:
            if delegate != nil {
                delegate?.isSquared = false}
        case 7:
            if delegate != nil { }
        case 8:
            if delegate != nil { }
        default:
            break
        }
        dismiss(animated: true, completion: nil)
    }

}
