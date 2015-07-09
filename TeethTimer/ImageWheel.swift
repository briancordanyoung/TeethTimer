import UIKit

typealias ImageIndex = Int
typealias WedgeValue = Int

// TODO: Refactor WedgeRegions and WedgeImageViews:

//     Regions (was WedgeRegion):
//       New property: WedgeImageView.
//               On assignment, it is transformed (rotated) in to place,
//       New property: percentInView
//               On set, Set WedgeImageView opacity or angle
//               (remove need for ImageWheel.VisualState)
//     ImageWheel:
//       New property: Array  WedgeImageURLs created on init (non-mutating)
//       New property: Array of All WedgeImageViews.
//          methods to create/destroy
//          create a dequeue method to assign different WedgeImageViews
//          to each wedge, transform it in to the wedge position,
//       New Methods to create/destroy edgeImageViews & contraints on demand.
//       (for when UICashing is on)



// MARK: - Structs
struct WedgeRegion: Printable {
  var minAngle: Angle
  var maxAngle: Angle
  var midAngle: Angle
  var value: WedgeValue
  var formatter = NSNumberFormatter()
  
  var minRotation: Rotation {
    if minAngle < midAngle &&
       minAngle < maxAngle {
      
      return Rotation(minAngle)
    } else {
      return Rotation(minAngle.value - Double(M_PI * 2))
    }
  }
  
  var midRotation: Rotation {
    return Rotation(midAngle)
  }
  
  var maxRotation: Rotation {
    if maxAngle > midAngle &&
      maxAngle.value > minRotation.value {
        
        return Rotation(maxAngle)
    } else {
      return Rotation(maxAngle.value + Double(M_PI * 2))
    }
  }

  
  init(WithMin min: Angle,
        AndMax max: Angle,
        AndMid mid: Angle,
  AndValue valueIn: Int) {
      minAngle = min
      maxAngle = max
      midAngle = mid
      value = valueIn
    
    formatter.minimumIntegerDigits  = 1
    formatter.maximumIntegerDigits  = 1
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.positivePrefix = " "
    formatter.negativeFormat = "-"
  }
  
  var description: String {
    return "Wedge Region: \(formatter.stringFromNumber(value)!) | Angles: min \(formatter.stringFromNumber(minRotation.value)!) mid \(formatter.stringFromNumber(midRotation.value)!) max \(formatter.stringFromNumber(maxRotation.value)!)"
  }
  
  
}


// MARK: -
// MARK: - ImageWheel Class
final class ImageWheel: UIView {
  // public properties

  // ImageWheel builds completely on the state of currentRotation
  var rotation = Rotation(0.0) { //rotationAngle
    didSet {
      updateAppearanceForRotation(rotation)
    }
  }
  
  
  var rotationForCenterOfCurrentWedge: Rotation {
    let angle      = Angle(self.rotation)
    let midAngle   = Rotation(currentWedge.midAngle)
    
    var workingRotation = Rotation(angle)

    var difference = workingRotation - midAngle
    while abs(difference) > Rotation(wedgeWidthAngle) {
      if difference > 0 {
        workingRotation -= Rotation.full
      } else {
        workingRotation += Rotation.full
      }
      difference = workingRotation - midAngle
    }

    return self.rotation - difference
  }
  
  // Internal properties
  let dev = Developement()
  
