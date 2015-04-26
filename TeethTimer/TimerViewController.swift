import UIKit

// MARK: -
// MARK: TimerViewController class
final class TimerViewController: UIViewController {

  // MARK: Properties
  @IBOutlet weak var startPauseButton: UIButton!
  @IBOutlet weak var resetButton:      UIButton!
  @IBOutlet weak var timerLabel:       UILabel!
  @IBOutlet weak var wheelCenterView:  UIView!
  @IBOutlet weak var fullScreenImage:  UIImageView!
  @IBOutlet weak var controlView:      UIView!
  @IBOutlet weak var lowerThirdView:   UIImageView!
  @IBOutlet weak var snapshotView:     UIView!
  @IBOutlet weak var testImageView:    UIImageView!
  
  @IBOutlet weak var testButton:       UIButton!
  
  @IBOutlet weak var posNegLabel:      UILabel!
  @IBOutlet weak var flippedLabel:     UILabel!
  
  let timer = Timer()
  
  let dev = Developement()
  
  var gavinWheel: WheelControl?
  var gavinWheelContainer = BugFixContainerView()
  
  var previousImageBeforeTouch: ImageIndex?
  var timerStateBeforeTouch: TimerStatus = .Paused
  
  var blurLowerThird: Bool  {
    return NSUserDefaults.standardUserDefaults().boolForKey("blurLowerThird")
  }
  var viewsAreSetupForBlurring = false
  
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
    gavinWheelContainer.backgroundColor = UIColor.clearColor()
    gavinWheelContainer.opaque = false
    
    let gavinWheel = WheelControl()
    gavinWheelContainer.addSubview(gavinWheel)
    gavinWheelContainer.wheelControl = gavinWheel
    
    gavinWheelContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
    gavinWheel.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    // TODO: Why do I need controlView? If I remove it and use any of the other
    //       statements below, I loose all touch events.
      controlView.insertSubview(gavinWheelContainer, belowSubview: lowerThirdView)
//    snapshotView.insertSubview(gavinWheel, belowSubview: lowerThirdView)
//    snapshotView.addSubview(gavinWheel)
//    self.snapshotView.insertSubview(gavinWheel, belowSubview: lowerThirdView)

    let height = NSLayoutConstraint(item: gavinWheelContainer,
                               attribute: .Width,
                               relatedBy: .Equal,
                                  toItem: self.view,
                               attribute: .Height,
                              multiplier: 2.0, // Twice the height of apps view
                                constant: 0.0)
    self.view.addConstraint(height)

    let aspect = NSLayoutConstraint(item: gavinWheelContainer,
                               attribute: .Width,
                               relatedBy: .Equal,
                                  toItem: gavinWheelContainer,
                               attribute: .Height,
                              multiplier: 1.0,
                                constant: 0.0)
    gavinWheelContainer.addConstraint(aspect)
    

    let centerY = NSLayoutConstraint(item: gavinWheelContainer,
                                attribute: .CenterY,
                                relatedBy: .Equal,
                                   toItem: wheelCenterView,
                                attribute: .CenterY,
                               multiplier: 1.0,
                                 constant: 0.0)
//    centerY.priority = 100.0
//    println("centerY.priority \(centerY.priority)")
    self.view.addConstraint(centerY)
    


    let centerX = NSLayoutConstraint(item: gavinWheelContainer,
                                attribute: .CenterX,
                                relatedBy: .Equal,
                                   toItem: wheelCenterView,
                                attribute: .CenterX,
                               multiplier: 1.0,
                                 constant: 0.0)
//    centerX.priority = 100.0
//    println("centerX.priority \(centerX.priority)")
    self.view.addConstraint(centerX)

    
    let centerYb = NSLayoutConstraint(item: gavinWheel,
                                attribute: .CenterY,
                                relatedBy: .Equal,
                                   toItem: gavinWheelContainer,
                                attribute: .CenterY,
                               multiplier: 1.0,
                                 constant: 0.0)
    gavinWheelContainer.addConstraint(centerYb)
    


