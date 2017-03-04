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
    
    let optionsArray = ["FILTERS","extraLight", "light", "dark", "regular", "prominent", "SHAPE", "square blurs", "circular blurs", "PHOTOS", "Camera", "Photo Album", "Save"]
    
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
        case 1, 2, 3, 4, 5:
            if delegate != nil {
                delegate?.blurIndex = indexPath.row - 1

                //delegate?.filterSelected(filterIndex: indexPath.row - 1)
            }
        case 7:
            if delegate != nil {
                delegate?.isSquared = true
//                delegate?.shapeSelected(isSquared: true)
            }
        case 8:
            if delegate != nil {
                delegate?.isSquared = false
//                delegate?.shapeSelected(isSquared: false)
            }
        case 10:
            if delegate != nil {
//                delegate?.shapeSelected(isSquared: false)
            }
        case 11:
            if delegate != nil {
//                delegate?.shapeSelected(isSquared: false)
            }
        default:
            break
        }
        dismiss(animated: true, completion: nil)
    }

}
