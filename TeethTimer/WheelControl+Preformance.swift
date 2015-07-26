import UIKit


// Unfinished Class
// Stated writing this to measure animation fps
// but something is not working correctly
//
// Include this in the WheelControl as a stat property and use this pattern
// where the wheel is being transformed or rotationState is changed
//
//      stats.incrementFrame()
//      if let msg = stats.descriptionMessage {
//        println(msg)
//      }



extension WheelControl {

  struct PreformanceStats: Printable {
    
    var last61FrameTimes: [NSDate] = []
    
    init() {
      last61FrameTimes = []
    }
    
    // Check Time and add to the array of the last 60 checks
    mutating func incrementFrame() {
      let now = NSDate()
      var timeSincePrevious = NSTimeInterval(Double.infinity)
      if let previous = last61FrameTimes.last {
        timeSincePrevious = now.timeIntervalSinceDate(previous)
      }
      
      // If the previous frame was more than 4 seconds ago,
      // reset the previous saved times and start over.
      if timeSincePrevious > 4 {
        resetFrameTimes()
      }
      
      rememberFrameTime(now)
    }

    mutating func resetFrameTimes() {
      last61FrameTimes.removeAll()
    }
    
    // Add the current time (NSDate) to the array of the last 61 checks
    mutating func rememberFrameTime( time: NSDate ) {
      if last61FrameTimes.count >= 60 {
        last61FrameTimes.removeAtIndex(0)
      }
      last61FrameTimes.append(time)
    }
    
    var fps: Int? {
      
      
      if last61FrameTimes.count >= 2 {
        let previous        = last61FrameTimes[last61FrameTimes.count - 1]
        let beforeThat      = last61FrameTimes[last61FrameTimes.count - 2]
        let interval        = previous.timeIntervalSinceDate(beforeThat)
        let fps             = Int(floor(1.0 / interval))
        return fps
      } else {
        return .None
      }
    }
    
    // Calculate the fps from the array of 60 frames
    var averageTimeInterval: NSTimeInterval? {
      if last61FrameTimes.count < 2 {
        return .None
      }
      
      var lastSixtyIntervals: [NSTimeInterval] = []
      for i in 1..<last61FrameTimes.count {
        let aFrame     = last61FrameTimes[i]
        let bFrame     = last61FrameTimes[i - 1]
        let difference = aFrame.timeIntervalSinceDate(bFrame)
        lastSixtyIntervals.append(difference)
      }
      
      let total   = lastSixtyIntervals.reduce(0, combine: {$0 + $1})
      let average = total / Double(lastSixtyIntervals.count)
      return average
    }
    

    var averageFPS: Int? {
      if let averageTimeInterval = averageTimeInterval {
        let fps = Int(floor(1.0 / averageTimeInterval))
        return fps
      } else {
        return .None
      }
    }
    
    
    // String representations
    
    
    var description: String {
      if let message = descriptionMessage {
        return message
      } else {
        return "Not enough data to report fps"
      }
    }
    
    var descriptionMessage: String? {
      var msg: String?
      if let fps = fps {
        if let averageFPS = averageFPS {
          msg = "Current FPS: \(pad(fps))  Avarage FPS: \(pad(averageFPS)) "
        } else {
          msg = "Current FPS: \(pad(fps)) "
        }
      }
      return msg
    }
    
    let formatter: NSNumberFormatter = {
      let numberFormater = NSNumberFormatter()
      numberFormater.formatWidth           = 3
      numberFormater.minimumIntegerDigits  = 1
      numberFormater.maximumIntegerDigits  = 3
      numberFormater.minimumFractionDigits = 0
      numberFormater.maximumFractionDigits = 0
      numberFormater.paddingCharacter      = " "
      numberFormater.positivePrefix = ""
      return numberFormater
      }()

    func pad(n:Int) -> String {
      if let stringOfN = formatter.stringFromNumber(n) {
        return stringOfN
      } else {
        return "???"
      }
    }
  }
}