    let centerXb = NSLayoutConstraint(item: gavinWheel,
                                attribute: .CenterX,
                                relatedBy: .Equal,
                                   toItem: gavinWheelContainer,
                                attribute: .CenterX,
                               multiplier: 1.0,
                                 constant: 0.0)
    gavinWheelContainer.addConstraint(centerXb)
    
    
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
    
    gavinWheel.backgroundColor = UIColor.redColor()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  func printCenters(label: String) {
    let a = wheelCenterView.center//self.view.convertPoint(wheelCenterView.center, toView: wheelCenterView)
    let b = self.view.convertPoint(gavinWheel!.center, toView: gavinWheel!)
    println("\(label) x:\(dev.pad(a.x)) y:\(dev.pad(a.y))    x:\(dev.pad(b.x)) y:\(dev.pad(b.x))")
  }
  
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
//    printCenters("updateViewConstraints")
  }
  
  func updateViewConstraintsNextLoop() {
    NSTimer.scheduledTimerWithTimeInterval( 0.0,
                                    target: self,
                                  selector: Selector("updateViewConstraints"),
                                  userInfo: nil,
                                   repeats: false)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Timer uses a Closure/Block based callback API
    // Set the properties with our callback functions
    timer.statusChangedHandler = updateButtonTitleWithText
    timer.timerUpdatedHandler  = updateTimerDisplay
    timer.reset()
  }
  
  override func viewDidAppear(animated: Bool) {
    setupAppearenceOfLowerThird()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: View Controller Rotation Methods
  override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    // TODO: animate & stretch snapshot view through screen rotation
      coordinator.animateAlongsideTransition(nil, completion: {
        context in
        if self.blurLowerThird && self.viewsAreSetupForBlurring {
          self.blurLowerThirdView()
        }
      })
  }
  

  
  override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation,
    duration: NSTimeInterval) {
      //  iOS 7 and before only
    if SystemVersion.iOS7AndBelow() {
        imageWheelView?.updateWedgeImageViewContraints( duration,
                                        AndOrientation: toInterfaceOrientation,
                                 AndViewControllerSize: self.view.bounds.size)
    }
  }
  
  
  
      //  iOS 7 and before only
  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    if blurLowerThird && viewsAreSetupForBlurring {
      blurLowerThirdView()
    }
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

    if blurLowerThird && viewsAreSetupForBlurring {
      blurLowerThirdView()
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
  private func styleButton(button: UIButton)  {
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 15
    button.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
    button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
  }
  
  func takeSnapshotOfView(view: UIView) -> UIImage {
    let resolutionScale = CGFloat(0.25)
    
    var size = view.frame.size
    var rect = view.frame
    size.width  *= resolutionScale
    size.height *= resolutionScale
    rect.size   = size
    rect.origin.x = 0
    rect.origin.y = 0
    
    UIGraphicsBeginImageContext(size)
    UIColor.whiteColor().setFill()
    let ctx = UIGraphicsGetCurrentContext()
    CGContextFillRect(ctx, rect)
    view.drawViewHierarchyInRect(rect, afterScreenUpdates:false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }

  func setupAppearenceOfLowerThird() {
    viewsAreSetupForBlurring = true
    if blurLowerThird {
      blurLowerThirdView()
      lowerThirdView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    } else {
      lowerThirdView.image = nil
      lowerThirdView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    }
  }
  
  
  func blurLowerThirdView() {
    var rect = lowerThirdView.frame
    rect.size.height = 88.0;
    rect.origin.y = 0
    
    let lowerThirdImage = takeSnapshotOfView( snapshotView )
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let lowerThirdBlurredImage = lowerThirdImage.applyBlurWithRadius( 8.0,
                                      tintColor: UIColor(white:0.0, alpha: 0.5),
                          saturationDeltaFactor: 2.0,
                                      maskImage: nil)
      dispatch_sync(dispatch_get_main_queue(), {
        self.lowerThirdView.image = lowerThirdBlurredImage
      })
    })
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

