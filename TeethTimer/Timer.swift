//
//  Timer.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 10/13/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import Foundation

class Timer: NSObject {

    
    // MARK: Properties
    var startTime: NSTimeInterval?
    var lastStartTime: NSTimeInterval?
    var timerUUID: String?

    var elapsedTimeAtPause = NSTimeInterval(0)
    var additionalElapsedTime = NSTimeInterval(0)
    
    var brushingDuration = NSTimeInterval(60 * 4) // 4 Minute Default
    var brushingDurationSetting: Int  {
        get {
            return NSUserDefaults.standardUserDefaults()
                .integerForKey("defaultDurationInSeconds")
        }
    }
    
    var hidden = false
    var visible: Bool {
        get {
            return !hidden
        }
        set(isVisible) {
            hidden = !isVisible
        }
    }

    var currentlyRunning = false
    var notCurrentlyRunning: Bool {
        get {
            return !currentlyRunning
        }
        set(notRunning) {
            currentlyRunning = !notRunning
        }
    }

    var hasStarted: Bool {
        get {
            var timerHasStarted = false

            if lastStartTime != nil {
                timerHasStarted = true
            }

            if elapsedTimeAtPause != 0 {
                timerHasStarted = true
            }

            if currentlyRunning {
                timerHasStarted = true
            }
            
            return timerHasStarted
        }
    }
    
    var hasNotStarted: Bool {
        get {
            return !hasStarted
        }
    }
    
    
    var hasCompleted = false
    var hasNotCompleted: Bool {
        get {
            return !hasCompleted
        }
        set(hasCompleted) {
            self.hasCompleted = !hasCompleted
        }
    }
    
    var elapsedTime: NSTimeInterval {
        get {
            var _elapsedTime: NSTimeInterval = 0
            if let start = lastStartTime? {
                let now = NSDate.timeIntervalSinceReferenceDate()
                _elapsedTime = now - start + elapsedTimeAtPause
            } else {
                _elapsedTime = elapsedTimeAtPause
            }
            return _elapsedTime
        }
    }
    
    var timeRemaining: NSTimeInterval {
        get {
            return (brushingDuration + additionalElapsedTime) - elapsedTime
        }
    }
    
    
    // Properties that hold functions. (a.k.a. a block based API)
    // These should be used as call backs alerting a view controller
    // that one of these events occurred.
    var updateTimerWithText: (String) -> ()
    var updateUIControlText: (String) -> ()
    var updateTimerWithSeconds: (NSTimeInterval) -> ()
    var updateTimerWithPercentage: (Float) -> ()

    
    
    // MARK:
    // =============================================================================
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
        
        func printPercentage(timeAsPercentage: Float) {
            #if DEBUG
            println("Percentage left: \(timeAsPercentage)")
            #endif
        }
        
