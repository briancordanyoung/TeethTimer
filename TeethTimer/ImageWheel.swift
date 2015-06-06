// MARK: - ImageWheel Summery


import UIKit

typealias ImageIndex = Int
typealias WedgeValue = Int

// MARK: - Enums
enum Parity: String, Printable  {
  case Even = "Even"
  case Odd  = "Odd"

  var description: String {
    return self.rawValue
  }
}



// MARK: - Structs
struct WedgeRegion: Printable {
  var minRadian: CGFloat
  var maxRadian: CGFloat
  var midRadian: CGFloat
  var value: WedgeValue
  
  init(WithMin min: CGFloat,
    AndMax max: CGFloat,
    AndMid mid: CGFloat,
    AndValue valueIn: Int) {
      minRadian = min
      maxRadian = max
      midRadian = mid
      value = valueIn
  }
  
  var description: String {
    return "Wedge Region: \(value) | Angles: min \(minRadian) mid \(midRadian) max \(maxRadian)"
  }
}


// MARK: -
// MARK: - ImageWheel Class
final class ImageWheel: UIView {

  // public properties

  // ImageWheel builds completely on the state of currentRotation
  var rotationAngle = CGFloat(0) { //rotationAngle
    didSet {
      updateAppearanceForRotation(currentRotation)
    }
  }
  
  
  var centerRotationForSection: CGFloat {
    var angle      = wedgeWheelAngle(currentRotation)
    let midAngle   = currentWedge.midRadian

    var difference = angle - midAngle
    while abs(difference) > wedgeWidthAngle {
      if difference > 0 {
        angle -= Circle.full
      } else {
        angle += Circle.full
      }
      difference = angle - midAngle
    }

    return currentRotation - difference
  }
  
  // Internal properties
  let dev = Developement()
  
  // Image and Wedge Properties
  let wedgeImageHeight: CGFloat  = 800 * 0.9
  let wedgeImageWidth:  CGFloat  = 734 * 0.9
  var wedgeImageAspect: CGFloat {
    return wedgeImageWidth / wedgeImageHeight
  }
  
  let images:          [UIImage]

  // Image and Wedge Properties
  var wedges: [WedgeRegion] = []
  var visualState = ImageWheelVisualState()
  

  // Computed properties
  var currentRotation: CGFloat {
    return rotationAngle
  }
  
  var wedgeWidthAngle: CGFloat {
    return Circle.full / CGFloat(wedges.count)
  }

  func wedgeWidthAngleForWedgeCount(wedgeCount: Int) -> CGFloat {
    return Circle.full / CGFloat(wedgeCount)
  }

  var wedgeCountParity: Parity {
    return wedgeCountParityForCount(wedges.count)
  }
  
  // MARK: -
  // MARK: Initialization
  init(Sections sectionsCount: Int,
             AndImages images: [UIImage]) {
              
    self.images = images
    super.init(frame: CGRect())
    

    createWedges(sectionsCount)
    updateAppearanceForRotation(currentRotation)
  }
  
