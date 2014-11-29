//
//  ViewController.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 10/11/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController, ImageWheelDelegate {

    // MARK: Properties
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var fullScreenImage: UIImageView!
    let timer = Timer()
    
    
    // MARK: View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButton(resetButton)
        styleButton(startPauseButton)
//        fullScreenImage.image = UIImage(named: "GavinPool-5.jpg")
        fullScreenImage.image = UIImage(named: "Gavin Poses-s01")

//        let wheel = ImageWheelControl(WithFrame: CGRectMake(0, 0, 200, 200),
//                                    AndDelegate: self,
//                                   withSections: 8)
//        wheel.center = CGPointMake(160, 240)
//        self.view.addSubview(wheel)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer.updateTimerWithText = updateTimeLabelWithText
        timer.updateUIControlText = updateButtonTitleWithText
        timer.updateTimerWithPercentage = updatePercentageDone
        timer.updateTimerWithSeconds = updateSeconds
        timer.reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: Button Actions
    @IBAction func startStopPressed(sender: UIButton) {
        if timer.hasCompleted {
            timer.reset()
            return
        }
        
        if timer.notCurrentlyRunning {
            timer.start()
        } else {
            timer.pause()
        }
    }

    @IBAction func resetPressed(sender: UIButton) {
        timer.reset()
    }

    
    // MARK: Callbacks to pass to the Timer class
    func updateTimeLabelWithText(labelText: String) {
        timerLabel.text = labelText
    }
    
    func updateButtonTitleWithText(buttonText: String) {
        startPauseButton.setTitle(buttonText, forState: UIControlState.Normal)
    }
    
    func updatePercentageDone(percentageDone: Float) {

    }
    
    func updateSeconds(secondsLeft: NSTimeInterval) {
    }
    
    // MARK: ImageWheelDelegate
    func wheelDidChangeValue(newValue: String) {
        println(newValue)
    }

    // MARK: Appearance Helper
    private func styleButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
}

