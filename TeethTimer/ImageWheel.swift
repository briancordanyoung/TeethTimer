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
  // Image and Wedge Properties
  let wedgeImageHeight: CGFloat  = (800 * 0.9)
  let wedgeImageWidth:  CGFloat  = (734 * 0.9)
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
    addWedgeContraints(sectionsCount)
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
    // Build UIViews for each pie piece
    for i in 1...count {
      
      let wedgeAngle = (CGFloat(wedgeWidthAngle) * CGFloat(i)) - wedgeStartingAngle
      
      var imageView = UIImageView(image: imageOfNumber(i))
      imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
      imageView.transform = CGAffineTransformMakeRotation(wedgeAngle)
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
  
  func addWedgeContraints(count: Int) {
    self.setTranslatesAutoresizingMaskIntoConstraints(false)

    for i in 1...count {
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
    setImagesForCurrentRotation(rotation)

    let angle = wedgeWheelAngle(rotation)
    setImageOpacityForCurrentAngle(angle)
  }

  func setImagesForCurrentRotation(rotation: CGFloat) {
    // get the rotation of the wedge at the bottom of the wheel.
    // if the
    let wedgeCountBack: Int
    if wedgeCountParity == .Even {
      wedgeCountBack =  wedges.count / 2
    } else {
      wedgeCountBack = (wedges.count / 2) + 1
    }
    let rotationBack = CGFloat(wedgeCountBack) * wedgeWidthAngle
    let startingRotation = rotation - rotationBack

    for i in 1...wedges.count {
      let rotationForward = (wedgeWidthAngle * CGFloat(i))
      let rotationToCheck = startingRotation + rotationForward

      if let imageView  = imageViewForRotation(rotationToCheck),
                  image = imageForRotation(rotationToCheck) {
        if imageView.image !== image {
          imageView.image = image
        }
      }
    }
  }
    
  
  func setImageOpacityForCurrentAngle(var angle: CGFloat) {
    
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
  
  func imageViewForRotation(rotation: CGFloat) -> UIImageView? {
    let wedge     = wedgeForRotation(rotation)
    let imageView = imageViewFromValue(wedge.value)
    
    return imageView
  }
  
  func imageIndexForRotation(rotation: CGFloat) -> ImageIndex {
    let startingRotationDifference = -firstImageRotation
    let rotationStartingAtZero = rotation + startingRotationDifference
    let wedgesFromStart = rotationStartingAtZero / wedgeWidthAngle
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