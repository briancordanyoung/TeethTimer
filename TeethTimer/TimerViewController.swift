//
//  ViewController.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 10/11/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var fullScreenImage: UIImageView!
    let timer: Timer
    
    
    // MARK: Functions to pass to the Timer class
    func updateTimeLabelWithText(labelText: String) {
        timerLabel.text = labelText
    }

    func updateButtonTitleWithText(buttonText: String) {
        startPauseButton.setTitle(buttonText, forState: UIControlState.Normal)
    }
    
    
    
    // MARK: Init methods
    required init(coder aDecoder: NSCoder) {
        timer = Timer()
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        timer = Timer()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    // MARK: View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButton(resetButton)
        styleButton(startPauseButton)
        fullScreenImage.image = UIImage(named: "GavinPool-5.jpg")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer.updateTimeAsText = updateTimeLabelWithText
        timer.updateUIControlText = updateButtonTitleWithText
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
    
    // MARK: Appearance Helper
    private func styleButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
}

