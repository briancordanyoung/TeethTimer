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
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var fullScreenImage: UIImageView!
    let timer: Timer
    
    // MARK: Init methods
    required init(coder aDecoder: NSCoder) {
        timer = Timer(WithStartButton: UIButton(), AndTimerLabel: UILabel())
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        timer = Timer(WithStartButton: UIButton(), AndTimerLabel: UILabel())
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    // MARK: View Controller Methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer.startPauseButton = startPauseButton
        timer.timerLabel = timerLabel
        timer.resetTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButton(resetButton)
        styleButton(startPauseButton)
        fullScreenImage.image = UIImage(named: "GavinPool-5.jpg")
        timer.resetTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func styleButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: Button Actions
    @IBAction func startStopPressed(sender: UIButton) {
        if timer.currentlyRunning == false {
            timer.startTimer()
        } else {
            timer.pauseTimer()
        }
    }

    @IBAction func resetPressed(sender: UIButton) {
        timer.resetTimer()
    }
    
    
    
    
}

