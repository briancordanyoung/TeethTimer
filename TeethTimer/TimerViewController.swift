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
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var lowerThirdView: UIView!
    
    @IBOutlet weak var testButton: UIButton!
    
    var gavinWheelHeight: NSLayoutConstraint?
    var gavinWheelWidth: NSLayoutConstraint?
    var gavinWheel: ImageWheelControl?
    
    let timer = Timer()

    // MARK: View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButton(resetButton)
        styleButton(startPauseButton)
//        fullScreenImage.image = UIImage(named: "background")
        
        let gavinWheel = ImageWheelControl(WithDelegate: self,
                                           WithSections: 6)
        
        controlView.insertSubview(gavinWheel, belowSubview: lowerThirdView)

        gavinWheel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.view.addConstraint(NSLayoutConstraint(item: gavinWheel,
                                              attribute: NSLayoutAttribute.CenterY,
                                              relatedBy: NSLayoutRelation.Equal,
                                                 toItem: timerLabel,
                                              attribute: NSLayoutAttribute.CenterY,
                                             multiplier: 1.0,
                                               constant: 0.0))
        

        self.view.addConstraint(NSLayoutConstraint(item: gavinWheel,
                                              attribute: NSLayoutAttribute.CenterX,
                                              relatedBy: NSLayoutRelation.Equal,
                                                 toItem: timerLabel,
                                              attribute: NSLayoutAttribute.CenterX,
                                             multiplier: 1.0,
                                               constant: 0.0))
        
        gavinWheelHeight = NSLayoutConstraint(item: gavinWheel,
                                         attribute: NSLayoutAttribute.Height,
                                         relatedBy: NSLayoutRelation.Equal,
                                            toItem: nil,
                                         attribute: NSLayoutAttribute.NotAnAttribute,
                                        multiplier: 1.0,
                                          constant: gavinWheelSize())
        if gavinWheelHeight != nil {
            gavinWheel.addConstraint(gavinWheelHeight!)
        }
        
        gavinWheelWidth = NSLayoutConstraint(item: gavinWheel,
                                        attribute: NSLayoutAttribute.Width,
                                        relatedBy: NSLayoutRelation.Equal,
                                           toItem: nil,
                                        attribute: NSLayoutAttribute.NotAnAttribute,
                                       multiplier: 1.0,
                                         constant: gavinWheelSize())
        if gavinWheelWidth != nil {
            gavinWheel.addConstraint(gavinWheelWidth!)
        }

        gavinWheel.positionViews()

        self.gavinWheel = gavinWheel
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

    @IBAction func testPresses(sender: UIButton) {
//        timer.addTimeBySeconds(30)
        timer.addTimeByPercentage(0.25)
    }
    
    // MARK: Callbacks to pass to the Timer class
    func updateTimeLabelWithText(labelText: String) {
        timerLabel.text = labelText
    }
    
    func updateButtonTitleWithText(buttonText: String) {
        startPauseButton.setTitle(buttonText, forState: UIControlState.Normal)
    }
    
    
    
    
    
    
    
    func clamp(value: Int, ToValue maximumValue: Int) -> Int {
        
        if value > maximumValue {
            return 1
        }
        
        if value < 0 {
            return 0
        }
        
        return value
    }
    
    func currentLeafValueFromPrecent(percentageDone: Float , WithSectionCount sections: Int) -> Int {
        let percentageToGo = 1.0 - percentageDone
        let sectionsByPercent = percentageToGo * Float(sections)
        let current = clamp(Int(sectionsByPercent),
                    ToValue: sections)
        
        return current
    }
    
    func updatePercentageDone(percentageDone: Float) {
        
        if let _gavinWheel = gavinWheel? {
            // At 100% should always be the first leaf
            // But, as soon as it is less, advance to the 2nd leaf.
            // This done on the lines marked belowe 1, 2 & 3

            
            var sections = _gavinWheel.numberOfSections - 1
            sections = sections - 1  // 1
            
            var currentLeafValue = 1 + currentLeafValueFromPrecent(percentageDone,
                                             WithSectionCount: sections)
            currentLeafValue = currentLeafValue + 1 // 2

            if percentageDone == 1.0 { // 3
                if _gavinWheel.currentLeafValue != 1 {
                    _gavinWheel.animateToLeafByValue(1)
                }
            } else if _gavinWheel.currentLeafValue != currentLeafValue {
                _gavinWheel.animateToLeafByValue(currentLeafValue)
            }
        }
    }
    
    
    
    
    func updateSeconds(secondsLeft: NSTimeInterval) {
    }
    
    // MARK: ImageWheelDelegate
    func wheelDidChangeValue(newValue: String) {
//        println(newValue)
    }

    // MARK:
    func gavinWheelSize() -> (CGFloat) {
        let height = self.view.bounds.height
        let width = self.view.bounds.width
        
        var gavinWheelSize = height
        if width > height {
            gavinWheelSize = width
        }
        
        return gavinWheelSize * 2
    }
    
    func updateGavinWheelSize() {
        gavinWheelHeight?.constant = gavinWheelSize()
        gavinWheelWidth?.constant = gavinWheelSize()
    }
    
    // MARK: Rotation Methods
    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        updateGavinWheelSize()
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation,
        duration: NSTimeInterval) {
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateGavinWheelSize()
    }

    
    // MARK: Appearance Helper
    private func styleButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
}

