import AVFoundation
import UIKit



// MARK: -
// MARK: TimerViewController class
final class TimerViewController: UIViewController {

  // MARK: Properties
  @IBOutlet weak var startPauseButton: UIButton!
  @IBOutlet weak var resetButton:      UIButton!
  @IBOutlet weak var cacheUIButton:  UIButton!
  @IBOutlet weak var timerLabel:       UILabel!
  @IBOutlet weak var fullScreenImage:  UIImageView!
  @IBOutlet weak var controlView:      UIView!
  @IBOutlet weak var lowerThirdView:   UIImageView!
  @IBOutlet weak var snapshotView:     UIView!
  @IBOutlet weak var testImageView:    UIImageView!
  @IBOutlet weak var videoView:        VideoView!
  
  let timer = Timer()

  // Properties used by extention methods
  var cacheState = CacheWheelState()
  var backgroundVideo = BackgroundVideoProperties()

  var gavinWheel: WheelControl?
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
    
    styleButton(resetButton)
    styleButton(startPauseButton)
    
    let gavinWheel = WheelControl()
    controlView.insertSubview(gavinWheel, belowSubview: lowerThirdView)
    setupGavinWheelConstraints(gavinWheel)
    setupGavinWheelControlEvents(gavinWheel)
    setupImageWheelAndAddToGavinWheel(gavinWheel)
    self.gavinWheel = gavinWheel
    setupVideoBackgroundConstraints()
    setupVideoBackgroundAsset(.Clockwise)
    setupVideoBackgroundAsset(.CounterClockwise)
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
  }
  
  override func willRotateToInterfaceOrientation(
                                 toInterfaceOrientation: UIInterfaceOrientation,
                                               duration: NSTimeInterval) {
      // pre iOS 8 only
    if SystemVersion.iOS7AndBelow() {
        imageWheelView?.updateWedgeImageViewContraints( duration,
                                        AndOrientation: toInterfaceOrientation,
                                 AndViewControllerSize: self.view.bounds.size)
    }
  }
  
  override func didRotateFromInterfaceOrientation(
                             fromInterfaceOrientation: UIInterfaceOrientation) {
  }
  
  // MARK: -
  // MARK: View Setup
  func setupGavinWheelConstraints(gavinWheel: WheelControl) {
    let height = NSLayoutConstraint(item: gavinWheel,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: self.view,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: 2.0,
                                constant: 0.0)
    self.view.addConstraint(height)
    
    let aspect = NSLayoutConstraint(item: gavinWheel,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: gavinWheel,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: 1.0,
                                constant: 0.0)
    gavinWheel.addConstraint(aspect)
    
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
  }
  
  func setupGavinWheelControlEvents(gavinWheel: WheelControl) {
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
  }
  
  func setupImageWheelAndAddToGavinWheel(gavinWheel: WheelControl) {
    let images = arrayOfImages(10)
    let imageWheel = ImageWheel(Sections: 4, AndImages: images)
    gavinWheel.wheelView.addSubview(imageWheel)
    
    // Set the inital rotation
    let startingRotation = imageWheel.wedgeFromValue(1).midRadian
    
    imageWheel.rotationAngle = CGFloat(startingRotation)
    gavinWheel.rotationAngle = CGFloat(startingRotation)
    gavinWheel.maximumRotation = imageWheel.firstImageRotation
    gavinWheel.minimumRotation = imageWheel.lastImageRotation
    gavinWheel.dampenCounterClockwise = true
    
    if SystemVersion.iOS7AndBelow() {
      imageWheel.updateWedgeImageViewContraints( 0,
        AndOrientation: self.interfaceOrientation,
        AndViewControllerSize: self.view.bounds.size)
    }
  }
  
  func setupVideoBackgroundConstraints() {
    let height = NSLayoutConstraint(item: videoView,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: self.view,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: 1.0,
                                constant: 0.0)
    self.view.addConstraint(height)
    
    let aspect = NSLayoutConstraint(item: videoView,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: videoView,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: 1.0,
                                constant: 0.0)
    videoView.addConstraint(aspect)
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
  
  @IBAction func cacheUI(sender: UIButton) {
    cacheUI()
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
      
      let min = gavinWheel.minimumRotation
      let max = gavinWheel.maximumRotation
      
      if let min = min, max = max {
        let current = gavinWheel.currentRotation
        let percentageBetween = percentValue( current,
                                isBetweenLow: min,
                                     AndHigh: max)
        updateBackgroundForPercentDone(percentageBetween)
      }
      
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
  
  // MARK: Blurred Lower Third
  func blurLowerThirdView() {
    var rect = lowerThirdView.frame
    rect.size.height = 88.0;
    rect.origin.y = 0
    
    let lowerThirdImage = takeSnapshotOfView( snapshotView,
                         WithResolutionScale: CGFloat(0.25) )
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let lowerThirdBlurredImage = lowerThirdImage.applyBlurWithRadius( 4.0,
                                      tintColor: UIColor(white:0.0, alpha: 0.5),
                          saturationDeltaFactor: 2.0,
                                      maskImage: nil)
      dispatch_sync(dispatch_get_main_queue(), {
        self.lowerThirdView?.image = lowerThirdBlurredImage
        })
      })
  }

  func takeSnapshotOfView(view: UIView,
                     WithResolutionScale resolutionScale: CGFloat) -> UIImage {
    
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
  
    // MARK:
  // MARK: Appearance Helper
  private func styleButton(button: UIButton)  {
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

  func percentValue(value: CGFloat,
    isBetweenLow   low: CGFloat,
    AndHigh       high: CGFloat ) -> CGFloat {
      return (value - low) / (high - low)
  }
  
}

