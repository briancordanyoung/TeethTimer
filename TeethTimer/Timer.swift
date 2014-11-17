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
    var elapsedTimeAtPause = NSTimeInterval(0)
    
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

            if startTime != nil {
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
            println("Change Timer Control to: \(controlText)")
            #endif
        }
        
        func printTime(timerAsString: String) {
            #if DEBUG
            println("Time Left: \(timerAsString)")
            #endif
        }
        
        func printSeconds(timerAsSeconds: NSTimeInterval) {
            #if DEBUG
            println("Seconds left: \(timerAsSeconds)")
            #endif
        }
        
        func printPercentage(timerAsPercentage: Float) {
            #if DEBUG
            println("Percentage left: \(timerAsPercentage)")
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
        startTime = NSDate.timeIntervalSinceReferenceDate()
        updateUIControlText("Pause")
        incrementTimer()
    }
    
    func pause() {
        notCurrentlyRunning = true
        updateUIControlText("Continue")
    }
    
    func reset() {
        startTime = nil
        notCurrentlyRunning = true
        hasNotCompleted = true
        elapsedTimeAtPause = 0

        syncBrushingDurationSetting()

        updateTimerWithTimeRemaining(brushingDuration)
        updateUIControlText("Start")
    }
    
    private func complete() {
        startTime = nil
        notCurrentlyRunning = true
        hasCompleted = true

        updateUIControlText("Done")
        updateTimerWithTimeRemaining(0.0)

        syncBrushingDurationSetting()
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
        return Float(secondsRemaining / brushingDuration)
    }
    
    private func updateTimerWithTimeRemaining(timeRemaining: NSTimeInterval) {
        // TODO: More testing to make sure that the timer always ends
        //       on 0 and 00:00.  Percentage left reuqired special handling
        updateTimerWithText(timeStringFromDuration(timeRemaining))
        updateTimerWithSeconds(timeRemaining)
        
        var percentageLeft = secondsToPercentage(timeRemaining)
        
        if percentageLeft < 0.001 {
            percentageLeft = 0.0
        }
        
        if hasCompleted {
            percentageLeft = 0.0
        }
        
        updateTimerWithPercentage(percentageLeft)
    }

    
    // MARK: Timer
    private func rememberTimerAtPause(elapsedTime: NSTimeInterval) {
        startTime = nil
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
        
        if let start = startTime? {
            let now = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime = now - start + elapsedTimeAtPause
            let timeRemaining = brushingDuration - elapsedTime

            if notCurrentlyRunning {
                rememberTimerAtPause(elapsedTime)
                return
            }
            
            if (elapsedTime > brushingDuration) {
                complete()
            } else {
                updateTimerWithTimeRemaining(timeRemaining)
                incrementTimerAgain()
            }
            
        }
    }

    
}
