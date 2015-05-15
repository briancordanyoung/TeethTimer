import AVFoundation
import UIKit


struct SaveState: Printable {
  var saveFrameState: SaveFrameState = .idle
  var currentFrame: Int = 0
  var totalFrames:  Int = 0
  var startingRotation: CGFloat = 0
  var endingRotation:   CGFloat = 0
  var currentRotation:  CGFloat {
    let anglePerFrame = self.anglePerFrame
    let acculmulatedAngle = anglePerFrame * CGFloat(currentFrame)
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
  
  var completed: () -> () = {}
  var timer: NSTimer?
  
  var description: String {
    // TODO: add description
    return ""
  }
  
  var isComplete: Bool {
    return currentFrame >= totalFrames
  }
}

enum SaveFrameState {
  case saving
  case idle
}


extension TimerViewController {
  
  
  
  func saveFrames() {
    
    func expandRange(range: (start: CGFloat,end: CGFloat),ByAmount amount: CGFloat)
      -> (start: CGFloat,end: CGFloat) {
        
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
    
    if saveState.isComplete {
      startPauseButton.hidden = true
      resetButton.hidden      = true
      timerLabel.hidden       = true
      saveFrameButton.hidden  = true
      
      saveState.completed = { [weak self] in
        self?.startPauseButton.hidden = false
        self?.resetButton.hidden      = false
        self?.timerLabel.hidden       = false
        self?.saveFrameButton.hidden  = false
        self?.saveState.completed     = {}
      }
      
      if let gavinWheel = gavinWheel, imageWheelView = imageWheelView {
        let wedgeWidthAngle  = imageWheelView.wedgeWidthAngle
        let halfWedgeWidthAngle = wedgeWidthAngle / 2
        let wedgeDegrees     = Circle().radian2Degree(wedgeWidthAngle)
        let halfWedgeDegrees = wedgeDegrees / 2
        let workingRange     = (start: gavinWheel.maximumRotation!,
          end: gavinWheel.minimumRotation!)
        let range = expandRange(workingRange, ByAmount: halfWedgeWidthAngle)
        saveState.totalFrames      = (720 * 2) + Int(wedgeDegrees)
        //        saveState.totalFrames      = saveState.totalFrames / 8
        saveState.startingRotation = range.start
        saveState.endingRotation   = range.end
        
        gavinWheel.rotationAngle = saveState.currentRotation
        
        saveState.timer = NSTimer.scheduledTimerWithTimeInterval( 0.01,
          target: self,
          selector: Selector("snapshotCurrentFrameIfIdle"),
          userInfo: nil,
          repeats: true)
      }
    }
  }
  
  func snapshotCurrentFrameIfIdle() {
    if saveState.isComplete {
      saveState.timer?.invalidate()
      saveState.timer = nil
      saveState.completed()
      saveState = SaveState()
    } else if saveState.saveFrameState == .idle {
      snapshotCurrentFrame()
    }
  }
  
  func snapshotCurrentFrame() {
    saveState.saveFrameState = .saving
    let frameNumber = saveState.currentFrame

    var padNumber: NSNumberFormatter = {
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
    
    let paths = NSFileManager.defaultManager()
      .URLsForDirectory( .DocumentDirectory,
        inDomains: .UserDomainMask)
    let path = paths.last as? NSURL
    
    if let path = path {
      
      if (frameNumber == 0) { println(path) }
      let frameString = pad(frameNumber + 1)
      let path = path.URLByAppendingPathComponent("gavinWheel-\(frameString).png")
      println(frameString)
      
      var image = takeSnapshotOfView(self.view, WithResolutionScale: CGFloat(2.0))
      let png   = UIImagePNGRepresentation(image)
      if png != nil {
        png.writeToURL(path, atomically: true)
      }
    }
    
    //    let d = Developement()
    //    println("frame: \(pad(frameNumber))  rotation: \(d.pad(saveState.currentRotation))")
    
    saveState.currentFrame += 1
    gavinWheel?.rotationAngle = saveState.currentRotation
    saveState.saveFrameState = .idle
  }
}
