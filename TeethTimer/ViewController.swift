//
//  ViewController.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 10/11/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Properties
    var startTime: NSTimeInterval?
    var elapsedTimeAtPause: NSTimeInterval = 0
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

    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    
    // MARK: View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        resetTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Button Actions
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
    
    
    
    // MARK: Timer Methods
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

    func resetTimer() {
        startTime = nil
        elapsedTimeAtPause = 0
        timerLabel.text = displayTimeStringFromDuration(brushingDuration)
    }
    
    func rememberTimerAtPause(elapsedTime: NSTimeInterval) {
        startTime = nil
        elapsedTimeAtPause = elapsedTime
    }

    
    
    // MARK: Time Helper Methods
    func displayTimeStringWithMinutes(minutes: Int, AndSeconds seconds: Int) -> String {
        return NSString(format: "%02i:%02i",minutes,seconds)
    }
    
    func displayTimeStringFromDuration(duration: NSTimeInterval) -> String {
        let durationParts = timeAsParts(duration)
        return displayTimeStringWithMinutes(durationParts.minutes, AndSeconds: durationParts.seconds)
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
            
            // TODO: Make Method to subtract elapsedTime from brushingDuration
            //       and then turn that result in to parts
            let elapsedTimeParts = timeAsParts(elapsedTime)
            let displaySecs = 59 - elapsedTimeParts.seconds
            let displayMins = Int(brushingDuration / 60) - elapsedTimeParts.minutes - 1

            
            
            let labelText = displayTimeStringWithMinutes(displayMins, AndSeconds: displaySecs)
            
            if (elapsedTime > brushingDuration) {
                pauseTimer()
                timerLabel.text = "00:00"
            } else {
                timerLabel.text = labelText
                updateTimeAgain()
            }
            
        }
        
    }
    
//    func printValues() {
//        
//        func printValuesAgain() {
//            var printer = NSTimer.scheduledTimerWithTimeInterval( 1,
//                target: self,
//                selector:  Selector("printValues"),
//                userInfo: nil,
//                repeats: false)
//        }
//        
//        if let start = startTime? {
//            let now = NSDate.timeIntervalSinceReferenceDate()
//            let elapsedTime = now - start + elapsedTimeAtPause
//            
//            println("Start Time: \(Int(start)) elapsedTime: \(Int(elapsedTime)) elapsedTimeAtPause: \(Int(elapsedTimeAtPause)) currentlyRunning: \(currentlyRunning) timerLabel: \(timerLabel.text)")
//        } else {
//            println("Start Time:     elapsedTime:      elapsedTimeAtPause: \(Int(elapsedTimeAtPause)) currentlyRunning: \(currentlyRunning) timerLabel: \(timerLabel.text)")
//        }
//        
//        printValuesAgain()
//    }
    
    
    
    
}

