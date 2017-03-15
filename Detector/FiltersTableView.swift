import UIKit

protocol optionsDelegate {
    var blurIndex: Int {get set}
    var isSquared: Bool {get set}
    func takePhoto()
    func getSavedImage()
    func screenShotMethod()
}

class FiltersTableView: UITableViewController {
    
    let optionsArray = ["ExtraLight", "Light", "Dark", "Regular", "Prominent", "Square Blurs", "Circular Blurs", "Take Photo", "Import Photo", "Save"]
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


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = optionsArray[indexPath.row]
        switch indexPath.row {
        case 5,6:
            cell.backgroundColor = UIColor(red: 195.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        case 7, 8, 9:
            cell.backgroundColor = UIColor(red: 195.0/255.0, green: 255.0/255.0, blue: 193.0/255.0, alpha: 1.0)
        default:
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 224.0/255.0, blue: 193.0/255.0, alpha: 1.0)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0, 1, 2, 3, 4:
            if delegate != nil {
                delegate?.blurIndex = indexPath.row - 1}
            dismiss(animated: true, completion: nil)

        case 5:
            if delegate != nil {
                delegate?.isSquared = true}
            dismiss(animated: true, completion: nil)

        case 6:
            if delegate != nil {
                delegate?.isSquared = false}
            dismiss(animated: true, completion: nil)

        case 7:
            dismiss(animated: true, completion: nil)
            if delegate != nil {
                delegate?.takePhoto()}
        case 8:
            dismiss(animated: true, completion: nil)
            if delegate != nil {
                delegate?.getSavedImage()}
           // dismiss(animated: true, completion: nil)

        default:
            if delegate != nil {
                delegate?.screenShotMethod()}
         //   dismiss(animated: true, completion: nil)

        }
    }

}
