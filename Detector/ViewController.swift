import UIKit
import CoreImage

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, optionsDelegate {
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
    var currentFace = 0
    var blurIndex = 0
    var isSquared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personPic.image = UIImage(named: "face-5")
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
        
        var i = 0
        
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
            
            let faceBox = UIView(frame: faceViewBounds)
//
//            faceBox.layer.borderWidth = 1
//            faceBox.layer.borderColor = UIColor.red.cgColor
//            faceBox.backgroundColor = UIColor.clear
//            faceBox.tag = i
//            personPic.addSubview(faceBox)

            let button = UIButton()
            button.frame = (frame: faceViewBounds)
            //button.backgroundColor = UIColor.clear
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.tag = i
            button.setTitle("", for: .normal)
            //button.isHidden = true
            self.view.addSubview(button)
            
            if face.hasLeftEyePosition {
               // print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
               // print("Right eye bounds are \(face.rightEyePosition)")
            }
            i += 1
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
    @IBAction func camera(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)

    }
    
    func getSavedImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func screenShotMethod() {
        self.toolBar.layer.backgroundColor = UIColor.clear.cgColor
        //self.
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
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
        
        //let beginImage = CIImage(image: currentImage)
        //currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        //applyProcessing()
    }
    
    
    
//    func filterSelected(filterIndex: Int) {
//        print(filterIndex)
//        blurColor = blurArray[filterIndex]
//    }
//    
//    func shapeSelected(isSquared: Bool) {
//        isSquare = isSquared
//    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @IBAction func opacitySlider(_ sender: UISlider) {
        opacity = sender.value
        blurFace()
    }

}




