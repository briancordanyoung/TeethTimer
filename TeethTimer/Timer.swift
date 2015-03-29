import Foundation
import CoreGraphics

//static let kTimerDefaultsDurationKey = "defaultDurationInSeconds"



enum TimerVisiblity: String, Printable {
  case Visible = "Visible"
  case Hidden  = "Hidden"
  
  var description: String {
    return self.rawValue
  }
}

enum TimerStatus: String, Printable {
  case Ready      = "Ready"
  case Counting   = "Counting"
  case Paused     = "Paused"
  case Completed  = "Completed"
  
  var description: String {
    return self.rawValue
  }
}


class Timer: NSObject {
  
  // MARK: Properties
  var startTime:         NSTimeInterval?
  var previousStartTime: NSTimeInterval?
  var timerUUID:         String?
  
  var timerUpdateInterval   = NSTimeInterval(0.1)
  var elapsedTimeAtPause    = NSTimeInterval(0)
  var additionalElapsedTime = NSTimeInterval(0)
  
  var duration = NSTimeInterval(60 * 4) // 4 Minute Default
  var durationSetting: Int  {
    return NSUserDefaults.standardUserDefaults()
      .integerForKey("defaultDurationInSeconds")
  }
  
  var visibility: TimerVisiblity = .Visible
  var status:     TimerStatus    = .Ready
  
  
  var elapsedTime: NSTimeInterval {
    var _elapsedTime: NSTimeInterval
    if let start = previousStartTime {
      let now = NSDate.timeIntervalSinceReferenceDate()
      _elapsedTime = now - start + elapsedTimeAtPause
    } else {
      _elapsedTime = elapsedTimeAtPause
    }
    return _elapsedTime
  }
  
  var timeRemaining: NSTimeInterval {
    return (duration + additionalElapsedTime) - elapsedTime
  }
  
  
  // Properties that hold functions. (a.k.a. a block based API)
  // These should be used as call backs alerting a view controller
  // that one of these events occurred.
  var updateTimerWithText: (String) -> ()
  var updateUIControlText: (String) -> ()
  var updateTimerWithSeconds: (NSTimeInterval) -> ()
  var updateTimerWithPercentage: (CGFloat) -> ()
  
  
  
  // MARK: -
  // MARK: Init methods
  convenience override init() {
    // I couldn't figure out how to initilize a UIViewController
    // with the nessesary functions at the time the Timer
    // intance is created.  So, I made this convenience init which
    // creates these stand-in println() functions.  These should be
    // replaced in the timer class instance by the callbacks that
    // update any controls like a UIButton or UILabel in the UIViewController.
    func printControlText(controlText: String) {
      #if DEBUG
        println("Change Timer Control Text to: \(controlText)")
      #endif
    }
    
    func printTime(timeAsString: String) {
      #if DEBUG
        println("Time Left: \(timeAsString)")
      #endif
    }
    
    func printSeconds(timeAsSeconds: NSTimeInterval) {
      #if DEBUG
        println("Seconds left: \(timeAsSeconds)")
      #endif
    }
    
    func printPercentage(timeAsPercentage: CGFloat) {
      #if DEBUG
        println("Percentage left: \(timeAsPercentage)")
      #endif
    }
    
    self.init(WithControlTextFunc: printControlText,
               AndUpdateTimerFunc: printTime,
             AndUpdateSecondsFunc: printSeconds,
          AndUpdatePercentageFunc: printPercentage)
  }
  
  init( WithControlTextFunc  updateUIControlTextFunc: (String) -> (),
        AndUpdateTimerFunc           updateTimerFunc: (String) -> (),
        AndUpdateSecondsFunc       updateSecondsFunc: (NSTimeInterval) -> (),
        AndUpdatePercentageFunc updatePercentageFunc: (CGFloat) -> ()) {
          
    updateUIControlText       = updateUIControlTextFunc
    updateTimerWithText       = updateTimerFunc
    updateTimerWithSeconds    = updateSecondsFunc
    updateTimerWithPercentage = updatePercentageFunc
  }
    
  // MARK: Timer Actions
  func start() {
    status = .Counting
    previousStartTime = NSDate.timeIntervalSinceReferenceDate()
    if startTime == nil {
      startTime = previousStartTime
    }
    if timerUUID == nil {
      timerUUID = NSUUID().UUIDString
    }
    updateUIControlText("Pause")
    incrementTimer()
  }
  
  func pause() {
    status = .Paused
    updateUIControlText("Continue")
  }
  
  func pauseAfterDoneAndAddTime() {
    status = .Paused
    updateUIControlText("Continue")
    updateTimerTo(timeRemaining)
  }
  
