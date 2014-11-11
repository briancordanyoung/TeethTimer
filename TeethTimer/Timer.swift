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
    var brushingDurationPref: Int  {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("defaultDurationInSeconds")
        }
    }
    
    var brushingDuration = (60 * 4) as NSTimeInterval // 4 Minutes
    var timerIsHidden = false
    
    var currentlyRunning = false
    var notCurrentlyRunning: Bool {
        get {
            return !currentlyRunning
        }
        set(notRunning) {
            currentlyRunning = !notRunning
        }
    }
    
    var startPauseButton: UIButton
    var timerLabel: UILabel
    
    init(WithStartButton button: UIButton, AndTimerLabel label: UILabel) {
        startPauseButton = button
        timerLabel = label
    }
    

    
    // MARK: Timer Methods
    func startTimer() {
        currentlyRunning = true
        startTime = NSDate.timeIntervalSinceReferenceDate()
        startPauseButton.setTitle("Pause", forState: UIControlState.Normal)
        updateTime()
    }
    
    func pauseTimer() {
        currentlyRunning = false
        startPauseButton.setTitle("Continue", forState: UIControlState.Normal)
    }
    
    func resetTimer() {
        startTime = nil
        currentlyRunning = false
        elapsedTimeAtPause = 0
        setBrushingDuration()
        timerLabel.text = displayTimeStringFromDuration(brushingDuration)
        startPauseButton.setTitle("Start", forState: UIControlState.Normal)
    }
    
    func timerCompleted() {
        startTime = nil
        elapsedTimeAtPause = 0
        currentlyRunning = false
        setBrushingDuration()
        timerLabel.text = "00:00"
        startPauseButton.setTitle("Done", forState: UIControlState.Normal)
    }
    
    func rememberTimerAtPause(elapsedTime: NSTimeInterval) {
        startTime = nil
        elapsedTimeAtPause = elapsedTime
    }
    
    func setBrushingDuration() {
        let brushingDurationPref = self.brushingDurationPref
        if (brushingDurationPref != 0) {
            brushingDuration = NSTimeInterval(brushingDurationPref)
        }
    }
    
    func timerHasStarted() -> Bool {
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
    
    func timerHasNotStarted() -> Bool {
        return !timerHasStarted()
    }
    
    
    // MARK: Time Helper Methods
    private func displayTimeStringWithMinutes(minutes: Int, AndSeconds seconds: Int) -> String {
        return NSString(format: "%02i:%02i",minutes,seconds)
    }
    
    private func displayTimeStringFromDuration(duration: NSTimeInterval) -> String {
        let durationParts = timeAsParts(duration)
        return displayTimeStringWithMinutes(durationParts.minutes, AndSeconds: durationParts.seconds)
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
    func updateTime() {
        
        func updateTimeAgain() {
            var timer = NSTimer.scheduledTimerWithTimeInterval( 0.1,
                target: self,
                selector:  Selector("updateTime"),
                userInfo: nil,
                repeats: false)
        }
        
        
        // Stop updating the timer if the app is hidden or the view controler
        // is not visable
        if timerIsHidden {
            return
        }
        
        if let start = startTime? {
            let now = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime = now - start + elapsedTimeAtPause
            
            if notCurrentlyRunning {
                rememberTimerAtPause(elapsedTime)
                return
            }
            
            let elapsedTimeParts = timeAsParts(brushingDuration - elapsedTime)
            let labelText = displayTimeStringWithMinutes(elapsedTimeParts.minutes,
                AndSeconds: elapsedTimeParts.seconds)
            
            
            if (elapsedTime > brushingDuration) {
                timerCompleted()
            } else {
                timerLabel.text = labelText
                updateTimeAgain()
            }
            
        }
    }

    
}