  var isCashedUI: Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(kAppUseCachedUIKey)
  }

  // Image and Wedge Properties
  let wedgeImageHeight: CGFloat  = 800 * 0.9
  let wedgeImageWidth:  CGFloat  = 734 * 0.9
  var wedgeImageAspect: CGFloat {
    return wedgeImageWidth / wedgeImageHeight
  }
  
  let images:          [UIImage]

  // Image and Wedge Properties
  var wedges: [WedgeRegion] = []
  var visualState = ImageWheel.VisualState()
  

  var wedgeWidthAngle: Angle {
    return Angle(((M_PI * 2) / Double(wedges.count)))
  }

  func wedgeWidthAngleForWedgeCount(wedgeCount: Int) -> Angle {
    let tau             = CGFloat(M_PI * 2)
    let wedgeWidthAngle = tau / CGFloat(wedgeCount)
    return Angle(wedgeWidthAngle)
  }

  // MARK: -
  // MARK: Initialization
  init(Sections sectionsCount: Int,
             AndImages images: [UIImage]) {
              
    self.images = images
    super.init(frame: CGRect())
    
    self.userInteractionEnabled = false
    createWedges(sectionsCount)
    updateAppearanceForRotation(rotation)
  }
  
  required init(coder: NSCoder) {
    // TODO: impliment coder and decoder
    self.images = []
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  // MARK: Setup Methods
  func createWedges(count: Int) {
    createWedgeViews(count)
    createWedgeRegions(count)
  }

  func createWedgeViews(count: Int) {
    let wedgeWidthAngle = Rotation(wedgeWidthAngleForWedgeCount(count))
    
    let wedgeStartingAngle = (Rotation.half * 3) + (wedgeWidthAngle / 2)
    // Build WedgeImageView for each pie piece
    for i in 1...count {
      
      let wedgeAngle = (wedgeWidthAngle * Rotation(i)) - wedgeStartingAngle
      
      var imageView = WedgeImageView(image: imageOfNumber(i))
      imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
      imageView.transform = CGAffineTransformMakeRotation(CGFloat(wedgeAngle))
      imageView.angleWidth = Angle(wedgeWidthAngle)
      imageView.tag = i
      
      self.addSubview(imageView)
    }
  }
  
  func createWedgeRegions(count: Int) {
    let wedgeWidthAngle = Revolution(wedgeWidthAngleForWedgeCount(count)).value
    
    var mid = Revolution(M_PI) - Revolution(wedgeWidthAngle / 2)
    var max = Revolution(M_PI)
    var min = Revolution(M_PI) - Revolution(wedgeWidthAngle)
    
    for i in 1...count {
      if i == 4 {

      }
      
      max = mid + Revolution(wedgeWidthAngle / 2)
      min = mid - Revolution(wedgeWidthAngle / 2)
      
      var wedge = WedgeRegion(WithMin: Angle(min.value),
                               AndMax: Angle(max.value),
                               AndMid: Angle(mid.value),
                             AndValue: i)
      
      mid -= Revolution(wedgeWidthAngle)
      
//      if count.parity == .Odd && (wedge.maxAngle < -Revolution(M_PI)) {
//        mid = (mid * -1)
//        mid -= wedgeWidthAngle
//      }
      println("\(wedge)")
      
//      if i == 4 {
//        println("      min \(min.value) \nwedge.min \(wedge.minRotation.value)\n          \(wedge.minAngle.value - (M_PI * 2))\n          \(M_PI * -1)\n          \(Double(M_PI) - (Double(M_PI) * 2))")
//      }
      
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
        createHeightAndAspectContraintsForView(imageView)
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
  

  // MARK: -
  // MARK: Visual representation of the wheel
  func updateAppearanceForRotation(rotation: Rotation) {
    if !isCashedUI {

      setImagesForRotation(rotation)

      let angle = Angle(rotation)
      // setImageOpacityForAngle(angle)
      setImageWedgeAngleForAngle(angle)
    }
  }

  func setImageWedgeAngleForAngle(var angle: Angle) {
    visualState.initAngleListWithWedges(wedges)

    angle = angle + (wedgeWidthAngle / 2)
    
    let twoWedgeWidthAngles = wedgeWidthAngle * 2
    
    for wedge in wedges {
      
      if angle >= wedge.minAngle &&
        angle <=  wedge.maxAngle    {
          
          let percent = percentValue( angle,
                        isBetweenLow: wedge.minAngle,
                             AndHigh: wedge.maxAngle)
          
          let wedgeAngle = twoWedgeWidthAngles * Angle(percent)
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
  
  func setImagesForRotation(var rotation: Rotation) {
 
//    let start = NSDate()
//    let end = NSDate()
//    let totalTime = end.timeIntervalSinceDate(start)
//    println("totalTime: \(totalTime)")

    
    
    rotation -= 0.001 // yucky fudge factor that fixes
                      // odd jumps on exact rotations

    func halfAnInt(number: Int) -> Int {
      return Int(ceil(Float(number) / 2))
    }
    
    let halfTheWedges  = halfAnInt(wedges.count)
    
    let currentWedge   = wedgeForRotation(rotation)
    let startWedge     = subtract( halfTheWedges,
                        fromIndex: currentWedge.value,
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
  
  
  
  func setImageOpacityForAngle(var angle: Angle) {
    
    visualState.initOpacityListWithWedges(wedges)
    
    // Shift the rotation 1/2 a wedge width angle
    // This is to center the effect of changing the opacity.
    angle = angle + (wedgeWidthAngle / 2)
    
    for wedge in wedges {
      
      if angle >= wedge.minAngle &&
        angle <=  wedge.maxAngle    {
          
          let percent = percentValue( angle,
                        isBetweenLow: wedge.minAngle,
                             AndHigh: wedge.maxAngle)
          
          visualState.wedgeOpacityList[wedge.value]    = CGFloat(percent)
          
          
          let neighbor = neighboringWedge(wedge)
          let invertedPercent = 1 - percent
          visualState.wedgeOpacityList[neighbor.value] = CGFloat(invertedPercent)
          
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
    return imageIndexForRotation(rotation)
  }
  
  // assumes: images increase as rotation decreases
  var rotationFromFirstToLast: Rotation {
    return Rotation(wedgeWidthAngle) * Rotation(images.count - 1)
  }
  
  // assumes: images increase as rotation decreases
  var firstImageRotation: Rotation {
    return Rotation(wedgeFromValue(1).midAngle)
  }
  
  var lastImageRotation: Rotation {
    // assumes: images increase as rotation decreases
    return firstImageRotation - rotationFromFirstToLast
  }

  // MARK: Image methods
  func imageForRotation (rotation: Rotation) -> UIImage? {
    var image: UIImage? = nil

    let imageIndex = imageIndexForRotation(rotation)
    
    if imageIndex <= images.count {
      image = imageOfNumber(imageIndex)
    }
    
    return image
  }
  
  func imageViewForRotation(rotation: Rotation) -> WedgeImageView? {
    let wedge     = wedgeForRotation(rotation)
    let imageView = imageViewFromValue(wedge.value)
    
    return imageView
  }
  
  func imageIndexForRotation(rotation: Rotation) -> ImageIndex {
    let startingRotationDifference = -firstImageRotation
    let rotationStartingAtZero     = rotation + startingRotationDifference
    let wedgesFromStart            = rotationStartingAtZero /
                                     Rotation(wedgeWidthAngle)
    // assumes: images increase as rotation decreases
    var currentImage = ImageIndex(round(-CGFloat(wedgesFromStart))) + 1
    
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
  
  func rotationForImage(image: ImageIndex) -> Rotation {
    let startingRotation = Rotation(wedgeFromValue(1).midAngle)
    let stepsFromStart   = image - 1
    let rotationToImage  = Rotation(stepsFromStart) * Rotation(wedgeWidthAngle)
    
    // assumes: images increase as rotation decreases
    return  startingRotation - rotationToImage
  }
  
  // MARK: -
  // MARK: Wedge Computed Properties
  var currentWedge: WedgeRegion {
    return wedgeForRotation(rotation)
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

  
  func thisAngle(angle: Angle,
   isWithinWedge wedge: WedgeRegion) -> Bool {
      var angleIsWithinWedge = false
      
      if (Rotation(angle) >= wedge.minRotation &&
        Rotation(angle) <= wedge.maxRotation   ) {
          
          angleIsWithinWedge = true
      }
      
      return angleIsWithinWedge
  }

  
  func wedgeForRotation(rotation: Rotation) -> WedgeRegion {
    let angle = Angle(rotation)
    return wedgeForAngle(angle)
  }
  
  func wedgeForAngle(angle: Angle) -> WedgeRegion {
    // Determin where the wheel is (which wedge we are within)
    var currentWedge: WedgeRegion?
    for wedge in wedges {
      if thisAngle(angle, isWithinWedge: wedge) {
        currentWedge = wedge
        break
      }
    }
    
//    if currentWedge == nil {
//      println("\(angle.value)")
//      for wedge in wedges {
//        println("\(wedge)")
//      }
//    }
    
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

  
  // MARK: Math Helpers
  func percentValue<T:AngularType>(value: T,
                      isBetweenLow   low: T,
                      AndHigh       high: T ) -> Double {
      return (value.value - low.value) / (high.value - low.value)
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