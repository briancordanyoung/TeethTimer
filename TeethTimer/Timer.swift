import Foundation
import CoreGraphics

// MARK: -
// MARK: - Enums
enum TimerStatus: String, Printable {
  case Ready      = "Ready"
  case Counting   = "Counting"
  case Paused     = "Paused"
  case Completed  = "Completed"
  
  var description: String {
    return self.rawValue
  }
}


// MARK: -
// MARK: Timer class
final class Timer: NSObject {
  
  // MARK: Properties
  var originalStartTime:       NSTimeInterval?
  var recentStartTime:         NSTimeInterval?
  var timerUUID:               String?
  
  var timerUpdateInterval    = NSTimeInterval(0.1)
  var secondsElapsedAtPause  = NSTimeInterval(0)
  var secondsAddedAfterStart = NSTimeInterval(0)
  var duration               = NSTimeInterval(60 * 4) // 4 Minute Default
  var durationSetting: Int  {
    return NSUserDefaults.standardUserDefaults()
      .integerForKey("defaultDurationInSeconds")
  }
  
  // Callback Handler Properties (block based API)
  // These should be used as call backs alerting a view controller
  // that one of these events occurred.
  var statusChangedHandler: (TimerStatus) -> ()
  var timerUpdatedHandler:  (Timer?) -> ()

  
  // MARK: Computed Properties
  var status: TimerStatus {
    get {
      return _status
    }
    set(newStatus) {
      switch newStatus {
      case .Ready:
        reset()
      case .Counting:
        start()
      case .Paused:
        pause()
      case .Completed:
        complete()
      }
    }
  }
  
  var secondsElapsed: NSTimeInterval {
    var _secondsElapsed: NSTimeInterval
    if let recentStartTime = recentStartTime {
      let now = NSDate.timeIntervalSinceReferenceDate()
      _secondsElapsed = now - recentStartTime + secondsElapsedAtPause
    } else {
      _secondsElapsed = secondsElapsedAtPause
    }
    return _secondsElapsed
  }
  
  var secondsRemaining: NSTimeInterval {
    var seconds = (duration + secondsAddedAfterStart) - secondsElapsed
    if seconds < 0 || status == .Completed {
      seconds = 0
    }
    return seconds
  }
  
  var percentageRemaining: CGFloat {
    var percentage = secondsToPercentage(secondsRemaining)
    if status == .Completed {
      percentage = 0
    }
    return percentage
  }
  
  // MARK: Internal Properties
  var _status: TimerStatus = .Ready {
    didSet {
      onNextRunloopNotifyStatusUpdated()
    }
  }
  
  
  // MARK: -
  // MARK: Init methods
  convenience override init() {
    // I couldn't figure out how to initilize a UIViewController
    // with the nessesary functions as the time the Timer
    // intance is created.  So, I made this convenience init which
    // creates these stand-in println() functions.  These should be
    // replaced in the timer class instance by the callbacks that
    // update any controls like a UIButton or UILabel in the UIViewController.
    
    func printStatus(status: TimerStatus) {
      #if DEBUG
        println("Change Timer Control Text to: \(printStatus)")
      #endif
    }
    
    func printSecondsRemaining(timer: Timer?) {
      #if DEBUG
        if let timer = timer {
          println("Seconds left: \(timer.secondsRemaining)")
        }
      #endif
    }
    
    self.init(WithStatusChangedHandler: printStatus,
                AndTimerUpdatedHandler: printSecondsRemaining)
  }
  
  init( WithStatusChangedHandler statusChangedHandlerFunc: (TimerStatus) -> (),
        AndTimerUpdatedHandler   timerUpdatedHandlerFunc:  (Timer?) -> ()    ) {
      statusChangedHandler  = statusChangedHandlerFunc
      timerUpdatedHandler   = timerUpdatedHandlerFunc
  }
  
  
  // MARK: -
  // MARK: Timer Actions
  func reset() {
    _status                = .Ready
    originalStartTime      = nil
    recentStartTime        = nil
    timerUUID              = nil
    secondsElapsedAtPause  = 0
    secondsAddedAfterStart = 0
    
    syncDurationSetting()
    notifyTimerUpdated()
  }
  
