
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var containerView: ContainerView!
  
  @IBOutlet weak var slider: UISlider!
  
  @IBOutlet weak var progressBar: UIProgressView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  @IBAction func sliderChanged(sender: UISlider) {
    let width = containerView.imageWheel!.wedgeWidthAngle
    containerView.imageWheel?.rotationAngle = Circle().DegreesToRadians(CGFloat(sender.value)) + (width / 2)
  }
  
  @IBAction func saveFramesButton(sender: UIButton) {
    progressBar.hidden = false
    saveImageWheelFramesWithProgress() {
        percentDone in
        self.progressBar.progress = Float(percentDone)
      }
//    progressBar.hidden = true
  }
  


  
  func saveImageWheelFramesWithProgress(percentDone: (CGFloat) -> ()) {
    let wheel         = containerView.imageWheel!
    let anglePerImage = wheel.wedgeWidthAngle
    let imageCount    = wheel.images.count
    let totalRotation = anglePerImage * CGFloat(imageCount)
    
    let totalFrames    = 720 * 2
    let anglePerFrame  = totalRotation / CGFloat(totalFrames)
    
//    for frame in 0..<totalFrames {
//      let currentRotation = anglePerFrame * CGFloat(frame)
//      wheel.rotationAngle = currentRotation
//      self.snapshotCurrentFrame(frame)
//      percentDone(CGFloat(frame/totalFrames))
//    }
    
//    Apply.background(totalFrames) { frame in
//      let currentRotation = anglePerFrame * CGFloat(frame)
//      let delay = Double(frame) * 2.0
//      Async.main(after: delay) {
//        wheel.rotationAngle = currentRotation
//        self.snapshotCurrentFrame(frame)
//        percentDone(CGFloat(frame)/CGFloat(totalFrames))
//      }
//    }

    for frame in 0..<totalFrames {
      autoreleasepool {
        let currentRotation = anglePerFrame * CGFloat(frame)
        let delay = Double(frame) * 2.0
        wheel.rotationAngle = currentRotation
        self.snapshotCurrentFrame(frame)
        percentDone(CGFloat(frame)/CGFloat(totalFrames))
      }
    }
  }
  
  
  
  func snapshotCurrentFrame(frameNumber: Int) {
    let paths = NSFileManager.defaultManager()
                             .URLsForDirectory( .DocumentDirectory,
                                    inDomains: .UserDomainMask)
    let path = paths.last as? NSURL
    
    if let path = path {
      
      if (frameNumber == 1) {
        println(path)
      }
      let frameString = pad(frameNumber)
      let path = path.URLByAppendingPathComponent("gavinWheel-\(frameString).png")
      println(frameString)
      
      var image = self.takeSnapshotOfView(self.containerView)
      let png   = UIImagePNGRepresentation(image)
      if png != nil {
        png.writeToURL(path, atomically: true)
      }
    }
  }

  func takeSnapshotOfView(view: UIView) -> UIImage {
    let resolutionScale = CGFloat(1.0)
    
    var size = view.frame.size
    var rect = view.frame
    size.width  *= resolutionScale
    size.height *= resolutionScale
    rect.size   = size
    rect.origin.x = 0
    rect.origin.y = 0
    
    UIGraphicsBeginImageContext(size)
    let ctx = UIGraphicsGetCurrentContext()
    view.drawViewHierarchyInRect(rect, afterScreenUpdates:true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  lazy var padNumber: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 4
    numberFormater.maximumIntegerDigits  = 4
    numberFormater.minimumFractionDigits = 0
    numberFormater.maximumFractionDigits = 0
    numberFormater.positivePrefix = ""
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

