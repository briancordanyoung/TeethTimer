// MARK: - ImageWheel Summery


import UIKit

typealias ImageIndex = Int
typealias WedgeValue = Int

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
    return "Wedge Region: \(value) | Angles: min-\(minRadian) mid-\(midRadian) max-\(maxRadian)"
  }
}


// MARK: -
// MARK: - ImageWheel Class
class ImageWheel: UIView {

  // public properties

  // ImageWheel builds completely on the state of currentRotation
  var rotationAngle = CGFloat(0) { //rotationAngle
    didSet {
      updateAppearanceForRotation(currentRotation)
    }
  }
  
  
  var currentImageMidRotation: CGFloat {
    // TODO: create methods for determining what image we are on
    //       and return what the rotation would be for the center of the wedge
    //       of that image.
    return 0.0
  }
  
  // Image and Wedge Properties
  let wedgeImageHeight: CGFloat  = (800 * 0.9)
  let wedgeImageWidth:  CGFloat  = (734 * 0.9)
  var images:          [UIImage] = []

  // Image and Wedge Properties
  var numberOfWedges: Int = 0
  var wedges: [WedgeRegion] = []
  var visualState = ImageWheelVisualState()
  

  // Internal properties
  var currentRotation: CGFloat {
    return angleFromRotation(rotationAngle)
  }
  
  var currentAngle: CGFloat {
    return angleFromRotation(currentRotation)
  }
  
  
  
  
  
  // MARK: -
  // MARK: Initialization
  init(Sections sectionsCount: Int,
             AndImages images: [UIImage]) {
              
    super.init(frame: CGRect())
    
    self.images    = images
    numberOfWedges = sectionsCount
    createWedges()
    addContraints()
    updateAppearanceForRotation(currentRotation)
  }
  
