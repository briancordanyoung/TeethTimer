import UIKit

// MARK: -
// MARK: TimerViewController class
final class TimerViewController: UIViewController {

  // MARK: Properties
  @IBOutlet weak var startPauseButton: UIButton!
  @IBOutlet weak var resetButton:      UIButton!
  @IBOutlet weak var timerLabel:       UILabel!
  @IBOutlet weak var fullScreenImage:  UIImageView!
  @IBOutlet weak var controlView:      UIView!
  @IBOutlet weak var lowerThirdView:   UIView!
  
  @IBOutlet weak var testButton:       UIButton!
  
  @IBOutlet weak var posNegLabel:      UILabel!
  @IBOutlet weak var flippedLabel:     UILabel!
  
  let timer = Timer()
  
  var gavinWheelHeight: NSLayoutConstraint?
  var gavinWheelWidth: NSLayoutConstraint?
  var gavinWheel: WheelControl?
  
  var previousImageBeforeTouch: ImageIndex?
  var timerStateBeforeTouch: TimerStatus = .Paused
  
  // A computed property to make it easy to access the ImageWheel inside gavinWheel
  var imageWheelView: ImageWheel? {
    var imageWheel: ImageWheel? = nil
    if let gavinWheel = gavinWheel {
        imageWheel = imageWheelFromWheelControl(gavinWheel)
    }
    return imageWheel
  }

