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
class Timer: NSObject {
  
  // MARK: Properties
  var status: TimerStatus   = .Ready {
    didSet {
      statusChangedHandler(status)
    }
  }

  var originalStartTime:      NSTimeInterval?
  var recentStartTime:        NSTimeInterval?
  var timerUUID:              String?
  
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
  
  var hasStarted: Bool {
    var timerHasStarted       = false
    if recentStartTime       != nil { timerHasStarted = true }
    if secondsElapsedAtPause != 0   { timerHasStarted = true }
    return timerHasStarted
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
    originalStartTime      = nil
    recentStartTime        = nil
    timerUUID              = nil
    secondsElapsedAtPause  = 0
    secondsAddedAfterStart = 0
    status                 = .Ready
    
    syncDurationSetting()
    notifyTimerUpdated()
  }
  
  func start() {
    recentStartTime = NSDate.timeIntervalSinceReferenceDate()
    if originalStartTime == nil {
      originalStartTime = recentStartTime
    }
    if timerUUID == nil {
      timerUUID = NSUUID().UUIDString
    }
    
    status = .Counting
    incrementTimer()
  }
  
  func pause() {
    rememberTimerAtPause(secondsElapsed)
    status = .Paused
  }
  
  func complete() {
    rememberTimerAtPause(secondsElapsed)
    status = .Completed
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
    
    var secondsToAdd = secondsAddedAfterStart + seconds
    if secondsToAdd > secondsElapsed {
      // limit seconds to add to at most the seconds already elapsed
      secondsToAdd = secondsElapsed
    }
    secondsAddedAfterStart = secondsToAdd
    
    switch status {
      case .Ready, .Paused:
        notifyTimerUpdated()
      case .Counting:
          break
      case .Completed:
        status = .Paused
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
        rememberTimerAtPause(secondsElapsed)
      case .Counting:
        incrementOrComplete()
      case .Completed:
        break
    }
  }
  
  func incrementOrComplete() {
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
  
  private func rememberTimerAtPause(secondsElapsed: NSTimeInterval) {
    recentStartTime = nil
    secondsElapsedAtPause = secondsElapsed
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
}


