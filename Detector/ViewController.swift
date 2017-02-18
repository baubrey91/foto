import UIKit
import CoreImage

class ViewController: UIViewController {
    @IBOutlet weak var personPic: UIImageView!
    
    var xArray = [CGFloat]()
    var yArray = [CGFloat]()
    var widthArray = [CGFloat]()
    var heightArray = [CGFloat]()
    var rightEyeArray = [CGPoint]()
    var leftEyeArray = [CGPoint]()
    
    let extraLight = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
    let light = UIBlurEffect(style: UIBlurEffectStyle.light)
    let dark = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let regular = UIBlurEffect(style: UIBlurEffectStyle.regular)
    let prominent = UIBlurEffect(style: UIBlurEffectStyle.prominent)

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
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
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
            
            print(leftEyeArray)
            
            let faceBox = UIView(frame: faceViewBounds)

            /*faceBox.layer.borderWidth = 1
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            faceBox.tag = i
            personPic.addSubview(faceBox)*/

            let button = UIButton()
            button.frame = (frame: CGRect(x: faceViewBounds.origin.x, y: faceViewBounds.origin.y, width: faceViewBounds.width, height: faceViewBounds.height))
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
        //if subview exist -remove
        //else create
        /*let views = personPic.subviews as! [UIVisualEffectView]
        //let views = personPic.subviews
        /*for v in personPic.subviews {
            if v.tag == sender.tag {
                v.removeFromSuperview()
            }
            else {
                let effectView:UIVisualEffectView = UIVisualEffectView (effect: dark)
                effectView.frame = CGRect(x: xArray[sender.tag], y: yArray[sender.tag], width: widthArray[sender.tag], height: heightArray[sender.tag])
                effectView.layer.cornerRadius = effectView.frame.size.width/2
                effectView.clipsToBounds = true
                effectView.tag = sender.tag
                effectView.isHidden = false
                personPic.addSubview(effectView)
                
            }
        }*/
        
        for v in views {
            if v.tag == sender.tag {
                if v.isHidden{
                    v.effect = blurColor
                    v.isHidden = false
                    v.backgroundColor = UIColor.gray
                    v.layer.opacity = opacity
                    v.layer.cornerRadius = v.frame.size.width/2
                    
                    //v.isHidden =  v.isHidden ? false : true
                }
                else {
                    v.isHidden = true
                    
                    /*let effectView:UIVisualEffectView = UIVisualEffectView (effect: light)
                     effectView.frame = CGRect(x: xArray[sender.tag], y: yArray[sender.tag], width: widthArray[sender.tag], height: heightArray[sender.tag])
                     effectView.layer.cornerRadius = effectView.frame.size.width/2
                     effectView.clipsToBounds = true
                     
                     effectView.tag = sender.tag
                     //effectView.isHidden = true
                     personPic.addSubview(effectView)*/
                }
            }
        }
        
        //sender.alpha = 0.5
        //sender.backgroundColor = .lightGray
        
        /* let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
         let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
         let effectView:UIVisualEffectView = UIVisualEffectView (effect: darkBlur)
         effectView.frame = CGRect(x: sender.frame.minX, y: sender.frame.minY, width: (sender.frame.maxX - sender.frame.minX), height: (sender.frame.maxY - sender.frame.minY))
         personPic.addSubview(effectView)*/*/
    }
    
    func blurFace() {
        let views = personPic.subviews as! [UIVisualEffectView]
        //let views = personPic.subviews
        /*for v in personPic.subviews {
         if v.tag == sender.tag {
         v.removeFromSuperview()
         }
         else {
         let effectView:UIVisualEffectView = UIVisualEffectView (effect: dark)
         effectView.frame = CGRect(x: xArray[sender.tag], y: yArray[sender.tag], width: widthArray[sender.tag], height: heightArray[sender.tag])
         effectView.layer.cornerRadius = effectView.frame.size.width/2
         effectView.clipsToBounds = true
         effectView.tag = sender.tag
         effectView.isHidden = false
         personPic.addSubview(effectView)
         
         }
         }*/
        
        for v in views {
            if v.tag == currentFace {
                //if v.isHidden{
                    v.effect = blurColor
                    //v.isHidden = false
                    v.backgroundColor = UIColor.gray
                    v.layer.opacity = opacity
                    v.layer.cornerRadius = v.frame.size.width/2
                    
                    //v.isHidden =  v.isHidden ? false : true
               // }
               // else {
               //     v.isHidden = true
                //}
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
        
        
       /* for i in 0..<xArray.count{
            let effectView:UIVisualEffectView = UIVisualEffectView (effect: dark)
            print(leftEyeArray[i].x)
            effectView.frame = CGRect(x: leftEyeArray[i].x-200, y: yArray[i], width: widthArray[i], height: heightArray[i])
            
            effectView.tag = i
            effectView.isHidden = true
            personPic.addSubview(effectView)
        }*/
    }
    
    @IBAction func extraLight(_ sender: Any) {
        blurColor = extraLight
    }
    
    @IBAction func light(_ sender: Any) {
        blurColor = light

    }
    
    @IBAction func Dark(_ sender: Any) {
        blurColor = dark

    }
    
    @IBAction func regular(_ sender: Any) {
        blurColor = regular
        
    }
    
    @IBAction func prominent(_ sender: Any) {
        blurColor = prominent
    }
    
    @IBAction func opacitySlider(_ sender: UISlider) {
        print(sender.value)
        opacity = sender.value
        blurFace()
    }
    
}

/*4 options
 1 - red hollow box
 2 - blurred box
 3 - black eye bars
 4 - clear
 
 make changes to button iteself?
 append dettected face values into array- creating another array of images
 make array if image views????
 */
/*d
profilePictureView.clipsToBounds = true

profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
profilePictureView.layer.borderWidth = 5.0*/