  required init(coder: NSCoder) {
    // TODO: impliment coder and decoder
    self.images = []
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  // MARK: Setup Methods
  func createWedges(count: Int) {
    let wedgeWidthAngle = wedgeWidthAngleForWedgeCount(count)

    let wedgeStartingAngle = (Circle.half * 3) + (wedgeWidthAngle / 2)
    // Build WedgeImageView for each pie piece
    for i in 1...count {
      
      let wedgeAngle = (CGFloat(wedgeWidthAngle) * CGFloat(i)) - wedgeStartingAngle
      
      var imageView = WedgeImageView(image: imageOfNumber(i))
      imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
      imageView.transform = CGAffineTransformMakeRotation(wedgeAngle)
      imageView.angleWidth = wedgeWidthAngle
      imageView.tag = i
      
      self.addSubview(imageView)
    }
    
    
    self.userInteractionEnabled = false
    
    if wedgeCountParityForCount(count) == .Even {
      createWedgeRegionsEven(count)
    } else {
      createWedgeRegionsOdd(count)
    }
}
  
  
  func wedgeCountParityForCount(count: Int) -> Parity {
    var result: Parity
    if count % 2 == 0 {
      result = .Even
    } else {
      result = .Odd
    }
    return result
  }
  
  
  func createWedgeRegionsEven(count: Int) {
    let wedgeWidthAngle = wedgeWidthAngleForWedgeCount(count)

    var mid = Circle.half - (wedgeWidthAngle / 2)
    var max = Circle.half
    var min = Circle.half - wedgeWidthAngle
    
    for i in 1...count {
      max = mid + (wedgeWidthAngle / 2)
      min = mid - (wedgeWidthAngle / 2)
      
      var wedge = WedgeRegion(WithMin: min,
                               AndMax: max,
                               AndMid: mid,
                             AndValue: i)
      
      mid -= wedgeWidthAngle
      
      wedges.append(wedge)
    }
  }
  
  
  func createWedgeRegionsOdd(count: Int) {
    let wedgeWidthAngle = wedgeWidthAngleForWedgeCount(count)

    var mid = Circle.half - (wedgeWidthAngle / 2)
    var max = Circle.half
    var min = Circle.half -  wedgeWidthAngle
    
    for i in 1...count {
      max = mid + (wedgeWidthAngle / 2)
      min = mid - (wedgeWidthAngle / 2)
      
      var wedge = WedgeRegion(WithMin: min,
                               AndMax: max,
                               AndMid: mid,
                             AndValue: i)
      
      mid -= wedgeWidthAngle
      
      if (wedge.maxRadian < -Circle.half) {
        mid = (mid * -1)
        mid -= wedgeWidthAngle
      }
      
      wedges.append(wedge)
    }
  }
  
  
  override func didMoveToSuperview() {
    addSelfContraints()
    addWedgeContraints(wedges.count)
  }
  
  func addSelfContraints() {
    if let superview = self.superview {
      let viewsDictionary = ["wheel":self]
      
      let height:[AnyObject] =
      NSLayoutConstraint.constraintsWithVisualFormat( "V:|[wheel]|",
                                             options: NSLayoutFormatOptions(0),
                                             metrics: nil,
                                               views: viewsDictionary)
      
      let width:[AnyObject] =
      NSLayoutConstraint.constraintsWithVisualFormat( "H:|[wheel]|",
                                             options: NSLayoutFormatOptions(0),
                                             metrics: nil,
                                               views: viewsDictionary)
      
      superview.addConstraints(height)
      superview.addConstraints(width)
    }
  }
  
  func addWedgeContraints(count: Int) {
    self.setTranslatesAutoresizingMaskIntoConstraints(false)

    for i in 1...count {
      if let imageView = imageViewFromValue(i) {
        
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        createCenterContraintsForView(imageView)
        if SystemVersion.iOS8AndUp() {
          createHeightAndAspectContraintsForView(imageView)
        } else {
          createHeightAndWidthContraintsForView(imageView)
        }
      }
    }
  }

  
  func createCenterContraintsForView(imageView: UIView) {
    let centerY = NSLayoutConstraint(item: imageView,
                                attribute: NSLayoutAttribute.CenterY,
                                relatedBy: NSLayoutRelation.Equal,
                                   toItem: self,
                                attribute: NSLayoutAttribute.CenterY,
                               multiplier: 1.0,
                                 constant: 0.0)
    self.addConstraint(centerY)
    
    let centerX = NSLayoutConstraint(item: imageView,
                                attribute: NSLayoutAttribute.CenterX,
                                relatedBy: NSLayoutRelation.Equal,
                                   toItem: self,
                                attribute: NSLayoutAttribute.CenterX,
                               multiplier: 1.0,
                                 constant: 0.0)
    self.addConstraint(centerX)

  }
  
  // iOS 8 and up
  func createHeightAndAspectContraintsForView(imageView: UIView) {
    let height = NSLayoutConstraint(item: imageView,
                               attribute: NSLayoutAttribute.Height,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: self,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: 0.75,
                                constant: 0.0)
    self.addConstraint(height)
    
    let aspect = NSLayoutConstraint(item: imageView,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: imageView,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: wedgeImageAspect,
                                constant: 0.0)
    self.addConstraint(aspect)

  }
  
  // iOS 7 below
  func createHeightAndWidthContraintsForView(imageView: UIView) {
    let height = NSLayoutConstraint(item: imageView,
                               attribute: NSLayoutAttribute.Height,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: nil,
                               attribute: NSLayoutAttribute.NotAnAttribute,
                              multiplier: 1.0,
                                constant: wedgeImageHeight)
    imageView.addConstraint(height)
    
    let width = NSLayoutConstraint(item: imageView,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: nil,
                               attribute: NSLayoutAttribute.NotAnAttribute,
                              multiplier: 1.0,
                                constant: wedgeImageWidth)
    imageView.addConstraint(width)
  }
  
  // iOS 7 Only
  func updateWedgeImageViewContraints(duration: NSTimeInterval,
                    AndOrientation orientation: UIInterfaceOrientation,
                    AndViewControllerSize size: CGSize) {
    
    let larger  = max(size.width, size.height)
    let smaller = min(size.width, size.height)
    let developementHeight = CGFloat(527.0)
                      
    let ratio: CGFloat
    
    switch orientation {
      case .Unknown,
           .Portrait,
           .PortraitUpsideDown:
        ratio = larger  / developementHeight
      case .LandscapeLeft,
           .LandscapeRight:
        ratio = smaller / developementHeight
    }
    
    let height = self.wedgeImageHeight * ratio
    let width  = self.wedgeImageWidth  * ratio
    
    for i in 1...wedges.count {
      if let imageView = imageViewFromValue(i) {
        for constraintTmp in imageView.constraints() {
          
          let constraint = constraintTmp as! NSLayoutConstraint
          if constraint.firstAttribute == NSLayoutAttribute.Height {
            UIView.animateWithDuration(duration, animations: {
              constraint.constant =  height
            })
          }
          if constraint.firstAttribute == NSLayoutAttribute.Width {
            UIView.animateWithDuration(duration, animations: {
              constraint.constant =  width
            })
          }
        }
      }
    }
  }
  
  
  
  

  // MARK: -
  // MARK: Visual representation of the wheel
  func updateAppearanceForRotation(rotation: CGFloat) {
    setImagesForRotation(rotation)

    let angle = wedgeWheelAngle(rotation)
//    setImageOpacityForAngle(angle)
    setImageWedgeAngleForAngle(angle)
  }

  func setImageWedgeAngleForAngle(var angle: CGFloat) {
    
    visualState.initAngleListWithWedges(wedges)

    angle = angle + (wedgeWidthAngle / 2)
    angle = wedgeWheelAngle(angle)
    
    let twoWedgeWidthAngles = wedgeWidthAngle * 2
    
    for wedge in wedges {
      
      if angle >= wedge.minRadian &&
        angle <=  wedge.maxRadian    {
          
          let percent = percentValue( angle,
                        isBetweenLow: wedge.minRadian,
                             AndHigh: wedge.maxRadian)
          
          let wedgeAngle = twoWedgeWidthAngles * percent
          let wedgeAngleInverted = twoWedgeWidthAngles - wedgeAngle
          
          let neighbor = neighboringWedge(wedge)

          visualState.wedgeAngleList[wedge.value]    = wedgeAngle
          visualState.wedgeAngleList[neighbor.value] = wedgeAngleInverted
      }
    }
    
    visualState.setAnglesOfWedgeImageViews(allWedgeImageViews)
  }
  
  lazy var padNumber: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 2
    numberFormater.maximumIntegerDigits  = 2
    numberFormater.minimumFractionDigits = 0
    numberFormater.maximumFractionDigits = 0
    numberFormater.positivePrefix = ""
    return numberFormater
    }()

  
  func nextIndexFrom( currentIndex: Int,  forSteps stepCount: Int) -> Int {
    var nextIndex = currentIndex + 1
    if nextIndex > stepCount {
      nextIndex = 1
    }
    return nextIndex
  }
  