  // MARK: -
  // MARK: View Controller Methods
  override func viewDidLoad() {
      
    super.viewDidLoad()
      
//  fullScreenImage.image = UIImage(named: "background")
    
    styleButton(resetButton)
    styleButton(startPauseButton)
    
    let gavinWheel = WheelControl()

    controlView.insertSubview(gavinWheel, belowSubview: lowerThirdView)

    gavinWheelHeight = NSLayoutConstraint(item: gavinWheel,
                                     attribute: NSLayoutAttribute.Height,
                                     relatedBy: NSLayoutRelation.Equal,
                                        toItem: nil,
                                     attribute: NSLayoutAttribute.NotAnAttribute,
                                    multiplier: 1.0,
                                      constant: gavinWheelSize())
    if let gavinWheelHeight = gavinWheelHeight {
        gavinWheel.addConstraint(gavinWheelHeight)
    }
    
    gavinWheelWidth = NSLayoutConstraint(item: gavinWheel,
                                    attribute: NSLayoutAttribute.Width,
                                    relatedBy: NSLayoutRelation.Equal,
                                       toItem: nil,
                                    attribute: NSLayoutAttribute.NotAnAttribute,
                                   multiplier: 1.0,
                                     constant: gavinWheelSize())
    if let gavinWheelWidth = gavinWheelWidth {
        gavinWheel.addConstraint(gavinWheelWidth)
    }
  
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
    
    gavinWheel.addTarget( self,
                  action: "gavinWheelChanged:",
        forControlEvents: UIControlEvents.ValueChanged)
    
    gavinWheel.addTarget( self,
                  action: "gavinWheelTouchedByUser:",
        forControlEvents: UIControlEvents.TouchDown)
    
    
    let events: [UIControlEvents] = [ .TouchUpInside,
                                      .TouchUpOutside,
                                      .TouchDragExit,
                                      .TouchDragOutside,
                                      .TouchCancel ]
    
    for event in events {
      gavinWheel.addTarget( self,
                    action: "gavinWheelRotatedByUser:",
          forControlEvents: event)
    }
    
    let images = arrayOfImages(10)
    let imageWheel = ImageWheel(Sections: 6, AndImages: images)
    gavinWheel.wheelView.addSubview(imageWheel)
    
    // Set the inital rotation
    let startingRotation = imageWheel.wedgeFromValue(1).midRadian

    imageWheel.rotationAngle = CGFloat(startingRotation)
    gavinWheel.rotationAngle = CGFloat(startingRotation)
    gavinWheel.maximumRotation = imageWheel.firstImageRotation
    gavinWheel.minimumRotation = imageWheel.lastImageRotation
    gavinWheel.dampenCounterClockwise = true
    self.gavinWheel = gavinWheel
    
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Timer uses a Closure/Block based callback API
    // Set the properties with our callback functions
    timer.statusChangedHandler = updateButtonTitleWithText
    timer.timerUpdatedHandler  = updateTimerDisplay
    timer.reset()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: View Controller Rotation Methods
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
  
  // MARK: -
  // MARK: Button Actions
  @IBAction func startStopPressed(sender: UIButton) {
    switch timer.status {
      case .Ready,
           .Paused:
        timer.start()
      case .Counting:
        timer.pause()
      case .Completed:
        timer.reset()
    }
  }
  
  @IBAction func resetPressed(sender: UIButton) {
    timer.reset()
  }
  
  // MARK: -
  // MARK: ImageWheelControl Target/Action Callbacks
  func gavinWheelTouchedByUser(gavinWheel: WheelControl) {
    // User touches the wheel
    if let imageWheelView = imageWheelView {
      previousImageBeforeTouch = imageWheelView.currentImage
    }
    
    timerStateBeforeTouch = timer.status
    if timerStateBeforeTouch == .Counting {
      timer.pause()
    }
  }
  
  func gavinWheelChanged(gavinWheel: WheelControl) {
    // Update the state of the ImageWheel to the WheelControl state
    if let imageWheelView = imageWheelView {
      imageWheelView.rotationAngle = gavinWheel.rotationAngle
      gavinWheel.snapToRotation    = imageWheelView.centerRotationForSection
    }
  }
  
  func gavinWheelRotatedByUser(gavinWheel: WheelControl) {
    if let previousImageBeforeTouch = previousImageBeforeTouch,
                     imageWheelView = imageWheelView {

      if previousImageBeforeTouch > imageWheelView.currentImage {
        // The wheel was turned back.
        let targetRotation = gavinWheel.targetRotationAngle
        let targetImage = imageWheelView.imageIndexForRotation(targetRotation)
        let wheelTurnedBackByTmp = previousImageBeforeTouch - targetImage
        let wheelTurnedBackBy = max(wheelTurnedBackByTmp,0)
        
                                              // 1st image is not in count down
        let imagesInCountDown = imageWheelView.images.count - 1
        let percentageTurnedBackBy = CGFloat(wheelTurnedBackBy) /
                                     CGFloat(imagesInCountDown)
        
        timer.addTimeByPercentage(percentageTurnedBackBy)
      }
      self.previousImageBeforeTouch = nil
    }
    
    if timerStateBeforeTouch == .Counting {
      timer.start()
    }
  }
  
  // MARK: -
  // MARK: Callbacks to pass to the Timer class
  func updateButtonTitleWithText(status: TimerStatus) {
    var buttonText: String
    
    switch status {
      case .Ready:
        buttonText = "Start"
      case .Counting:
        buttonText = "Pause"
      case .Paused:
        buttonText = "Continue"
      case .Completed:
        buttonText = "Done"
    }
    
    startPauseButton.setTitle(buttonText, forState: UIControlState.Normal)
  }

  func updateTimerDisplay(timer: Timer?) {
    if let timer = timer {
      let percentageRemaining = timer.percentageRemaining
      
      let d = Developement()
      updateWheelWithpercentageRemaining(percentageRemaining)
      
      timerLabel.text = timeStringFromDuration(timer.secondsRemaining)
      
      if timer.status == .Completed {
        println("original timer:        \(timer.duration)")
        println("total running time:    \(timer.secondsElapsedAtPause)")
        println("total additional time: \(timer.secondsAddedAfterStart)")
      }
    }
  }

  func updateWheelWithpercentageRemaining(percentageRemaining: CGFloat) {
    if let     gavinWheel = gavinWheel,
       let imageWheelView = imageWheelView {

      let firstAndLastStep = 2
      let stepsToCountDown = imageWheelView.images.count - firstAndLastStep

      let nextImageFromSteps = currentWheelValueFromPrecent( percentageRemaining,
                                           WithSectionCount: stepsToCountDown)
      let nextImage                 = nextImageFromSteps + firstAndLastStep

      let countDownHasNotBegun      = percentageRemaining == 1.0
      
      let currentImage              = imageWheelView.currentImage
      let notDisplayingFirstImage   = currentImage > 1
      let rotateToFirstImage        = countDownHasNotBegun &&
                                      notDisplayingFirstImage
        
      let notDisplayingCurrentImage = imageWheelView.currentImage != nextImage
      let notAlreadyAnimating       = gavinWheel.animationState   == .AtRest
      let rotateToNextImage         = notDisplayingCurrentImage &&
                                      notAlreadyAnimating
      
      if countDownHasNotBegun {
        // At 100% should always be the first image
        if rotateToFirstImage  {
          let rotation = imageWheelView.rotationForImage(1)
          gavinWheel.animateToRotation(rotation)
        }
        
      } else if rotateToNextImage {
        // As soon as percentageRemaining is less than 100%, 
        // advance to the next image.
        let rotation = imageWheelView.rotationForImage(nextImage)
        gavinWheel.animateToRotation(rotation)
      }
    }
  }


  // MARK: Timer Callback helper Methods
  
  // TODO: Create a dictionary for Image and percent total time
  //       alter method to return the current image
  func currentWheelValueFromPrecent(percentageRemaining: CGFloat,
                              WithSectionCount sectionCount: Int) -> Int {
      let percentageDone = 1.0 - percentageRemaining
      let sectionsByPercent = Int(percentageDone * CGFloat(sectionCount))
      let current = clamp(sectionsByPercent, ToValue: sectionCount)
      
      return current
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
  
  // MARK: -
  // MARK: Layout Methods
  func updateGavinWheelSize() {
    gavinWheelHeight?.constant = gavinWheelSize()
    gavinWheelWidth?.constant  = gavinWheelSize()
  }
  
  func gavinWheelSize() -> (CGFloat) {
    let height = self.view.bounds.height
    let width = self.view.bounds.width
    
    var gavinWheelSize = height
    if width > height {
      gavinWheelSize = width
    }
    
    return gavinWheelSize * 2
  }
  
  // MARK: -
  // MARK: Helpers
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
    return "Gavin Poses-s\(paddedTwoDigitNumber(i))"
//    return "num-\(paddedTwoDigitNumber(i))"
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
  
  func imageWheelFromWheelControl(wheelControl: WheelControl) -> ImageWheel? {
    var imageWheel: ImageWheel? = nil
    for viewinWheel in wheelControl.wheelView.subviews {
      if viewinWheel.isKindOfClass(ImageWheel) {
        imageWheel = viewinWheel as? ImageWheel
      }
    }
    return imageWheel
  }
  
  // MARK: Appearance Helper
  private func styleButton(button: UIButton) {
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 15
    button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
    button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
  }

  // MARK: Time to String Helpers
  private func timeStringFromMinutes(minutes: Int,
    AndSeconds seconds: Int) -> String {
      return NSString(format: "%02i:%02i",minutes,seconds) as! String
  }
  
  private func timeStringFromDuration(duration: NSTimeInterval) -> String {
    let durationParts = timeAsParts(duration)
    return timeStringFromMinutes( durationParts.minutes,
      AndSeconds: durationParts.seconds)
  }

  private func timeAsParts(elapsedTimeInterval: NSTimeInterval)
                                            -> (minutes: Int,seconds: Int) {
      var elapsedTime = elapsedTimeInterval
      let elapsedMinsTime = elapsedTime / 60.0
      let elapsedMins = Int(elapsedMinsTime)
      elapsedTime = elapsedMinsTime * 60
      let elapsedSecsTime = elapsedTime - (NSTimeInterval(elapsedMins) * 60)
      let elapsedSecs = Int(elapsedSecsTime)
      
      return (elapsedMins, elapsedSecs)
  }

}

