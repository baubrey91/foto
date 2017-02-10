import UIKit
import CoreImage

class ViewController: UIViewController {
    @IBOutlet weak var personPic: UIImageView!
    
    var xArray = [CGFloat]()
    var yArray = [CGFloat]()
    var widthArray = [CGFloat]()
    var heightArray = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personPic.image = UIImage(named: "face-2")
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
        
        for face in faces as! [CIFaceFeature] {

            //print("Found bounds are \(face.bounds)")
            
            // Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = personPic.bounds.size
            let scale = min(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height)
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            xArray.append(faceViewBounds.origin.x)
            yArray.append(faceViewBounds.origin.y)
            heightArray.append(faceViewBounds.width)
            widthArray.append(faceViewBounds.height)
            
            let faceBox = UIView(frame: faceViewBounds)

            faceBox.layer.borderWidth = 1
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            personPic.addSubview(faceBox)

            let button = UIButton()
            button.frame = (frame: CGRect(x: faceViewBounds.origin.x, y: faceViewBounds.origin.y, width: faceViewBounds.width, height: faceViewBounds.height))
            //button.backgroundColor = UIColor.clear
            button.setTitle("Name your Button ", for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            self.view.addSubview(button)
            
            if face.hasLeftEyePosition {
               // print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
               // print("Right eye bounds are \(face.rightEyePosition)")
            }
        }
    }
    
    func buttonAction(sender: UIButton!, x: Int) {
        
        sender.alpha = 0.5
        sender.backgroundColor = .lightGray

       /* let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
        let effectView:UIVisualEffectView = UIVisualEffectView (effect: darkBlur)
        effectView.frame = CGRect(x: sender.frame.minX, y: sender.frame.minY, width: (sender.frame.maxX - sender.frame.minX), height: (sender.frame.maxY - sender.frame.minY))
        personPic.addSubview(effectView)*/
    }
    
    func createBlur(){
        for i in 0..<xArray.count{
            let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
            let effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
            effectView.frame = CGRect(x: xArray[i], y: yArray[i], width: widthArray[i], height: heightArray[i])
            effectView.tag
            personPic.addSubview(effectView)
            
        }
    }
}

/*4 options
 1 - red hollow box
 2 - blurred box
 3 - black eye bars
 4 - clear
 
 make changes to button iteself?
 append dettected face values into array- creating another array of images
 */