  func add(steps: Int, fromIndex currentIndex: Int,
                           forSteps stepCount: Int) -> Int {
    var nextIndex = currentIndex
    for i in 1..<steps {
      nextIndex = nextIndexFrom(nextIndex, forSteps: stepCount)
    }
    return nextIndex
  }
  
  func previousIndexFrom( currentIndex: Int,  forSteps stepCount: Int) -> Int {
    var previousIndex = currentIndex - 1
    if previousIndex < 1 {
      previousIndex = stepCount
    }
    return previousIndex
  }
  
  func subtract(steps: Int, fromIndex currentIndex: Int,
                                forSteps stepCount: Int) -> Int {
    var previousIndex = currentIndex
    for i in 1..<steps {
      previousIndex = previousIndexFrom(previousIndex, forSteps: stepCount)
    }
    return previousIndex
  }
  
  func setImagesForRotation(var rotation: CGFloat) {
    
    rotation -= 0.001 // fudge factor that fixes odd jumps on exact rotations

    func halfAnInt(number: Int) -> Int {
      return Int(ceil(Float(number) / 2))
    }
    
    let halfTheWedges  = halfAnInt(wedges.count)
    
    let currentWedge   = wedgeForRotation(rotation).value
    let startWedge     = subtract( halfTheWedges,
                        fromIndex: currentWedge,
                         forSteps: wedges.count)
    var wedge          = startWedge
    
    let currentImage   = imageIndexForRotation(rotation)
    let startImage     = subtract( halfTheWedges,
                        fromIndex: currentImage,
                         forSteps: images.count)
    
    var imageNumber    = startImage
    
    var wedgeImages: [Int:Int] = [:]
    
    for i in 1...wedges.count {
      if let imageView = imageViewFromValue(wedge) {
        
        let image = imageOfNumber(imageNumber)
        if imageView.image !== image {
          imageView.image = image
        }
      }
      wedgeImages[wedge] = imageNumber

      wedge       = nextIndexFrom(wedge,       forSteps: wedges.count)
      imageNumber = nextIndexFrom(imageNumber, forSteps: images.count)
    }
  }
  
  
  
