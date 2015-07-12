
import UIKit

let kAppUseCachedUIKey = "useCachedUI"

class ViewController: UIViewController {

  
  @IBOutlet weak var containerView: InfinateCounterContainerView!
  @IBOutlet weak var infinateContainerView: InfinateContainerView!
  @IBOutlet weak var slider: UISlider!
  
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var infoLabel: UILabel!
  
  @IBAction func show(sender: UIButton) {
    infinateContainerView.imageWheel?.createWedgeImageViews()
    let sliderValue = Rotation(degrees: CGFloat(slider.value))
    infinateContainerView.imageWheel?.rotation = sliderValue
  }
  @IBAction func hide(sender: UIButton) {
    infinateContainerView.imageWheel?.removeWedgeImageViews()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    infoLabel.text = labelNumber.stringFromNumber(slider.value)
//    containerView.transform =
//          CGAffineTransformMakeRotation(Angle(degrees: -90 - 45).cgRadians)
    sliderChanged(slider)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  
  @IBAction func sliderChanged(sender: UISlider) {
//    updateWheel(sender)
    updateInfinateWheel(sender)
    updateCounterInfinateWheel(sender)
    infoLabel.text = labelNumber.stringFromNumber(sender.value)
  }
  
//  func updateWheel(sender: UISlider) {
//    let width = containerView.imageWheel!.wedgeWidthAngle
//    let halfWidth = Rotation(width / 2)
//    let sliderValue = Rotation(degrees: CGFloat(sender.value))
//    let rotationAngle = sliderValue - (width * 2) // + Rotation(degrees:360)
//    containerView.imageWheel?.rotation = rotationAngle
//  }
  
  func updateInfinateWheel(sender: UISlider) {
    let rotation = Rotation(degrees: CGFloat(sender.value))
    infinateContainerView.imageWheel?.rotation = rotation
  }
  
  func updateCounterInfinateWheel(sender: UISlider) {
    let rotation = Rotation(degrees: CGFloat(sender.value))
    containerView.imageWheel?.rotation = rotation
  }
  
  @IBAction func saveFramesButton(sender: UIButton) {
    progressBar.hidden = false
//    saveImageWheelFramesWithProgress() {
//        percentDone in
//        self.progressBar.progress = Float(percentDone)
//      }
  }
  

  
  
  
  
  
  
  
  
  
  

//  
//  func saveImageWheelFramesWithProgress(percentDone: (CGFloat) -> ()) {
//    let wheel         = containerView.imageWheel!
//    let infWheel         = infinateContainerView.imageWheel!
//    let anglePerImage = wheel.wedgeWidthAngle
//    let imageCount    = wheel.images.count
//    let totalRotation = anglePerImage * Angle(imageCount)
//    
//    let infAnglePerImage = infWheel.wedgeSeries.wedgeSeperation
//    let infImageCount    = infWheel.wedgeSeries.wedgeCount
//    let infTotalRotation = infAnglePerImage * Angle(infImageCount)
//    
//    let totalFrames    = 720 * 2
//    let anglePerFrame  = totalRotation / Angle(totalFrames)
//    let infAnglePerFrame  = infTotalRotation / Angle(totalFrames)
//    
//    for frame in 0..<totalFrames {
//      autoreleasepool {
//        let currentRotation = Rotation(anglePerFrame) * Rotation(frame)
//        let delay = Double(frame) * 2.0
//        wheel.rotation = currentRotation
//        self.snapshotCurrentFrame(frame)
//        percentDone(CGFloat(frame)/CGFloat(totalFrames))
//      }
//    }
//  }
//  
//  
//  
//  func snapshotCurrentFrame(frameNumber: Int) {
//    let paths = NSFileManager.defaultManager()
//                             .URLsForDirectory( .DocumentDirectory,
//                                    inDomains: .UserDomainMask)
//    let path = paths.last as? NSURL
//    
//    if let path = path {
//      
//      if (frameNumber == 1) {
//        println(path)
//      }
//      let frameString = pad(frameNumber)
//      let path = path.URLByAppendingPathComponent("gavinWheel-\(frameString).png")
//      println(frameString)
//      
//      var image = takeSnapshotOfView(containerView)
//      let png   = UIImagePNGRepresentation(image)
//      if png != nil {
//        png.writeToURL(path, atomically: true)
//      }
//    }
//  }
//
//  func takeSnapshotOfView(view: UIView) -> UIImage {
//    let resolutionScale = CGFloat(1.0)
//    
//    var size = view.frame.size
//    var rect = view.frame
//    size.width  *= resolutionScale
//    size.height *= resolutionScale
//    rect.size   = size
//    rect.origin.x = 0
//    rect.origin.y = 0
//    
//    UIGraphicsBeginImageContext(size)
//    let ctx = UIGraphicsGetCurrentContext()
//    view.drawViewHierarchyInRect(rect, afterScreenUpdates:true)
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    return image
//  }

  
  
  
  
  
  
  lazy var padNumber: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 4
    numberFormater.maximumIntegerDigits  = 4
    numberFormater.minimumFractionDigits = 0
    numberFormater.maximumFractionDigits = 0
    numberFormater.positivePrefix = ""
    return numberFormater
    }()
  
  lazy var labelNumber: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 3
    numberFormater.maximumIntegerDigits  = 3
    numberFormater.minimumFractionDigits = 3
    numberFormater.maximumFractionDigits = 3
    numberFormater.positivePrefix = " "
    numberFormater.negativeFormat = "-"
    return numberFormater
    }()
  
  func pad(number: Int) -> String {
    var paddedNumber = " 1.000"
    if let numberString = padNumber.stringFromNumber(number) {
      paddedNumber = numberString
    }
    return paddedNumber
  }

}

