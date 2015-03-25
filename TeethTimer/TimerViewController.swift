import UIKit

// MARK: -
// MARK: - Enums
enum TimerStateAtTouch: String, Printable {
  case Running = "Running"
  case Paused  = "Paused"

  var description: String {
    return self.rawValue
  }
}



// MARK: -
// MARK: TimerViewController class
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
  
  let timer = Timer()
  
  var gavinWheelHeight: NSLayoutConstraint?
  var gavinWheelWidth: NSLayoutConstraint?
  var gavinWheel: WheelControl?
  
  var previousImageBeforeTouch: ImageIndex?
  var timerStateBeforeTouch: TimerStateAtTouch = .Paused
  
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
    timer.updateTimerWithText = updateTimeLabelWithText
    timer.updateUIControlText = updateButtonTitleWithText
    timer.updateTimerWithPercentage = updatePercentageDone
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
  
  // MARK: -
  // MARK: ImageWheelControl Target/Action Callbacks
  func gavinWheelTouchedByUser(gavinWheel: WheelControl) {
    // User touches the wheel
    if let imageWheelView = imageWheelView {
      previousImageBeforeTouch = imageWheelView.currentImage
    }
    
    if timer.currentlyRunning {
      timerStateBeforeTouch = .Running
      timer.pause()
    } else {
      timerStateBeforeTouch = .Paused
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
    
    if timerStateBeforeTouch == .Running {
      timer.start()
    }
  }
  
  // MARK: -
  // MARK: Callbacks to pass to the Timer class
  func updateTimeLabelWithText(labelText: String) {
    timerLabel.text = labelText
  }
  
  func updateButtonTitleWithText(buttonText: String) {
    startPauseButton.setTitle(buttonText, forState: UIControlState.Normal)
  }
  
  func updatePercentageDone(percentageDone: CGFloat) {

    if let     gavinWheel = gavinWheel,
       let imageWheelView = imageWheelView {
      // At 100% should always be the first image
      // But, as soon as it is less, advance to the 2nd image.
      // This done on the lines marked belowe 1, 2 & 3

      var steps = imageWheelView.images.count - 1
      steps = steps - 1  // 1

      var currentImage = 1 + currentWheelValueFromPrecent( percentageDone,
                                         WithSectionCount: steps)
      currentImage = currentImage + 1 // 2

      if percentageDone == 1.0 { // 3
        if imageWheelView.currentImage != 1 {
          let rotation = imageWheelView.rotationForImage(1)
          gavinWheel.animateToRotation(rotation)
        }
      } else if imageWheelView.currentImage != currentImage {
        let rotation = imageWheelView.rotationForImage(currentImage)
        gavinWheel.animateToRotation(rotation)
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
  
  // TODO: Create a dictionary for Image and percent total time
  //       alter method to return the current image
  func currentWheelValueFromPrecent(percentageDone: CGFloat,
    WithSectionCount sections: Int) -> Int {
      let percentageToGo = 1.0 - percentageDone
      let sectionsByPercent = percentageToGo * CGFloat(sections)
      let current = clamp(Int(sectionsByPercent),
        ToValue: sections)
      
      return current
  }
  
  
  // MARK: -
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
    gavinWheelWidth?.constant  = gavinWheelSize()
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

  
}

