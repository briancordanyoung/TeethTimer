import UIKit

class TimerViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var fullScreenImage: UIImageView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var lowerThirdView: UIView!
    
    @IBOutlet weak var testButton: UIButton!
    
    @IBOutlet weak var posNegLabel: UILabel!
    @IBOutlet weak var flippedLabel: UILabel!
    
    
    var gavinWheelHeight: NSLayoutConstraint?
    var gavinWheelWidth: NSLayoutConstraint?
    var gavinWheel: ImageWheelControl?
    
    let timer = Timer()

    // MARK: View Controller Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        fullScreenImage.image = UIImage(named: "background")
        
        
        styleButton(resetButton)
        styleButton(startPauseButton)
        
        let images = arrayOfImages(10)
        let gavinWheel = ImageWheelControl(WithSections: 10, AndImages: images)
        
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

        gavinWheel.addConstraintsToViews()
        gavinWheel.addTarget(self,
            action: "gavinWheelRotatedByUser:",
            forControlEvents: UIControlEvents.TouchUpInside)
        
        gavinWheel.addTarget(self,
            action: "gavinWheelChanged:",
            forControlEvents: UIControlEvents.ValueChanged)
        
        gavinWheel.addTarget(self,
            action: "gavinWheelTouchedByUser:",
            forControlEvents: UIControlEvents.TouchDown)

        gavinWheel.wheelTurnedBackBy = wheelTurnedBackByFunc
        self.gavinWheel = gavinWheel
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Timer uses a Closure/Block based callback API
        // Set the properties with our callback functions
        timer.updateTimerWithText = updateTimeLabelWithText
        timer.updateUIControlText = updateButtonTitleWithText
        timer.updateTimerWithPercentage = updatePercentageDone
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
    }
    
    // MARK: ImageWheelControl Target/Action Callback
    func gavinWheelRotatedByUser(gavinWheel: ImageWheelControl) {
    }
    
    func gavinWheelChanged(gavinWheel: ImageWheelControl) {
    }
    
    func gavinWheelTouchedByUser(gavinWheel: ImageWheelControl) {
    }
    
    // MARK: Callbacks to pass to the Timer class
    func updateTimeLabelWithText(labelText: String) {
        timerLabel.text = labelText
    }
    
    func updateButtonTitleWithText(buttonText: String) {
        startPauseButton.setTitle(buttonText, forState: UIControlState.Normal)
    }
    
    // MARK: Callbacks to pass to the ImageWheel class
    func wheelTurnedBackByFunc(Wedge: Int,  AndPercentage percentage: CGFloat) {
        timer.addTimeByPercentage(percentage)
    }
    
    func updatePercentageDone(percentageDone: CGFloat) {
        
        if let gavinWheel = gavinWheel {
            // At 100% should always be the first leaf
            // But, as soon as it is less, advance to the 2nd leaf.
            // This done on the lines marked belowe 1, 2 & 3

            // TODO: Change numberOfWedges to numberOfImages
            var sections = gavinWheel.numberOfWedges - 1
            sections = sections - 1  // 1
            
            var currentLeafValue = 1 + currentLeafValueFromPrecent(percentageDone,
                                             WithSectionCount: sections)
            currentLeafValue = currentLeafValue + 1 // 2

            if percentageDone == 1.0 { // 3
                if gavinWheel.currentWedgeValue != 1 {
                    gavinWheel.animateToWedgeByValue( 1,
                                         inDirection: .Negitive)
                }
            } else if gavinWheel.currentWedgeValue != currentLeafValue {
                gavinWheel.animateToWedgeByValue( currentLeafValue,
                                     inDirection: .Positive)
            }
        }
    }
    
    // MARK: Timer Callback helper Methods
    func clamp(value: Int, ToValue maximumValue: Int) -> Int {
        
        if value > maximumValue {
            return 1
        }
        
        if value < 0 {
            return 0
        }
        
        return value
    }
    
    func currentLeafValueFromPrecent(percentageDone: CGFloat,
                          WithSectionCount sections: Int) -> Int {
        let percentageToGo = 1.0 - percentageDone
        let sectionsByPercent = percentageToGo * CGFloat(sections)
        let current = clamp(Int(sectionsByPercent),
            ToValue: sections)
        
        return current
    }
    
    
    // MARK: Layout Methods
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

    
    func paddedTwoDigitNumber(i: Int) -> String {
        var paddedTwoDigitNumber = "00"
        
        let numberFormater = NSNumberFormatter()
        numberFormater.minimumIntegerDigits  = 2
        numberFormater.maximumIntegerDigits  = 2
        numberFormater.minimumFractionDigits = 0
        numberFormater.maximumFractionDigits = 0
        
        if let numberString = numberFormater.stringFromNumber(i) {
            paddedTwoDigitNumber = numberString
        }
        return paddedTwoDigitNumber
    }
    
    func imageNameForNumber(i: Int) -> String {
//                return "Gavin Poses-s\(paddedTwoDigitNumber(i))"
        return "num-\(paddedTwoDigitNumber(i))"
    }

    func arrayOfImages(count: Int) -> [UIImage] {
        var imageArray: [UIImage] = []
        for i in 1...count {
            if let image = UIImage(named: imageNameForNumber(i)) {
                imageArray.append(image)
            }
        }
        
        return imageArray
    }
    
    

    // MARK: Appearance Helper
    private func styleButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
}

