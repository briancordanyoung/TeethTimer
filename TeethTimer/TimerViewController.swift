import AVFoundation
import UIKit


let kAppUseCachedUIKey          = "useCachedUI"
let kAppBlurLowerThirdKey       = "blurLowerThird"
let kAppShowTimeLabelKey        = "showTimeLabel"

// MARK: -
// MARK: TimerViewController class
final class TimerViewController: UIViewController {

  // MARK: Properties
  @IBOutlet weak var startPauseButton: UIButton!
  @IBOutlet weak var resetButton:      UIButton!
  @IBOutlet weak var cacheUIButton:    UIButton!
  @IBOutlet weak var timerLabel:       UILabel!
  @IBOutlet weak var fullScreenImage:  UIImageView!
  @IBOutlet weak var controlView:      UIView!
  @IBOutlet weak var lowerThirdView:   UIImageView!
  @IBOutlet weak var snapshotView:     UIView!
  @IBOutlet weak var testImageView:    UIImageView!
  @IBOutlet weak var videoView:        VideoView!
  @IBOutlet weak var debugPosition: NSLayoutConstraint!
  
  @IBOutlet weak var debug: UILabel!
  
  let timer = Timer()
  let d = Developement()

  var gavinWheel: WheelControl?
  var previousIndexBeforeTouch: WedgeIndex?
  var timerStateBeforeTouch: Timer.Status = .Paused
  
  var blurLowerThird: Bool  {
    return NSUserDefaults.standardUserDefaults().boolForKey(kAppBlurLowerThirdKey)
  }
  
  var showTimeLabel: Bool  {
    return NSUserDefaults.standardUserDefaults().boolForKey(kAppShowTimeLabelKey)
  }
  
