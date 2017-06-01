import UIKit
import CoreImage

public class CustomCell: LiquidFloatingCell {
    var name: String = "sample"
    
    init(icon: UIImage, name: String) {
        self.name = name
        super.init(icon: icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setupView(_ view: UIView) {
        super.setupView(view)
        let label = UILabel()
        label.text = name
        label.textColor = UIColor.darkGray
        label.font = UIFont(name: "Helvetica-Neue", size: 10)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.right.equalTo(self).offset(80)
            make.width.equalTo(75)
            make.top.height.equalTo(self)
        }
    }
}

public class CustomDrawingActionButton: LiquidFloatingActionButton {
    
    override public func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
        
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = kCALineCapRound
        plusLayer.strokeColor = UIColor.white.cgColor
        plusLayer.lineWidth = 3.0
        
        let w = frame.width
        let h = frame.height
        
        let points = [
            (CGPoint(x: w * 0.25, y: h * 0.35), CGPoint(x: w * 0.75, y: h * 0.35)),
            (CGPoint(x: w * 0.25, y: h * 0.5), CGPoint(x: w * 0.75, y: h * 0.5)),
            (CGPoint(x: w * 0.25, y: h * 0.65), CGPoint(x: w * 0.75, y: h * 0.65))
        ]
        
        let path = UIBezierPath()
        for (start, end) in points {
            path.move(to: start)
            path.addLine(to: end)
        }
        
        plusLayer.path = path.cgPath
        
