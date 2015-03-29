import Foundation
import CoreGraphics

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
  var status: TimerStatus   = .Ready

  var startTime:              NSTimeInterval?
  var previousStartTime:      NSTimeInterval?
  var timerUUID:              String?
  
  var timerUpdateInterval   = NSTimeInterval(0.1)
  var elapsedTimeAtPause    = NSTimeInterval(0)

  var timeAddedAfterStart   = NSTimeInterval(0)
  var duration              = NSTimeInterval(60 * 4) // 4 Minute Default
  var durationSetting: Int  {
    return NSUserDefaults.standardUserDefaults()
      .integerForKey("defaultDurationInSeconds")
  }
  
  
  
  // MARK: Computed Properties
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
    return (duration + timeAddedAfterStart) - elapsedTime
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
    rememberTimerAtPause(elapsedTime)
    updateUIControlText("Continue")
  }
  
  func completed() {
    notifyTimerCompleted(elapsedTime)
  }
  
  func reset() {
    startTime = nil
    previousStartTime = nil
    timerUUID = nil
    status = .Ready
    elapsedTimeAtPause = 0
    timeAddedAfterStart = 0
    
    syncDurationSetting()
    
    notifyTimerRemaining(duration)
    updateUIControlText("Start")
  }
  
  private func notifyTimerCompleted(elapsedTime: NSTimeInterval) {
    status = .Completed
    rememberTimerAtPause(elapsedTime)
    
    updateUIControlText("Done")
    notifyTimerRemaining(0.0)
    
    println("original timer:        \(duration)")
    println("total running time:    \(elapsedTimeAtPause)")
    println("total additional time: \(timeAddedAfterStart)")
  }
  
  
  func addTimeByPercentage(percentage: CGFloat) {
    // Don't use duration + timeAddedAfterStart because
    // we only want to add a percentage of the original duration
    // without any additional seconds added
    let additionalSeconds = duration * NSTimeInterval(percentage)
    addTimeBySeconds(additionalSeconds)
  }
  
  func addTimeBySeconds(seconds: NSTimeInterval) {
    
    var timeToAdd = timeAddedAfterStart + seconds
    if timeToAdd > elapsedTime {
      // limit additional time to at most,
      timeToAdd = elapsedTime
    }
    timeAddedAfterStart = timeToAdd
    
    switch status {
      case .Ready, .Paused:
        notifyTimerRemaining(timeRemaining)
      case .Counting:
          break
      case .Completed:
        status = .Paused
        updateUIControlText("Continue")
        notifyTimerRemaining(timeRemaining)
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
  
  private func notifyTimerRemaining(timeRemaining: NSTimeInterval) {
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
    if (elapsedTime > (duration + timeAddedAfterStart)) {
      notifyTimerCompleted(elapsedTime)
    } else {
      notifyTimerRemaining(timeRemaining)
      incrementTimerAgain()
    }
  }
  
  func incrementTimer() {
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


