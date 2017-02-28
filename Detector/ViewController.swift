import UIKit
import CoreImage

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, filterDelegate {
    @IBOutlet weak var personPic: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    
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
        
        let ratio = self.personPic.bounds.height / self.view.bounds.height
        let ratio2 =  self.view.bounds.height / self.personPic.bounds.height


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
            print(viewSize.width)
            print(ciImageSize.width)
            print(viewSize.height)
            print(ciImageSize.height)
            let scale = min(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height)
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2 //1.1 0.5
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            print("viewwidth : \(viewSize.width)")
            print("viewheight : \(viewSize.height)")
            print("CIwidth : \(ciImageSize.width)")
            print("CIheight : \(ciImageSize.height)")

            print(UIScreen.main.bounds.size.width)
            
            xArray.append(faceViewBounds.origin.x)
            yArray.append(faceViewBounds.origin.y)
            heightArray.append(faceViewBounds.width)
            widthArray.append(faceViewBounds.height)
            rightEyeArray.append(face.rightEyePosition)
            leftEyeArray.append(face.leftEyePosition)
            
            let faceBox = UIView(frame: faceViewBounds)

            faceBox.layer.borderWidth = 1
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            faceBox.tag = i
            personPic.addSubview(faceBox)

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
        
        for v in views {
            if v.tag == currentFace {
                v.effect = blurColor
                v.backgroundColor = UIColor.gray
                v.layer.opacity = opacity
                v.layer.cornerRadius = v.frame.size.width/2
            }
        }
    }
    
    func createBlur(){
        for i in 0..<xArray.count{
            let effectView:UIVisualEffectView = UIVisualEffectView(effect: blurColor)
            effectView.frame = CGRect(x: xArray[i], y: yArray[i], width: widthArray[i], height: heightArray[i])
            effectView.layer.cornerRadius = effectView.frame.size.width/2
            effectView.clipsToBounds = true
            effectView.tag = i
            effectView.isHidden = true
            personPic.addSubview(effectView)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            if let popoverTBC = segue.destination as? FiltersTableView{
                popoverTBC.preferredContentSize = CGSize(width: 200, height: 300)
                popoverTBC.referencedButton = sender as! UIButton
                popoverTBC.delegate = self
                popoverTBC.popoverPresentationController?.delegate = self
            }
        }
    }
    
    func filterSelected(button: UIButton, filter: String, filterIndex: Int) {
        filterButton.setTitle(filter, for: .normal)
        blurColor = blurArray[filterIndex]
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @IBAction func opacitySlider(_ sender: UISlider) {
        opacity = sender.value
        blurFace()
    }
}




