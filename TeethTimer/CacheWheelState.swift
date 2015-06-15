import AVFoundation
import UIKit

typealias CompletionHandler = () -> ()

enum FrameState {
  case idle
  case rendered(UIImage)
  case writing
}

struct CacheWheelState {
  var frameState: FrameState = .idle
  var currentFrame: Int = 0
  var totalFrames:  Int = 0
  var startingRotation: Rotation = 0
  var endingRotation:   Rotation = 0
  
  var currentRotation:  Rotation {
    let anglePerFrame = self.anglePerFrame
    let acculmulatedAngle = anglePerFrame * Rotation(currentFrame - 1)
    let currentRotation: Rotation
    if startingRotation > endingRotation {
      currentRotation = startingRotation - acculmulatedAngle
    } else {
      currentRotation = startingRotation + acculmulatedAngle
    }
    return currentRotation
  }
  
  var anglePerFrame: Rotation {
    let totalRotation = abs(startingRotation - endingRotation)
    return totalRotation / Rotation(totalFrames)
  }
  
  var completionHandler: () -> () = {}
  var timer: NSTimer?
  
  var movieMaker: MovieMaker?
  
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
  
}