  func start() {
    _status = .Counting
    
    recentStartTime = NSDate.timeIntervalSinceReferenceDate()
    if originalStartTime == nil {
      originalStartTime = recentStartTime
    }
    if timerUUID == nil {
      timerUUID = NSUUID().UUIDString
    }
    
    incrementTimer()
  }
  
  func pause() {
    _status = .Paused
    rememberTimerAtPause()
  }
  
  func complete() {
    _status = .Completed
    rememberTimerAtPause()
    notifyTimerUpdated()
  }
  
  
  func addTimeByPercentage(percentage: CGFloat) {
    // Don't use duration + secondsAddedAfterStart because
    // we only want to add a percentage of the original duration
    // without any additional seconds added
    let additionalSeconds = duration * NSTimeInterval(percentage)
    addTimeBySeconds(additionalSeconds)
  }
  
  func addTimeBySeconds(seconds: NSTimeInterval) {
    
    var secondsAdded = secondsAddedAfterStart + seconds
    if secondsAdded > secondsElapsed {
      // limit seconds to add to at most the seconds already elapsed
      secondsAdded = secondsElapsed
    }
    secondsAddedAfterStart = secondsAdded
    
    switch status {
      case .Ready, .Paused:
        notifyTimerUpdated()
      case .Counting:
          break
      case .Completed:
        _status = .Paused
        notifyTimerUpdated()
    }
  }
  

  // MARK: -
  // MARK: Timer
  func incrementTimer() {
    switch status {
      case .Ready:
        break
      case .Paused:
        rememberTimerAtPause()
      case .Counting:
        incrementOrComplete()
      case .Completed:
        break
    }
  }
  
  private func incrementOrComplete() {
    if (secondsElapsed > (duration + secondsAddedAfterStart)) {
      complete()
    } else {
      notifyTimerUpdated()
      incrementTimerAgain()
    }
  }
  
  private func incrementTimerAgain() {
    NSTimer.scheduledTimerWithTimeInterval( timerUpdateInterval,
                                    target: self,
                                  selector: Selector("incrementTimer"),
                                  userInfo: nil,
                                   repeats: false)
  }
  
  private func rememberTimerAtPause() {
    secondsElapsedAtPause = secondsElapsed
    recentStartTime = nil
  }
  
  // MARK: -
  // MARK: Helpers
  private func syncDurationSetting() {
    let durationSetting = self.durationSetting
    if (durationSetting != 0) {
      duration = NSTimeInterval(durationSetting)
    }
  }
  
  private func secondsToPercentage(secondsRemaining: NSTimeInterval) -> CGFloat {
    return CGFloat(secondsRemaining / duration)
  }
  
  private func notifyTimerUpdated() {
    weak var weakSelf = self
    timerUpdatedHandler(weakSelf)
  }
  
  
  // The statusChangedHandler() is intended for acting on a change of status
  // only, and not intended as a callback to check property values of the
  // Timer class. (hense, only the TimerStatus emun is passed as the sole argument.)
  // If this callback IS used to check properties, they may not represent
  // the state of the timer correctly since the status is changed first and 
  // drives rest of the class.  Properties sensitive to this are:
  //     secondsElapsedAtPause
  //     recentStartTime
  //     secondsElapsed (computed)
  // To mitigate this case, the status callback is delayed until the next
  // runloop using NSTimer with a delay of 0.0.
  private func onNextRunloopNotifyStatusUpdated() {
    NSTimer.scheduledTimerWithTimeInterval( 0.0,
                                    target: self,
                                  selector: Selector("notifyStatusUpdated"),
                                  userInfo: nil,
                                   repeats: false)
  }
  
  func notifyStatusUpdated() {
    statusChangedHandler(status)
  }
  
}