        self.init(printControlText, printTime, printSeconds, printPercentage)
    }
    
    init( updateUIControlTextFunc: (String) -> (),
                  updateTimerFunc: (String) -> (),
                updateSecondsFunc: (NSTimeInterval) -> (),
             updatePercentageFunc: (Float) -> ()    ) {
            
        updateUIControlText       = updateUIControlTextFunc
        updateTimerWithText       = updateTimerFunc
        updateTimerWithSeconds    = updateSecondsFunc
        updateTimerWithPercentage = updatePercentageFunc
    }
    
    // MARK: Timer Actions
    func start() {
        currentlyRunning = true
        lastStartTime = NSDate.timeIntervalSinceReferenceDate()
        if startTime == nil {
            startTime = lastStartTime
        }
        if timerUUID == nil {
            timerUUID = NSUUID().UUIDString
        }
        updateUIControlText("Pause")
        incrementTimer()
    }
    
    func pause() {
        notCurrentlyRunning = true
        updateUIControlText("Continue")
    }
    
    func pauseAfterDoneAndAddTime() {
        hasNotCompleted = true
        updateUIControlText("Continue")
        updateTimerTo(timeRemaining)
    }
    
    func reset() {
        startTime = nil
        lastStartTime = nil
        timerUUID = nil
        notCurrentlyRunning = true
        hasNotCompleted = true
        elapsedTimeAtPause = 0
        additionalElapsedTime = 0

        syncBrushingDurationSetting()

        updateTimerTo(brushingDuration)
        updateUIControlText("Start")
    }
    
    private func complete(elapsedTime: NSTimeInterval) {
        notCurrentlyRunning = true
        rememberTimerAtPause(elapsedTime)
        hasCompleted = true

        updateUIControlText("Done")
        updateTimerTo(0.0)
        
        println("original timer:        \(brushingDuration)")
        println("total running time:    \(elapsedTimeAtPause)")
        println("total additional time: \(additionalElapsedTime)")
    }
    
    
    func addTimeByPercentage(percentage: Float) {
        // Don't use brushingDuration + additionalElapsedTime because
        // we only want to add a percentage of the original duration
        // without any additional seconds added
        let additionalSeconds = NSTimeInterval(Float(brushingDuration) * percentage)
        addTimeBySeconds(additionalSeconds)
    }
    
    func addTimeBySeconds(seconds: NSTimeInterval) {
        // Don't add sooo much to the timer that the time left
        // if more than the original brushing duration
        additionalElapsedTime = additionalElapsedTime + seconds
        if additionalElapsedTime > elapsedTime {
            additionalElapsedTime = elapsedTime
        }
        
        if notCurrentlyRunning {
            updateTimerTo(timeRemaining)
        }
        
        if hasCompleted {
            pauseAfterDoneAndAddTime()
        }
    }
    
    func transitionToHidden() {
        hidden = true
    }
    
    func transitionToVisible() {
        visible = true
        if hasStarted {
            incrementTimer()
        } else {
            reset()
        }
    }
    
    private func syncBrushingDurationSetting() {
        let brushingDurationSetting = self.brushingDurationSetting
        if (brushingDurationSetting != 0) {
            brushingDuration = NSTimeInterval(brushingDurationSetting)
        }
    }
    
    // MARK: Time Helper Methods
    private func timeStringFromMinutes(minutes: Int, AndSeconds seconds: Int) -> String {
        return NSString(format: "%02i:%02i",minutes,seconds)
    }
    
    private func timeStringFromDuration(duration: NSTimeInterval) -> String {
        let durationParts = timeAsParts(duration)
        return timeStringFromMinutes(durationParts.minutes, AndSeconds: durationParts.seconds)
    }
    
    private func timeAsParts(elapsedTimeInterval: NSTimeInterval) -> (minutes: Int,seconds: Int) {
        var elapsedTime = elapsedTimeInterval
        let elapsedMinsTime = elapsedTime / 60.0
        let elapsedMins = Int(elapsedMinsTime)
        elapsedTime = elapsedMinsTime * 60
        let elapsedSecsTime = elapsedTime - (Double(elapsedMins) * 60)
        let elapsedSecs = Int(elapsedSecsTime)
        
        return (elapsedMins, elapsedSecs)
    }
    
    private func secondsToPercentage(secondsRemaining: NSTimeInterval) -> Float {
        return Float(secondsRemaining / (brushingDuration))
    }
    
    private func updateTimerTo(timeRemaining: NSTimeInterval) {
        // TODO: More testing to make sure that the timer always ends...
        //       on 0 and 00:00.  Percentage left reuqired special handling
        updateTimerWithText(timeStringFromDuration(timeRemaining))
        updateTimerWithSeconds(timeRemaining)
        
        var percentageLeft = secondsToPercentage(timeRemaining)
        
        if hasCompleted {
            percentageLeft = 0.0
        }
        
        updateTimerWithPercentage(percentageLeft)
    }

    
    // MARK: Timer
    private func rememberTimerAtPause(elapsedTime: NSTimeInterval) {
        lastStartTime = nil
        elapsedTimeAtPause = elapsedTime
    }
    
    private func incrementTimerAgain() {
        var timer = NSTimer.scheduledTimerWithTimeInterval( 0.1,
            target: self,
            selector:  Selector("incrementTimer"),
            userInfo: nil,
            repeats: false)
    }
    
    func incrementTimer() {
        
        // Stop updating the timer if the app or view controler
        // is not visable
        if hidden {
            return
        }
        
        if let start = lastStartTime? {
//            let now = NSDate.timeIntervalSinceReferenceDate()
//            let elapsedTime = now - start + elapsedTimeAtPause
//            let timeRemaining = (brushingDuration + additionalElapsedTime) - elapsedTime

            if notCurrentlyRunning {
                rememberTimerAtPause(elapsedTime)
                return
            }
            
            if (elapsedTime > (brushingDuration + additionalElapsedTime)) {
                complete(elapsedTime)
            } else {
                updateTimerTo(timeRemaining)
                incrementTimerAgain()
            }
            
        }
    }

    
}