  func setImageOpacityForAngle(var angle: CGFloat) {
    
    visualState.initOpacityListWithWedges(wedges)
    
    // Shift the rotation 1/2 a wedge width angle
    // This is to center the effect of changing the opacity.
    angle = angle + (wedgeWidthAngle / 2)
    angle = wedgeWheelAngle(angle)
    
    for wedge in wedges {
      
      if angle >= wedge.minRadian &&
        angle <=  wedge.maxRadian    {
          
          let percent = percentValue( angle,
            isBetweenLow: wedge.minRadian,
            AndHigh: wedge.maxRadian)
          
          visualState.wedgeOpacityList[wedge.value]    = percent
          
          
          let neighbor = neighboringWedge(wedge)
          let invertedPercent = 1 - percent
          visualState.wedgeOpacityList[neighbor.value] = invertedPercent
          
      }
    }
    visualState.setOpacityOfWedgeImageViews(allWedgeImageViews)
  }

  
  
  
  // MARK: -
  // MARK: Image Computed Properties
  var allWedgeImageViews: [WedgeImageView] {
    let views = self.subviews
    
    var wedgeImageViews: [WedgeImageView] = []
    for image in views {
      if image.isKindOfClass(WedgeImageView.self) {
        let imageView = image as! WedgeImageView
        if imageView.tag != 0 {
          wedgeImageViews.append(imageView)
        }
      }
    }
    return wedgeImageViews
  }


  var currentImage: ImageIndex {
    return imageIndexForRotation(currentRotation)
  }
  
  // assumes: images increase as rotation decreases
  var rotationFromFirstToLast: CGFloat {
    return wedgeWidthAngle * CGFloat(images.count - 1)
  }
  
  // assumes: images increase as rotation decreases
  var firstImageRotation: CGFloat {
    return wedgeFromValue(1).midRadian
  }
  
  var lastImageRotation: CGFloat {
    // assumes: images increase as rotation decreases
    return firstImageRotation - rotationFromFirstToLast
  }

  // MARK: Image methods
  func imageForRotation (rotation: CGFloat) -> UIImage? {
    var image: UIImage? = nil

    let imageIndex = imageIndexForRotation(rotation)
    
    if imageIndex <= images.count {
      image = imageOfNumber(imageIndex)
    }
    
    return image
  }
  
  func imageViewForRotation(rotation: CGFloat) -> WedgeImageView? {
    let wedge     = wedgeForRotation(rotation)
    let imageView = imageViewFromValue(wedge.value)
    
    return imageView
  }
  
  func imageIndexForRotation(rotation: CGFloat) -> ImageIndex {
    let startingRotationDifference = -firstImageRotation
    let rotationStartingAtZero     = rotation + startingRotationDifference
    let wedgesFromStart            = rotationStartingAtZero / wedgeWidthAngle
    // assumes: images increase as rotation decreases
    var currentImage = ImageIndex(round(-wedgesFromStart)) + 1
    
    while currentImage > images.count || currentImage < 1 {
      if currentImage < 1 {
        currentImage += images.count
      }
      if currentImage > images.count {
        currentImage -= images.count
      }
    }
    return currentImage
  }
  
  func rotationForImage(image: ImageIndex) -> CGFloat {
    let startingRotation = wedgeFromValue(1).midRadian
    let stepsFromStart   = image - 1
    let rotationToImage  = CGFloat(stepsFromStart) * wedgeWidthAngle
    
    // assumes: images increase as rotation decreases
    return  startingRotation - rotationToImage
  }
  
