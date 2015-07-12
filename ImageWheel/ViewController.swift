
import UIKit

let kAppUseCachedUIKey = "useCachedUI"

class ViewController: UIViewController {

  var d = Developement()
  
  @IBOutlet weak var CCWContainerView: InfinateCounterContainerView!
  @IBOutlet weak var CWContainerView: InfinateContainerView!
  @IBOutlet weak var slider: UISlider!
  
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var infoLabel: UILabel!
  
  @IBAction func show(sender: UIButton) {
    CWContainerView.imageWheel?.createWedgeImageViews()
    let sliderValue = Rotation(degrees: CGFloat(slider.value))
    CWContainerView.imageWheel?.rotation = sliderValue
  }
  @IBAction func hide(sender: UIButton) {
    CWContainerView.imageWheel?.removeWedgeImageViews()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    infoLabel.text = labelNumber.stringFromNumber(slider.value)
    sliderChanged(slider)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  
  
  @IBAction func sliderChanged(sender: UISlider) {
    updateClockwiseWheel(sender)
    updateCounterClockwiseWheel(sender)
    infoLabel.text = labelNumber.stringFromNumber(sender.value)
//    print(" CW  "); printRotationStateForImageWheel(CWContainerView.imageWheel)
//    print("    ||||     CCW "); printRotationStateForImageWheel(CCWContainerView.imageWheel)
//    println("")
//    printRotationStateMinMaxForImageWheel(CCWContainerView.imageWheel)
  }
  
  
  func printRotationStateForImageWheel(wheel: InfiniteImageWheel?) {
    if let s = wheel?.rotationState {
      
      var msg = ""
//      //      msg += "min: \(d.pd(s.minimumRotationWithinWedgeSeries)) "
//      msg += "rot: \(d.pd(s.rotation))   "
//      //      msg += "max:\(d.pd(s.maximumRotationWithinWedgeSeries)) "
//      msg += "cnt: \(d.pd(s.wedgeCenter))   "
//      msg += "idx: \(d.pi2(s.wedgeIndex))   "
//      msg += "nidx: \(d.pi2(s.wedgeIndexNeighbor))   "
////      msg += " \(s.polarity)"
////      msg += "off: \(d.pd(s.offsetFromWedgeCenter))   "
////      msg += "off: \(s.directionRotatedOffWedgeCenter)   "
////      msg += "lay: \(s.layoutDirection)   "
      
      
      print("\(msg)")
    }
  }
  
  
  
  func printRotationStateMinMaxForImageWheel(wheel: InfiniteImageWheel?) {
    if let s = wheel?.rotationState {
      
      var msg = ""
//      msg += "Series Mult: \(d.pi(s.wedgeSeriesMultiplier))   "
//      msg += "Rot Count: \(d.pi(s.rotationCount))   "
//      msg += "w: \(d.pd4(s.seriesWidth))   "
//      msg += "Com: \(d.pd4(s.distanceOfCompleteRotations))   "
//      msg += "WedgeCount: \(d.pi(s.countOfWedgesInRemainder))   "
      msg += "  |   "
      msg += "min: \(d.pd4(s.minimumRotationWithinWedgeSeries))  <-  "
      msg += "rot: \(d.pd4(s.rotation)) "
      msg += "(\(d.pd4(s.wedgeCenter)))"
      msg += "  ->  max: \(d.pd4(s.maximumRotationWithinWedgeSeries)) "
      
      println("\(msg)")
    }
  }
  
  
  
  func updateClockwiseWheel(sender: UISlider) {
    let rotation = Rotation(degrees: CGFloat(sender.value))
    CWContainerView.imageWheel?.rotation = rotation
    let transformAngle = CGFloat(Angle(rotation))
    CWContainerView.transform = CGAffineTransformMakeRotation(transformAngle)
  }
  
  func updateCounterClockwiseWheel(sender: UISlider) {
    let rotation = Rotation(degrees: CGFloat(sender.value))
    CCWContainerView.imageWheel?.rotation = rotation
    let transformAngle = CGFloat(Angle(rotation))
    CCWContainerView.transform = CGAffineTransformMakeRotation(transformAngle)
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
//    let wheel         = CCWContainerView.imageWheel!
//    let infWheel         = CWContainerView.imageWheel!
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
//      var image = takeSnapshotOfView(CCWContainerView)
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

}