  required init(coder: NSCoder) {
    // TODO: impliment coder and decoder
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  // MARK: Setup Methods
  func createWedges() {
    
    let wedgeStartingAngle = (Circle.half * 3) + (wedgeWidthAngle / 2)
    // Build UIViews for each pie piece
    for i in 1...numberOfWedges {
      
      let wedgeAngle = (CGFloat(wedgeWidthAngle) * CGFloat(i)) - wedgeStartingAngle
      
      var imageView = UIImageView(image: imageOfNumber(i))
      imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
      imageView.transform = CGAffineTransformMakeRotation(wedgeAngle)
      imageView.tag = i
      
      self.addSubview(imageView)
    }
    
    
    self.userInteractionEnabled = false
    
    if wedgeCountParity == .Even {
      createWedgeRegionsEven()
    } else {
      createWedgeRegionsOdd()
    }
    
  }
  
  func createWedgeAtIndex(i: Int, AndAngle angle: CGFloat) -> UIImageView {
    var imageView = UIImageView()
    imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
    imageView.transform = CGAffineTransformMakeRotation(angle)
    imageView.tag = i
    return imageView
  }
  
  func createWedgeRegionsEven() {
    var mid = Circle.half - (wedgeWidthAngle / 2)
    var max = Circle.half
    var min = Circle.half - wedgeWidthAngle
    
    for i in 1...numberOfWedges {
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
  
  
  func createWedgeRegionsOdd() {
    var mid = Circle.half - (wedgeWidthAngle / 2)
    var max = Circle.half
    var min = Circle.half -  wedgeWidthAngle
    
    for i in 1...numberOfWedges {
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
  
  func addContraints() {
    self.setTranslatesAutoresizingMaskIntoConstraints(false)

    for i in 1...numberOfWedges {
      if let imageView = imageViewFromValue(i) {
        
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addConstraint(NSLayoutConstraint(item: imageView,
                                         attribute: NSLayoutAttribute.CenterY,
                                         relatedBy: NSLayoutRelation.Equal,
                                            toItem: self,
                                         attribute: NSLayoutAttribute.CenterY,
                                        multiplier: 1.0,
                                          constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: imageView,
                                         attribute: NSLayoutAttribute.CenterX,
                                         relatedBy: NSLayoutRelation.Equal,
                                            toItem: self,
                                         attribute: NSLayoutAttribute.CenterX,
                                        multiplier: 1.0,
                                          constant: 0.0))
        
        imageView.addConstraint( NSLayoutConstraint(item: imageView,
                                    attribute: NSLayoutAttribute.Height,
                                    relatedBy: NSLayoutRelation.Equal,
                                       toItem: nil,
                                    attribute: NSLayoutAttribute.NotAnAttribute,
                                   multiplier: 1.0,
                                     constant: wedgeImageHeight))
        
        imageView.addConstraint( NSLayoutConstraint(item: imageView,
                                    attribute: NSLayoutAttribute.Width,
                                    relatedBy: NSLayoutRelation.Equal,
                                       toItem: nil,
                                    attribute: NSLayoutAttribute.NotAnAttribute,
                                   multiplier: 1.0,
                                     constant: wedgeImageWidth))
      }
    }

  }

  
  override func didMoveToSuperview() {
    if let superview = self.superview {
      let viewsDictionary = ["wheel":self]
      
      let view_constraint_H:[AnyObject] =
      NSLayoutConstraint.constraintsWithVisualFormat(  "H:|[wheel]|",
        options: NSLayoutFormatOptions(0),
        metrics: nil,
        views: viewsDictionary)
      
      let view_constraint_V:[AnyObject] =
      NSLayoutConstraint.constraintsWithVisualFormat(  "V:|[wheel]|",
        options: NSLayoutFormatOptions(0),
        metrics: nil,
        views: viewsDictionary)
      
      superview.addConstraints(view_constraint_H)
      superview.addConstraints(view_constraint_V)
    }
  }
  
  
  
  
  
  
  
  

  // MARK: -
  // MARK: Visual representation of the wheel
  func updateAppearanceForRotation(rotation: CGFloat) {
    let angle = angleFromRotation(rotation)
    setImageOpacityForCurrentAngle(angle)
  }
  
  
  func setImageOpacityForCurrentAngle(var angle: CGFloat) {
    
    visualState.initOpacityListWithWedges(wedges)
    
    // Shift the rotation 1/2 a wedge width angle
    // This is to center the effect of changing the opacity.
    angle = angle + (wedgeWidthAngle / 2)
    angle = normalizAngle(angle)
    
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
  var allWedgeImageViews: [UIImageView] {
    let views = self.subviews
    
    var wedgeImageViews: [UIImageView] = []
    for image in views {
      if image.isKindOfClass(UIImageView.self) {
        let imageView = image as! UIImageView
        if imageView.tag != 0 {
          wedgeImageViews.append(imageView)
        }
      }
    }
    return wedgeImageViews
  }
  
  var currentImage: ImageIndex {
    func near(x: CGFloat) -> CGFloat { return round(x * 4) }
    
    var image    = currentWedgeValue
    var rotation = currentRotation
    let angle    = currentAngle
    
    while near(rotation) != near(angle) {
      
      if near(rotation) > near(angle) {
        for i in 1...numberOfWedges {
          image = previousImage(image)
        }
        rotation -= Circle.full
      }
      
      if near(rotation) < near(angle) {
        for i in 1...numberOfWedges {
          image = nextImage(image)
        }
        rotation += Circle.full
      }
    }
    
    return image
  }
  
  var firstImageRotation: CGFloat {
    return wedgeFromValue(1).midRadian
  }
  
  var lastImageRotation: CGFloat {
    let rotationAmountFromFirstToLast = wedgeWidthAngle * CGFloat(images.count)
    return firstImageRotation - rotationAmountFromFirstToLast
  }
  
  
  
  // MARK: Image methods
  func imageForWedge(          wedge: WedgeRegion,
    WhileCurrentImageIs currentImage: ImageIndex) -> ImageIndex {
      
      var currentWedge = wedgeForImage(currentImage)
      let resolved = resolveDirectionAndCountToWedge( wedge,
        GivenCurrentWedge: currentWedge,
        inDirection: .Closest)
      
      let image: ImageIndex
      if resolved.direction == .Clockwise {
        // WAS: image = currentImage + resolved.count
        image = currentImage - resolved.count
      } else {
        // WAS: image = currentImage - resolved.count
        image = currentImage + resolved.count
      }
      
      return image
  }
  
  
  func wedgeForImage(image: ImageIndex) -> WedgeRegion {
    var wedgeValue = image % wedges.count
    if wedgeValue == 0 {
      wedgeValue = wedges.count
    }
    return wedgeFromValue(wedgeValue)
  }
  
  func resolveDirectionAndCountToImage(image: ImageIndex,
                   var inDirection direction: DirectionToRotate)
                               -> (direction: DirectionToRotate, count: Int) {
      let count: Int
      
      switch direction {
      case .Closest:
        // WAS: .Clockwise
        let positiveCount = countFromImage( currentImage,
                                   ToImage: image,
                               inDirection: .CounterClockwise)
        // WAS: .CounterClockwise
        let negitiveCount = countFromImage( currentImage,
                                   ToImage: image,
                               inDirection: .Clockwise)
        
        // WAS: .Clockwise
        if positiveCount <= negitiveCount {
          count     = positiveCount
          direction = .CounterClockwise
        } else {
          // WAS: .CounterClockwise
          count     = negitiveCount
          direction = .Clockwise
        }
        
      case .Clockwise:
        
        count = countFromImage( currentImage,
                       ToImage: image,
                   inDirection: .Clockwise)
        
      case .CounterClockwise:
        count = countFromImage( currentImage,
                       ToImage: image,
                   inDirection: .CounterClockwise)
        
      }
      
      return (direction, count)
  }
  
  func countFromImage( fromImage: ImageIndex,
                 ToImage toImage: ImageIndex,
           inDirection direction: DirectionRotated) -> Int {
      
      
      assert(fromImage >= 1, "countFromImage: fromImage too low \(fromImage)")
      assert(toImage >= 1, "countFromImage: toImage too low \(toImage)")
      assert(fromImage <= images.count, "countFromImage: fromImage too high \(fromImage)")
      assert(toImage <= images.count, "countFromImage: toImage too high \(toImage)")
      
      var image = fromImage
      var count = 0
      while true {
        if image == toImage {
          break
        }
        // WAS: if direction == .Clockwise {
        if direction == .CounterClockwise {
          image = nextImage(image)
        } else {
          image = previousImage(image)
        }
        ++count
      }
      
      return count
  }
  
  func nextImage(var image: ImageIndex) -> ImageIndex {
    ++image
    if image > images.count {
      image = 1
    }
    return image
  }
  
  func previousImage(var image: ImageIndex) -> ImageIndex {
    --image
    if image < 1 {
      image = images.count
    }
    return image
  }
  
  
  // MARK: -
  // MARK: Wedge Computed Properties
  var currentWedge: WedgeRegion {
    return wedgeForAngle(currentAngle)
  }
  
  var currentWedgeValue: WedgeValue {
    return currentWedge.value
  }
  
  var wedgeWidthAngle: CGFloat {
    return Circle.full / CGFloat(numberOfWedges)
  }
  
  var wedgeCountParity: Parity {
    var result: Parity
    if numberOfWedges % 2 == 0 {
      result = .Even
    } else {
      result = .Odd
    }
    return result
  }
  

  // MARK: Wedge Methods
  func resolveDirectionAndCountToWedge(wedge: WedgeRegion,
                   var inDirection direction: DirectionToRotate)
                               -> (direction: DirectionToRotate, count: Int) {
      
      return resolveDirectionAndCountToWedge( wedge,
                           GivenCurrentWedge: self.currentWedge,
                                 inDirection: direction)
  }
  
  func resolveDirectionAndCountToWedge(wedge: WedgeRegion,
              GivenCurrentWedge currentWedge: WedgeRegion,
                   var inDirection direction: DirectionToRotate)
                              ->  (direction: DirectionToRotate, count: Int) {
      
      let count: Int
      
      switch direction {
      case .Closest:
        // WAS: Clockwise
        let positiveCount = countFromWedgeValue( currentWedge.value,
                                   ToWedgeValue: wedge.value,
                                    inDirection: .CounterClockwise)
        // WAS: CounterClockwise
        let negitiveCount = countFromWedgeValue( currentWedge.value,
                                   ToWedgeValue: wedge.value,
                                    inDirection: .Clockwise)
        
        // WAS: Clockwise
        if positiveCount <= negitiveCount {
          count     = positiveCount
          direction = .CounterClockwise
        } else {
          // WAS: CounterClockwise
          count     = negitiveCount
          direction = .Clockwise
        }
        
      case .Clockwise:
        count = countFromWedgeValue( currentWedge.value,
                       ToWedgeValue: wedge.value,
                        inDirection: .Clockwise)
        
      case .CounterClockwise:
        count = countFromWedgeValue( currentWedge.value,
                       ToWedgeValue: wedge.value,
                        inDirection: .CounterClockwise)
      }
      
      return (direction, count)
      
  }
  
  func countFromWedgeValue( fromValue: Int,
               ToWedgeValue   toValue: Int,
                inDirection direction: DirectionRotated) -> Int {
      
      var value = fromValue
      var count = 0
      while true {
        if value == toValue {
          break
        }
        // WAS: Clockwise
        if direction == .CounterClockwise {
          value = nextWedgeValue(value)
        } else {
          value = previousWedgeValue(value)
        }
        ++count
      }
      return count
  }
  
  func nextWedge(wedge: WedgeRegion) -> WedgeRegion {
    let value = nextWedgeValue(wedge.value)
    return wedgeFromValue(value)
  }
  
  func previousWedge(wedge: WedgeRegion) -> WedgeRegion {
    let value = previousWedgeValue(wedge.value)
    return wedgeFromValue(value)
  }
  
  func nextWedgeValue(var value: Int) -> Int {
    ++value
    if value > wedges.count {
      value = 1
    }
    return value
  }
  
  func previousWedgeValue(var value: Int) -> Int {
    --value
    if value < 1 {
      value = wedges.count
    }
    return value
  }
  
  
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
  
  
  func wedgeForAngle(angle: CGFloat) -> WedgeRegion {
    
    let normAngle = normalizAngle(angle)
    
    // Determin where the wheel is (which wedge we are within)
    var currentWedge: WedgeRegion?
    for wedge in wedges {
      if thisAngle(normAngle, isWithinWedge: wedge) {
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
  func normalizAngle(var angle: CGFloat) -> CGFloat {
    let positiveHalfCircle =  Circle.half
    let negitiveHalfCircle = -Circle.half
    
    while angle > positiveHalfCircle || angle < negitiveHalfCircle {
      if angle > positiveHalfCircle {
        angle -= Circle.full
      }
      if angle < negitiveHalfCircle {
        angle += Circle.full
      }
    }
    return angle
  }

  func angleFromRotation(rotation: CGFloat) -> CGFloat {
    var angle = rotation
    
    if angle >  Circle.half {
      angle += Circle.half
      let totalRotations = floor(angle / Circle.full)
      angle  = angle - (Circle.full * totalRotations)
      angle -= Circle.half
    }
    
    if angle < -Circle.half {
      angle -= Circle.half
      let totalRotations = floor(abs(angle) / Circle.full)
      angle  = angle + (Circle.full * totalRotations)
      angle += Circle.half
    }
    
    return angle
  }

  
  // MARK: Math Helpers
  func percentValue(value: CGFloat,
       isBetweenLow   low: CGFloat,
       AndHigh       high: CGFloat ) -> CGFloat {
      return (value - low) / (high - low)
  }
  
  // MARK: image and imageView helpers
  func imageViewFromValue(value: Int) -> UIImageView? {
    
    var wedgeView: UIImageView?
    
    for image in allWedgeImageViews {
      let imageView = image as UIImageView
      if imageView.tag == value {
        wedgeView = imageView
      }
    }
    
    return wedgeView
  }
  
  func imageOfNumber(i: Int) -> UIImage {
    return images[i - 1]
  }
  
  
}