        return plusLayer
    }
}

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var personPic: UIImageView!
    @IBOutlet weak var opacitySlider: TNSlider!
    
    var xArray = [CGFloat]()
    var yArray = [CGFloat]()
    var widthArray = [CGFloat]()
    var heightArray = [CGFloat]()
    var rightEyeArray = [CGPoint]()
    var leftEyeArray = [CGPoint]()
    
    let blurArray = [UIBlurEffect(style: UIBlurEffectStyle.extraLight),
                     UIBlurEffect(style: UIBlurEffectStyle.light),
                     UIBlurEffect(style: UIBlurEffectStyle.dark),
                     UIBlurEffect(style: UIBlurEffectStyle.regular),
                     UIBlurEffect(style: UIBlurEffectStyle.prominent)]

    var blurColor: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
    //var imagePicker: UIImagePickerController!
    var opacity: Float = 1.0
    var currentFace = 0
    var blurIndex = 0
    var isSquared = false
    var faceBox = false
    
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!
    
    var floatingClipButton: SpiderButton!
    
    var floatingActionButtons: [UIButton] {
        let buttonFrame = CGRect(x: 0, y: 0, width: 66, height: 66)
        
        let camera = UIButton(frame: buttonFrame)
        camera.addTarget(self, action: #selector(takePhoto(_:)), for: .touchUpInside)
        camera.setImage(UIImage(named:"cbutton_camera"), for: .normal)
        camera.setImage(UIImage(named:"cbutton_camera-tap"), for: .highlighted)
        
        let album = UIButton(frame: buttonFrame)
        album.addTarget(self, action: #selector(importPhoto(_:)), for: .touchUpInside)
        album.setImage(UIImage(named:"cbutton_album"), for: .normal)
        album.setImage(UIImage(named:"cbutton_album_tapped"), for: .highlighted)

        
        let save = UIButton(frame: buttonFrame)
        save.addTarget(self, action: #selector(savePhoto(_:)), for: .touchUpInside)
        save.setImage(UIImage(named:"cbutton_pencil"), for: .normal)
        save.setImage(UIImage(named:"cbutton_pencil-tap"), for: .highlighted)
        
        return [camera, album, save]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttons = floatingActionButtons
        if buttons.count > 0 {
            addFloatingClip(for: buttons)
        }
        
        personPic.image = UIImage(named: "stock")
        detect()
        createBlur()
        setUpOptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // If floating clip button is needed and not part of the nav view hierarchy, add it.
        
        if floatingClipButton != nil &&
            navigationController != nil &&
            (floatingClipButton.isDescendant(of: navigationController!.view) == false) {
            
            addFloatingClip()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // If floating clip button is present, remove it from the nav view hierarchy before transitioning out
        if floatingClipButton != nil &&
            navigationController != nil &&
            floatingClipButton.isDescendant(of: navigationController!.view) {
            
            floatingClipButton.removeFromSuperview()
        }
    }

    
    func setUpOptions() {
        // self.view.backgroundColor = UIColor(red: 55 / 255.0, green: 55 / 255.0, blue: 55 / 255.0, alpha: 1.0)
        // Do any additional setup after loading the view, typically from a nib.
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = CustomDrawingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            let cell = LiquidFloatingCell(icon: UIImage(named: iconName)!)
            return cell
        }
        
        let customCellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            let cell = CustomCell(icon: UIImage(named: iconName)!, name: iconName)
            return cell
        }
        
        cells.append(customCellFactory("One"))//extraLight
        cells.append(customCellFactory("Two"))//Light
        cells.append(customCellFactory("Three"))//Dark
        cells.append(customCellFactory("Four"))//Regular
        cells.append(customCellFactory("Five"))//Prominent
        cells.append(customCellFactory("Square"))//Square
        cells.append(customCellFactory("Circle"))//Circular

        //let floatingFrame = CGRect(x: self.view.frame.width - 56 - 16, y: self.view.frame.height - 56 - 16, width: 56, height: 56)
        let optionsFrame = CGRect(x: 20, y: 20, width: 66, height: 66)
        let optionsButton = createButton(optionsFrame, .down)

        let image = UIImage(named: "ic_art")
        optionsButton.image = image
        
        //let topLeftButton = createButton(floatingFrame2, .down)
        self.view.addSubview(optionsButton)
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
        //let blurColor = blurArray[blurIndex]
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = (info[UIImagePickerControllerEditedImage] as? UIImage) else {
            let alertController = UIAlertController(title: "OH NO", message: "Something went wrong, please try again.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)

            dismiss(animated: true)
            return
        }
        
        dismiss(animated: true)
        let views = personPic.subviews as! [UIVisualEffectView]
 
        for v in views {
            v.removeFromSuperview()
        }
        personPic.image = image
        xArray = []
        yArray = []
        widthArray = []
        heightArray = []
        detect()
        createBlur()
    }
    
    func takeScreenShot(completionHandler: @escaping (Bool) -> ()) {
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
    
    func addFloatingClip(for buttons: [UIButton] = []) {
        // Frame position is hard set to mimic a clip over nav bar
        let floatingClipFrame = CGRect(x: view.bounds.size.width - 80, y: 20, width: 40, height: 40)
        
        if floatingClipButton == nil {
            floatingClipButton = SpiderButton(frame: floatingClipFrame, actionButtons:buttons)
        } else {
            floatingClipButton.frame = floatingClipFrame
        }
        // Add floating clip on nav controller's view
        view.addSubview(floatingClipButton)
    }
    
    @IBAction func opacitySlider(_ sender: TNSlider) {
        opacity = sender.value
        blurFace()
    }
    
    func takePhoto(_ sender: AnyObject) {
        let imagePicker =  UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func importPhoto(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func savePhoto(_ sender: AnyObject) {
        
        self.opacitySlider.isHidden = true
        
        self.floatingClipButton.isHidden = true
        self.floatingActionButton.isHidden = true
        //self.floatingClipButton.contentView.isHidden = true
        takeScreenShot(completionHandler: { _ in
            self.opacitySlider.isHidden = false
            self.floatingClipButton.isHidden = false
            self.floatingActionButton.isHidden = false

            let alertController = UIAlertController(title: "YAY", message: "Photo has been saved to phone!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "DONE", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
    }
}


extension ViewController: LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate {
    
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(_ index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        switch index {
        case 5:
            isSquared = false
        case 6:
            isSquared = true
        default:
            blurColor = blurArray[index]
        }
        liquidFloatingActionButton.close()
    }
}

