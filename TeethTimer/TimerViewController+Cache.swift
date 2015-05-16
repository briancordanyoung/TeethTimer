import AVFoundation
import UIKit


enum FrameState {
  case rendering
  case rendered(UIImage)
  case compressing
  case idle
}

struct SaveState {
  var frameState: FrameState = .idle
  var currentFrame: Int = 0
  var totalFrames:  Int = 0
  var startingRotation: CGFloat = 0
  var endingRotation:   CGFloat = 0
  var currentRotation:  CGFloat {
    let anglePerFrame = self.anglePerFrame
    let acculmulatedAngle = anglePerFrame * CGFloat(currentFrame - 1)
    let currentRotation: CGFloat
    if startingRotation > endingRotation {
      currentRotation = startingRotation - acculmulatedAngle
    } else {
      currentRotation = startingRotation + acculmulatedAngle
    }
    return currentRotation
  }
  
  var anglePerFrame: CGFloat {
    let totalRotation = abs(startingRotation - endingRotation)
    return totalRotation / CGFloat(totalFrames)
  }
  
  var completionHandler: () -> () = {}
  var timer: NSTimer?
  
  let padFormater: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 4
    numberFormater.maximumIntegerDigits  = 4
    numberFormater.minimumFractionDigits = 0
    numberFormater.maximumFractionDigits = 0
    numberFormater.positivePrefix = ""
    return numberFormater
    }()
  
  func pad(number: Int) -> String {
    var paddedNumber = "0000"
    if let numberString = padFormater.stringFromNumber(number) {
      paddedNumber = numberString
    }
    return paddedNumber
  }

  var isComplete: Bool {
    return currentFrame > totalFrames
  }
  
  var hasNotBegun: Bool {
    return totalFrames == 0
  }

  var assetWriter:   AVAssetWriter?
  var writerInput:   AVAssetWriterInput?
  var bufferAdapter: AVAssetWriterInputPixelBufferAdaptor?
  var videoSettings: [String:AnyObject]?
  var frameTime:     CMTime?
  
}



extension TimerViewController {
  
  func setupViewsBeforeRendering() {
    startPauseButton.hidden = true
    resetButton.hidden      = true
    timerLabel.hidden       = true
    saveFrameButton.hidden  = true
  }
  
  func resetViewsAfterRendering() {
    self.startPauseButton.hidden     = false
    self.resetButton.hidden          = false
    self.timerLabel.hidden           = false
    self.saveFrameButton.hidden      = false
    self.saveState.completionHandler = {}
  }
  
  // Method used to start the process of rendering and saving the UI
  func saveFrames() {
    if saveState.hasNotBegun {
      if let gavinWheel = gavinWheel, imageWheelView = imageWheelView {
        setupViewsBeforeRendering()
        setupSaveStateWith(gavinWheel, AndImageWheel: imageWheelView)
      } else {
        // Can't find the views needed to render!
      }
    }
  }
  
  func setupSaveStateWith(wheelControl: WheelControl,
              AndImageWheel imageWheel: ImageWheel) {
    
    saveState.completionHandler = resetViewsAfterRendering

    let wedgeWidthAngle     = imageWheel.wedgeWidthAngle
    let halfWedgeWidthAngle = wedgeWidthAngle / 2
    let workingRange        = (start: wheelControl.maximumRotation!,
                                 end: wheelControl.minimumRotation!)
                
    // The complete range (in radians) from the furthers point in each direction
    // the wheelControl may rotate.  Including the half a wedge width past
    // the minimum and maximum rotation points when dampening completely stops
    // the rotation.
    let range = expandRange(workingRange, ByAmount: halfWedgeWidthAngle)
    let radiansInRange  = abs(range.start - range.end)
    let degreesInRange  = Circle().radian2Degree(radiansInRange)
    let framesPerDegree = CGFloat(2)
    
    saveState.startingRotation = range.start
    saveState.endingRotation   = range.end
    saveState.totalFrames      = Int(degreesInRange * framesPerDegree)
    saveState.currentFrame     = 1
    
    wheelControl.rotationAngle = saveState.currentRotation
    
    saveState.timer = NSTimer.scheduledTimerWithTimeInterval( 0.01,
                                      target: self,
                                    selector: Selector("checkStateAndContinue"),
                                    userInfo: nil,
                                     repeats: true)
  }
  
  
  func checkStateAndContinue() {
    if saveState.isComplete {
      tearDownAndResetSaveState()
    } else {
      checkForNextStage()
    }
  }
  
  func checkForNextStage() {
    switch saveState.frameState {
      
      case .idle:
        renderViews()
      
      case .rendering:
        break // Do nothing.  We are waiting for an image to be rendered.
      
      case .rendered(let image):
        writeFrame(image)
      
      case .compressing:
        break // Do nothing. We are waiting until compressing is done and 
              // ready for another image.
    }
  }
  
  func renderViews() {
    saveState.frameState = .rendering
    var image = takeSnapshotOfView(self.view, WithResolutionScale: CGFloat(2.0))
    saveState.frameState = .rendered(image)
  }
  
  
  func writeFrame(image: UIImage) {
    // TODO: Save on background thread
    saveState.frameState = .compressing
    
    if let path = urlForFrame() {
      let png = UIImagePNGRepresentation(image)
      if png != nil {
        png.writeToURL(path, atomically: true)
      }
    } else {
      println("Error: Could not generate file path for frame")
    }
    
    saveState.currentFrame += 1
    gavinWheel?.rotationAngle = saveState.currentRotation
    saveState.frameState = .idle
  }
  
  func tearDownAndResetSaveState() {
    saveState.timer?.invalidate()
    saveState.completionHandler()
    saveState = SaveState()
  }

  // Helpers
  func urlForFrame() -> NSURL? {
    var url: NSURL?
    
    let frameNumber = saveState.currentFrame
    
    let paths = NSFileManager.defaultManager()
      .URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
    let path = paths.last as? NSURL
    
    if let path = path {
      if (frameNumber == 1) { println(path) }
      let frameString = saveState.pad(frameNumber)
      let frameName   = "gavinWheel-\(frameString).png"
      url = path.URLByAppendingPathComponent(frameName)
      println(frameString)
    }
    
    return url
  }

  private func expandRange(range: (start: CGFloat,end: CGFloat),
    ByAmount amount: CGFloat) -> (start: CGFloat,end: CGFloat) {
      
      var resultingRange = range
      if range.start > range.end {
        resultingRange.start += amount
        resultingRange.end   -= amount
      } else {
        resultingRange.start -= amount
        resultingRange.end   += amount
      }
      return resultingRange
  }

}
