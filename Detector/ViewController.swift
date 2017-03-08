import UIKit
import CoreImage

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var personPic: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterBottomButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    var xArray          = [CGFloat]()
    var yArray          = [CGFloat]()
    var widthArray      = [CGFloat]()
    var heightArray     = [CGFloat]()
    var rightEyeArray   = [CGPoint]()
    var leftEyeArray    = [CGPoint]()
    
    let blurArray = [UIBlurEffect(style: UIBlurEffectStyle.extraLight),
                     UIBlurEffect(style: UIBlurEffectStyle.light),
                     UIBlurEffect(style: UIBlurEffectStyle.dark),
                     UIBlurEffect(style: UIBlurEffectStyle.regular),
                     UIBlurEffect(style: UIBlurEffectStyle.prominent)]

    var blurColor:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
    var opacity:Float = 1.0
    var currentFace =   0
    var blurIndex =     0
    var isSquared =     false
    var faceBox =       false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personPic.image = UIImage(named: "stock")
        detect()
        createBlur()
    }
    
    func detect() {
        
        guard let personciImage = CIImage(image: personPic.image!) else {
            return
        }

        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage)

        // For converting the Core Image Coordinates to UIView Coordinates
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        var index = 0
        
        for face in faces as! [CIFaceFeature] {

            //print("Found bounds are \(face.bounds)")
            
            // Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = personPic.bounds.size

            let scale = min(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height)
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2 //1.1 0.5
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            xArray.append(faceViewBounds.origin.x)
            yArray.append(faceViewBounds.origin.y)
            heightArray.append(faceViewBounds.width)
            widthArray.append(faceViewBounds.height)
            rightEyeArray.append(face.rightEyePosition)
            leftEyeArray.append(face.leftEyePosition)
            
            if faceBox {
                let faceBox = UIView(frame: faceViewBounds)
                
                faceBox.layer.borderWidth = 1
                faceBox.layer.borderColor = UIColor.red.cgColor
                faceBox.backgroundColor = UIColor.clear
                faceBox.tag = index
                personPic.addSubview(faceBox)
            } else {
                
                let button = UIButton()
                button.frame = (frame: faceViewBounds)
                //button.backgroundColor = UIColor.clear
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                button.tag = index
                button.setTitle("", for: .normal)
                //button.isHidden = true
                self.view.addSubview(button)
                
                index += 1
            }
        }
    }
    
    func buttonAction(sender: UIButton!, x: Int) {
        currentFace = sender.tag
        blurFace()
        
        for v in personPic.subviews {
            if v.tag == sender.tag {
                v.isHidden = (v.isHidden) ? false : true
            }
        }
    }
    
    func blurFace() {
        let views = personPic.subviews as! [UIVisualEffectView]
        let blurColor = blurArray[blurIndex]
        for v in views {
            if v.tag == currentFace {
                v.effect = blurColor
                v.backgroundColor = UIColor.gray
                v.layer.opacity = opacity
                if !isSquared {
                    v.layer.cornerRadius = v.frame.size.width/2
                    v.clipsToBounds = true
                } else {
                    v.layer.cornerRadius = v.frame.size.width
                    v.clipsToBounds = false
                }
            }
        }
    }
    
    func createBlur(){
        for i in 0..<xArray.count{
            let effectView:UIVisualEffectView = UIVisualEffectView(effect: blurColor)
            effectView.frame = CGRect(x: xArray[i], y: yArray[i], width: widthArray[i], height: heightArray[i])
            /*effectView.layer.cornerRadius = effectView.frame.size.width/2
            effectView.clipsToBounds = true*/
            effectView.tag = i
            effectView.isHidden = true
            personPic.addSubview(effectView)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            if let popoverTBC = segue.destination as? FiltersTableView{
                popoverTBC.preferredContentSize = CGSize(width: 175, height: 450)
                popoverTBC.delegate = self
                popoverTBC.popoverPresentationController?.delegate = self
            }
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        dismiss(animated: true)
    
        let views = personPic.subviews as! [UIVisualEffectView]
        
        for v in views {
            v.removeFromSuperview()
        }
        personPic.image = image
        detect()
        createBlur()
    }
    
    func takeScreenShot(completionHandler: @escaping (Bool) -> ()){
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        completionHandler(true)
        }

    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @IBAction func opacitySlider(_ sender: UISlider) {
        opacity = sender.value
        blurFace()
    }

}

extension ViewController: optionsDelegate {
    
    func getSavedImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func screenShotMethod() {
        self.toolBar.isHidden = true
        takeScreenShot(completionHandler: {_ in
            self.toolBar.isHidden = false
            let alertController = UIAlertController(title: "YAY", message: "Photo has been saved to phone?", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "DONE", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
    }
//    func faceBoxFunction() {
//        for v in personPic.subviews{
//            v.removeFromSuperview()
//        }
//        faceBox = !faceBox
//        detect()
//        createBlur()
//    }
}