  var isCashedUI: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(kAppUseCachedUIKey)
    }
    set(isCachedUI) {
      NSUserDefaults.standardUserDefaults().setBool( isCachedUI,
                                             forKey: kAppUseCachedUIKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
  
  var viewsAreSetupForBlurring = false
  
  // A computed property to make it easy to access the ImageWheel inside gavinWheel
  var imageWheelView: InfiniteImageWheel? {
    var imageWheel: InfiniteImageWheel?
    if let gavinWheel = gavinWheel {
        imageWheel = imageWheelFromWheelControl(gavinWheel)
    }
    return imageWheel
  }

  // Properties used by extention methods
  lazy var cacheState: CacheWheelState = {
    return CacheWheelState()
  }()
  lazy var backgroundVideo: BackgroundVideoProperties = {
    return BackgroundVideoProperties()
  }()

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
    
    setupBackground()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Timer uses a Closure/Block based callback API
    // Set the properties with our callback functions
    timer.statusChangedHandler = updateButtonTitleWithText
    timer.timerUpdatedHandler  = updateTimerDisplay
    timer.reset()
    setupAppearence()

//    d.printDocumentFolderPath()    
  }
  
  override func viewDidAppear(animated: Bool) {
    setupAppearenceOfLowerThird()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    imageWheelView?.removeWedgeImageViews()
  }
  
  // MARK: View Controller Rotation Methods
  override func viewWillTransitionToSize(size: CGSize,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
  }
  
  override func willRotateToInterfaceOrientation(
                                 toInterfaceOrientation: UIInterfaceOrientation,
                                               duration: NSTimeInterval) {
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
                  action: "wheelRotated:",
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
                    action: "wheelRotatedByUser:",
          forControlEvents: event)
    }
  }
  
  func setupImageWheelAndAddToGavinWheel(gavinWheel: WheelControl) {
    let imageNames = arrayOfNames(10)
    let imageWheel = InfiniteImageWheel(imageNames: imageNames,
                                  seperatedByAngle: Angle(degrees: 90),
                                       inDirection: .ClockwiseLayout)
    
    gavinWheel.wheelView.addSubview(imageWheel)
    
    // Set the inital rotation
    let startingRotation = imageWheel.rotationState.wedgeCenterForIndex(0)
    let halfWedge = imageWheel.rotationState.wedgeSeries.wedgeSeperation / 2
    let min = imageWheel.rotationState.minimumRotationWithinWedgeSeries
    let max = imageWheel.rotationState.maximumRotationWithinWedgeSeries

    imageWheel.rotation        = startingRotation
    gavinWheel.rotation        = startingRotation
    gavinWheel.minimumRotation = min + halfWedge
    gavinWheel.maximumRotation = max - halfWedge
    gavinWheel.dampenCounterClockwise = true
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
  
  
  func setupAppearence() {
    
    if isCashedUI {
      showCachedUI()
    } else {
      showLiveUI()
      setupAppearenceOfLowerThird()
    }
    
    timerLabel.hidden = !showTimeLabel
    
    if let gavinWheel = gavinWheel {
      wheelRotated(gavinWheel)
    }
    setupVideoBackgroundAsset()
  }
  
  func showCachedUI() {
    cacheUIButton.hidden   = true
    imageWheelView?.removeWedgeImageViews()
    imageWheelView?.hidden = true
    lowerThirdView.hidden  = true
    snapshotView.hidden    = true
    debugPosition.constant = 20
    timerLabel.hidden      = !showTimeLabel
    debug.hidden = false
  }
  
  func showLiveUI() {
    cacheUIButton.hidden   = false
    imageWheelView?.createWedgeImageViews()
    imageWheelView?.hidden = false
    lowerThirdView.hidden  = false
    snapshotView.hidden    = false
    debugPosition.constant = 0
    timerLabel.hidden      = !showTimeLabel
    debug.hidden = false
  }
  
  func setupAppearenceOfLowerThird() {
    viewsAreSetupForBlurring = true
    if blurLowerThird {
      blurLowerThirdView()
      lowerThirdView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    } else {
      lowerThirdView.image = .None
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
    rememberIndex()
    rememberTimerStatueAndPause()
  }
  
  
  func rememberTimerStatueAndPause() {
    timerStateBeforeTouch = timer.status
    if timerStateBeforeTouch == .Counting {
      timer.pause()
    }
  }
  
  func rememberIndex() {
    if let imageWheelView = imageWheelView {
      previousIndexBeforeTouch = imageWheelView.rotationState.wedgeIndex
    }
  }
  
  
  
  func wheelRotated(gavinWheel: WheelControl) {

    if let imageWheelView = imageWheelView {
      
      imageWheelView.rotation    = gavinWheel.rotation
      gavinWheel.snapToRotation  = imageWheelView.wedgeCenter
      
      if let percentageRemaining = gavinWheel.percentageRemaining {
        updateBackgroundForPercentDone(percentageRemaining)
        updateDebugCacheIULabel(debug, WithImageWheel: imageWheelView,
                                        andPercentage: percentageRemaining)
      } else {
        updateDebugCacheIULabel(debug, WithImageWheel: imageWheelView,
                                        andPercentage: 0)
      }
    }

    if blurLowerThird && viewsAreSetupForBlurring {
      blurLowerThirdView()
    }
  }
  
  
  func updateDebugCacheIULabel(label: UILabel,
           WithImageWheel imageWheel: InfiniteImageWheel,
               andPercentage percent: CGFloat) {
    let dev = Developement()
    let rotationString = dev.pad(CGFloat(imageWheel.rotation.degrees))
    label.text = "\(rotationString) \(dev.pad(percent))%"
  }

  
  func wheelRotatedByUser(gavinWheel: WheelControl) {
    
    if let previousIndexBeforeTouch = previousIndexBeforeTouch,
                     imageWheelView = imageWheelView {

      if previousIndexBeforeTouch > imageWheelView.rotationState.wedgeIndex {
        
        // The wheel was turned back.
        let rotation = gavinWheel.rotation
        let index    = imageWheelView.indexFromRotation(rotation)
        
        let wheelTurnedBackByTmp = previousIndexBeforeTouch - index
        let wheelTurnedBackBy    = max(wheelTurnedBackByTmp,0)
        
                                              // 1st image is not in count down
        let imagesInCountDown = imageWheelView.wedgeSeries.wedgeCount - 1
        let percentageTurnedBackBy = CGFloat(wheelTurnedBackBy) /
                                     CGFloat(imagesInCountDown)
        
        timer.addTimeByPercentage(percentageTurnedBackBy)
      }
      self.previousIndexBeforeTouch = .None
    }
    
    if timerStateBeforeTouch == .Counting {
      timer.start()
    }
  }
  
  // MARK: -
  // MARK: Callbacks to pass to the Timer Object
  func updateButtonTitleWithText(status: Timer.Status) {
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
        
      let state = imageWheelView.rotationState

      let wedgeCount         = imageWheelView.wedgeSeries.wedgeCount
      let firstStep          = 1
      let firstAndLastStep   = 2
        
      let stepsToCountDown   = wedgeCount - firstAndLastStep
      let calcedIndexFromSteps = currentIndexFromPercent( percentageRemaining,
                                        WithSectionCount: stepsToCountDown)
      let calcedIndex          = calcedIndexFromSteps + firstStep


      let currentIndex              = state.wedgeIndex
      let notDisplayingFirstImage   = currentIndex != 0
      let countDownHasNotBegun      = percentageRemaining == 1.0
      let rotateToFirstImage        = countDownHasNotBegun &&
                                      notDisplayingFirstImage
        
      let rotateToNextImage         = (currentIndex != calcedIndex) &&
                                      (gavinWheel.animationState == .AtRest)
      
        
      if countDownHasNotBegun {
        // At 100% should always be the first image
        if rotateToFirstImage  {
          let rotation = state.wedgeCenterForIndex(0)
          gavinWheel.animateToRotation(rotation)
        }
        
      } else if rotateToNextImage {
        // As soon as percentageRemaining is less than 100%, 
        // advance to the next image.
        let rotation = state.wedgeCenterForIndex(calcedIndex)
        gavinWheel.animateToRotation(rotation)
      }
    }
  }


  // MARK: Timer Callback helper Methods
  func currentIndexFromPercent(percentageRemaining: CGFloat,
                     WithSectionCount sectionCount: Int) -> Int {
      let percentageDone = 1.0 - percentageRemaining
      let sectionsByPercent = Int(percentageDone * CGFloat(sectionCount))
      let current = clamp(sectionsByPercent, ToValue: sectionCount)
      
      // Subtract 1 to shift it from 1 thru sectionCount into:
      // 0 thru maxIndex
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
  
  
  func arrayOfNames(count: Int) -> [String] {
    var nameArray: [String] = []
    for i in 1...count {
//    for i in 0..<count {
      nameArray.append(imageNameForNumber(i))
    }
    return nameArray
  }
  
  func imageWheelFromWheelControl(wheelControl: WheelControl) -> InfiniteImageWheel? {
    var imageWheel: InfiniteImageWheel?
    for viewinWheel in wheelControl.wheelView.subviews {
      if viewinWheel.isKindOfClass(InfiniteImageWheel) {
        imageWheel = viewinWheel as? InfiniteImageWheel
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

}