  func reset() {
    startTime = nil
    previousStartTime = nil
    timerUUID = nil
    status = .Ready
    elapsedTimeAtPause = 0
    additionalElapsedTime = 0
    
    syncDurationSetting()
    
    updateTimerTo(duration)
    updateUIControlText("Start")
  }
  
  private func complete(elapsedTime: NSTimeInterval) {
    status = .Completed
    rememberTimerAtPause(elapsedTime)
    
    updateUIControlText("Done")
    updateTimerTo(0.0)
    
    println("original timer:        \(duration)")
    println("total running time:    \(elapsedTimeAtPause)")
    println("total additional time: \(additionalElapsedTime)")
  }
  
  
  func addTimeByPercentage(percentage: CGFloat) {
    // Don't use duration + additionalElapsedTime because
    // we only want to add a percentage of the original duration
    // without any additional seconds added
    let additionalSeconds = duration * NSTimeInterval(percentage)
    addTimeBySeconds(additionalSeconds)
  }
  
  func addTimeBySeconds(seconds: NSTimeInterval) {
    // Don't add sooo much to the timer that the time left
    // if more than the original duration
    additionalElapsedTime = additionalElapsedTime + seconds
    if additionalElapsedTime > elapsedTime {
      additionalElapsedTime = elapsedTime
    }
    
    if status != .Counting {
      updateTimerTo(timeRemaining)
    }
    
    if status == .Completed {
      pauseAfterDoneAndAddTime()
    }
  }
  
  // MARK: -
  // MARK: Visible State
  var hasStarted: Bool {
    var timerHasStarted = false
    if previousStartTime  != nil { timerHasStarted = true }
    if elapsedTimeAtPause != 0   { timerHasStarted = true }
    if status == .Counting       { timerHasStarted = true }
    return timerHasStarted
  }

  func transitionToHidden() {
    visibility = .Hidden
  }
  
  func transitionToVisible() {
    visibility = .Visible
    if hasStarted {
      incrementTimer()
    } else {
      reset()
    }
  }
  
  // MARK: -
  private func syncDurationSetting() {
    let durationSetting = self.durationSetting
    if (durationSetting != 0) {
      duration = NSTimeInterval(durationSetting)
    }
  }
  
  // MARK: Time Helper Methods
  private func timeStringFromMinutes(minutes: Int,
                          AndSeconds seconds: Int) -> String {
      return NSString(format: "%02i:%02i",minutes,seconds) as! String
  }
  
  private func timeStringFromDuration(duration: NSTimeInterval) -> String {
    let durationParts = timeAsParts(duration)
    return timeStringFromMinutes( durationParts.minutes,
                      AndSeconds: durationParts.seconds)
  }
  
  private func timeAsParts(elapsedTimeInterval: NSTimeInterval)
    -> (minutes: Int,seconds: Int) {
      var elapsedTime = elapsedTimeInterval
      let elapsedMinsTime = elapsedTime / 60.0
      let elapsedMins = Int(elapsedMinsTime)
      elapsedTime = elapsedMinsTime * 60
      let elapsedSecsTime = elapsedTime - (NSTimeInterval(elapsedMins) * 60)
      let elapsedSecs = Int(elapsedSecsTime)
      
      return (elapsedMins, elapsedSecs)
  }
  
  private func secondsToPercentage(secondsRemaining: NSTimeInterval) -> CGFloat {
    return CGFloat(secondsRemaining / duration)
  }
  
  private func updateTimerTo(timeRemaining: NSTimeInterval) {
    let percentageLeft = secondsToPercentage(timeRemaining)
    
    updateTimerWithPercentage(percentageLeft)
    updateTimerWithText(timeStringFromDuration(timeRemaining))
    updateTimerWithSeconds(timeRemaining)
  }
  
  
  // MARK: Timer
  private func rememberTimerAtPause(elapsedTime: NSTimeInterval) {
    previousStartTime = nil
    elapsedTimeAtPause = elapsedTime
  }
  
  private func incrementTimerAgain() {
    NSTimer.scheduledTimerWithTimeInterval( timerUpdateInterval,
                                    target: self,
                                  selector: Selector("incrementTimer"),
                                  userInfo: nil,
                                   repeats: false)
  }
  
  func incrementTimerCount() {
    if (elapsedTime > (duration + additionalElapsedTime)) {
      complete(elapsedTime)
    } else {
      updateTimerTo(timeRemaining)
      incrementTimerAgain()
    }
  }
  
  func incrementTimer() {
    
    // Stop updating the timer if the app or view controler is not visable
    if visibility == .Hidden {
      return
    }

    switch status {
      case .Ready:
        break
      case .Paused:
        rememberTimerAtPause(elapsedTime)
      case .Counting:
        incrementTimerCount()
      case .Completed:
        break
    }
  }
}