  // MARK: -
  // MARK: Wedge Computed Properties
  var currentWedge: WedgeRegion {
    return wedgeForRotation(currentRotation)
  }
  
  var currentWedgeValue: WedgeValue {
    return currentWedge.value
  }

  // MARK: Wedge methods
  func wedgeFromValue(value: Int) -> WedgeRegion {
    
    var returnWedge: WedgeRegion?
    
    for wedge in wedges {
      if wedge.value == value {
        returnWedge = wedge
      }
    }
    
    assert(returnWedge != nil, "wedgeFromValue():  No wedge found with value \(value)")
    return returnWedge!
  }

  
  func thisAngle(angle: CGFloat,
    isWithinWedge wedge: WedgeRegion) -> Bool {
      var angleIsWithinWedge = false
      
      if (angle >= wedge.minRadian &&
        angle <= wedge.maxRadian   ) {
          
          angleIsWithinWedge = true
      }
      
      return angleIsWithinWedge
  }

  
  func wedgeForRotation(rotation: CGFloat) -> WedgeRegion {
    let angle = wedgeWheelAngle(rotation)
    return wedgeForAngle(angle)
  }
  
  func wedgeForAngle(angle: CGFloat) -> WedgeRegion {
    
    // Determin where the wheel is (which wedge we are within)
    var currentWedge: WedgeRegion?
    for wedge in wedges {
      if thisAngle(angle, isWithinWedge: wedge) {
        currentWedge = wedge
        break
      }
    }
    
    assert(currentWedge != nil,"wedgeForAngle() may not be nil. Wedges do not fill the circle.")
    return currentWedge!
  }

  
  func neighboringWedge(wedge: WedgeRegion) -> WedgeRegion {
    var wedgeValue = wedge.value
    if wedgeValue == wedges.count {
      wedgeValue = 1
    } else {
      ++wedgeValue
    }
    
    let otherWedge = wedgeFromValue(wedgeValue)
    return otherWedge
  }
  
  // MARK: -
  // MARK: Angle Helpers
  
  // wedgeWheelAngle uses multiplication to normilize any rotation
  // on to the wedge wheel from approximately (-M_PI) thru (M_PI)
  // This is approximate due to floating point rounding errors.
  // first and last wedges are used to define min and max instead of
  // Circle.half & -Circle.half for this reason.
  func wedgeWheelAngle(rotation: CGFloat) -> CGFloat {
    let max = wedges.first!.maxRadian
    let min = wedges.last!.minRadian
    var angle = rotation
    
    if angle >  max {
      angle += Circle.half
      let totalRotations = floor(angle / Circle.full)
      angle  = angle - (Circle.full * totalRotations)
      angle -= Circle.half
    }
    
    if angle < min {
      angle -= Circle.half
      let totalRotations = floor(abs(angle) / Circle.full)
      angle  = angle + (Circle.full * totalRotations)
      angle += Circle.half
    }
    
    return angle
  }
  
  // wedgeWheelAngle uses addition/subtraction to normilize any rotation
  // on to the wedge wheel from approximately (-M_PI) thru (M_PI)
  // This is approximate due to floating point rounding errors.
  // first and last wedges are used to define min and max instead of
  // Circle.half & -Circle.half for this reason.
//  func wedgeWheelAngle(var angle: CGFloat) -> CGFloat {
//    let max = wedges.first!.maxRadian
//    let min = wedges.last!.minRadian
//    
//    while angle > max || angle < min {
//      if angle > max {
//        angle -= Circle.full
//      }
//      if angle < min {
//        angle += Circle.full
//      }
//    }
//    return angle
//  }
  

  
  // MARK: Math Helpers
  func percentValue(value: CGFloat,
       isBetweenLow   low: CGFloat,
       AndHigh       high: CGFloat ) -> CGFloat {
      return (value - low) / (high - low)
  }

  // MARK: image and imageView helpers
  func imageViewFromValue(value: Int) -> WedgeImageView? {
    
    var wedgeView: WedgeImageView?
    
    for image in allWedgeImageViews {
      let imageView = image as WedgeImageView
      if imageView.tag == value {
        wedgeView = imageView
      }
    }
    
    return wedgeView
  }
  
  func imageOfNumber(i: Int) -> UIImage {
    return images[i - 1]
  }

  func imageNumberFromImage(image: UIImage) -> Int? {
    var imageNumber: Int?
    for i in 1...images.count {
      if images[i - 1] === image {
        imageNumber = i
      }
    }
    return imageNumber
  }

  
}