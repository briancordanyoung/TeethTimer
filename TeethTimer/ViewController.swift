//
//  ViewController.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 10/11/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    var currentlyRunning = false
    var startTime: NSTimeInterval?
    var elapsedTimeAtPause: NSTimeInterval = 0
    var brushingDuration = (60 * 4) as NSTimeInterval // 4 Minutes
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStopPressed(sender: UIButton) {
        if currentlyRunning == false {
            startTimer()
        } else {
            pauseTimer()
        }
    }

    
    @IBAction func resetPressed(sender: UIButton) {
        pauseTimer()
        resetTimer()
    }

    func startTimer() {
        currentlyRunning = true
        startTime = NSDate.timeIntervalSinceReferenceDate()
        startPauseButton.setTitle("Pause", forState: UIControlState.Normal)
        updateTime()
    }
    
    func pauseTimer() {
        currentlyRunning = false
        startPauseButton.setTitle("Start", forState: UIControlState.Normal)
    }
    
    func displayTimeStringWithMinutes(minutes: Int, AndSeconds seconds: Int) -> String {
        return NSString(format: "%02i:%02i",minutes,seconds)
    }
    
    func displayTimeStringFromDuration(duration: NSTimeInterval) -> String {
        let durationParts = timeAsParts(duration)
        return displayTimeStringWithMinutes(durationParts.minutes, AndSeconds: durationParts.seconds)
    }
    
    func keepUpdatingTime() {
        var timer = NSTimer.scheduledTimerWithTimeInterval( 0.1,
            target: self,
            selector:  Selector("updateTime"),
            userInfo: nil,
            repeats: false)
    }
    
    func resetTimer() {
        startTime = nil
        elapsedTimeAtPause = 0
        timerLabel.text = displayTimeStringFromDuration(brushingDuration)
    }
    
    func rememberTimerAtPaused(elapsedTime: NSTimeInterval) {
        elapsedTimeAtPause += elapsedTime
        startTime = nil
    }
    
    func timeAsParts(elapsedTimeInterval: NSTimeInterval) -> (minutes: Int,seconds: Int){
        var elapsedTime = elapsedTimeInterval
        let elapsedMinsTime = elapsedTime / 60.0
        let elapsedMins = Int(elapsedMinsTime)
        elapsedTime = elapsedMinsTime * 60
        let elapsedSecsTime = elapsedTime - (Double(elapsedMins) * 60)
        let elapsedSecs = Int(elapsedSecsTime)

        return (elapsedMins, elapsedSecs)
    }
    
    func updateTime() {
        if let time = startTime? {
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            var elapsedTime = currentTime - time
            
            let elapsedTimeParts = timeAsParts(elapsedTime)
            
            let displaySecs = 59 - elapsedTimeParts.seconds
            let displayMins = Int(brushingDuration / 60) - elapsedTimeParts.minutes - 1
            
            let labelText = displayTimeStringWithMinutes(displayMins, AndSeconds: displaySecs)
            
            if currentlyRunning == false {
                rememberTimerAtPaused(elapsedTime)
            } else {
                if (elapsedTime > brushingDuration) {
                    pauseTimer()
                    timerLabel.text = "00:00"
                } else {
                    timerLabel.text = labelText
                    keepUpdatingTime()
                }
            }
            
        }
    }
}

