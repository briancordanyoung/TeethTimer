//
//  Timer.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 10/13/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

class Timer: NSObject {

    
    // MARK: Properties
    var startTime: NSTimeInterval?
    var elapsedTimeAtPause: NSTimeInterval = 0
    var timerIsHidden = false
    
    var brushingDuration = (60 * 4) as NSTimeInterval // 4 Minute Default
    var brushingDurationSetting: Int  {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("defaultDurationInSeconds")
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
    
    
    var startPauseButton: UIButton
    var startPauseButtonTitle: String {
        get {
            var returnText = ""
            if let buttonTitle = startPauseButton.titleForState(UIControlState.Normal) {
                returnText = buttonTitle
            }
            return returnText
        }
        set(title) {
            startPauseButton.setTitle(title, forState: UIControlState.Normal)
        }
    }

    
    var timerLabel: UILabel
    var timerText: String {
        get {
            var returnText = ""
            if let labelText = timerLabel.text {
                returnText = labelText
            }
            return returnText
        }
        set(text) {
            timerLabel.text = text
        }
    }
    
    var hasCompleted: Bool {
        get {
            var hasCompleted = false
            if startPauseButtonTitle == "Done" {
                hasCompleted = true
            }
            return hasCompleted
        }
    }
    
    // MARK:
    // =============================================================================
    // MARK: Init methods
    convenience override init() {
        // I couldn't figure out how to initilize a UIViewController
        // with the nessesary UIButton & UILabel at the time the Timer
        // intance is created.  So, I made this convenience init which
        // creates these throw-away UIButton & UILabel.  These should be
        // ignored and replaced by the UIButton & UILabel that is used
        // in the UIViewController, likely coming from the storyboard.
        self.init(WithStartButton: UIButton(), AndTimerLabel: UILabel())
    }
    
    init(WithStartButton button: UIButton, AndTimerLabel label: UILabel) {
        startPauseButton = button
        timerLabel = label
    }
    
    // MARK: Timer Actions
    func start() {
        currentlyRunning = true
        startTime = NSDate.timeIntervalSinceReferenceDate()
        startPauseButtonTitle = "Pause"
        incrementTimer()
    }
    
    func pause() {
        notCurrentlyRunning = true
        startPauseButtonTitle = "Continue"
    }
    
    func reset() {
        startTime = nil
        notCurrentlyRunning = true
        elapsedTimeAtPause = 0
        syncBrushingDurationSetting()
        timerText = timeStringFromDuration(brushingDuration)
        startPauseButtonTitle = "Start"
    }
    
    private func complete() {
        startTime = nil
        notCurrentlyRunning = true
        currentlyRunning = false
        syncBrushingDurationSetting()
        timerText = "00:00"
        startPauseButtonTitle = "Done"
    }
    
    func syncBrushingDurationSetting() {
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
        
        // Stop updating the timer if the app is hidden or the view controler
        // is not visable
        if timerIsHidden {
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
                timerText = timeStringFromDuration(timeRemaining)
                incrementTimerAgain()
            }
            
        }
    }

    
}
