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
  
  // ImageWheel builds completely on WheelControl
  let wheel: WheelControl
  var container: UIView {
    return wheel.wheelView
  }
  
  var currentRotation: CGFloat {
    return wheel.currentRotation
  }
  
  // TODO: remove currentAngle.
  // ImageWheel should be completely based on rotation, not angle
  var currentAngle: CGFloat {
    return wheel.currentAngle
  }
  
  // Image and Wedge Properties
  let wedgeImageHeight: CGFloat  = (800 * 0.9)
  let wedgeImageWidth:  CGFloat  = (734 * 0.9)
  var images:          [UIImage] = []

  // Image and Wedge Properties
  var numberOfWedges: Int = 0
  var wedges: [WedgeRegion] = []
  var visualState = ImageWheelVisualState()
  

  
  // Image Properties
  var allWedgeImageViews: [UIImageView] {
      let views = container.subviews
      
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
    let rotationAmountFromFristToLast = wedgeWidthAngle * CGFloat(images.count)
    return firstImageRotation - rotationAmountFromFristToLast
  }
  
  
  // Wedge Properties
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

  
  
  
  
  // MARK: -
  // MARK: Initialization
  init(WithWheelControl wheel: WheelControl,
       Sections sectionsCount: Int,
             AndImages images: [UIImage]) {
              
    self.wheel = wheel
    super.init(frame: CGRect())
    
    self.images    = images
    numberOfWedges = sectionsCount
    createWedges()
  }
  
  required init(coder: NSCoder) {
    // TODO: impliment coder and decoder
    wheel = WheelControl()
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  // MARK: Setup Methods
  func createWedges() {
    
    let wedgeStartingAngle = (Circle.half * 3) + CGFloat(self.wedgeWidthAngle / 2)
    // Build UIViews for each pie piece
    for i in 1...numberOfWedges {
      
      let wedgeAngle = (CGFloat(wedgeWidthAngle) * CGFloat(i)) - wedgeStartingAngle
      
      var imageView = UIImageView(image: imageOfNumber(i))
      imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
      imageView.transform = CGAffineTransformMakeRotation(wedgeAngle)
      imageView.tag = i
      
      container.addSubview(imageView)
    }
    
    
    container.userInteractionEnabled = false
    self.addSubview(container)
    
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
  // MARK: Wedge Rotation Methods (Without Animating)
  func rotateToWedgeByValue(value: Int) {
    let wedge = wedgeFromValue(value)
    rotateToWedge(wedge)
  }
  
  func rotateToWedge(wedge: WedgeRegion) {
//    rotateToAngle(wedge.midRadian)
    // TODO: This is wrong.  The following methods need to be removed 
    // and replaced with image versions
    // rotateToWedge
    // rotateToWedgeByValue
    wheel.currentRotation = wedge.midRadian
  }
  
//  func rotateToAngle(angle: CGFloat) {
//    if (wheel.userState.currently == .NotInteracting) {
//      
//      let normilizedAngle = normalizAngle(angle)
//      let newRotation = currentAngle - normilizedAngle
//      let t = CGAffineTransformRotate(container.transform, newRotation)
//      container.transform = t;
//      
//      
//      // TODO: Calculate direction
//      // WAS: Clockwise
////      wheelRotatedTo( normilizedAngle,
////        turningDirection: .CounterClockwise)
//    }
////    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
//  }
  
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
    
    let normAngle = wheel.normalizAngle(angle)
    
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
  
  
  // MARK: Math Helpers
  func percentValue(value: CGFloat,
       isBetweenLow   low: CGFloat,
       AndHigh       high: CGFloat ) -> CGFloat {
      return (value - low) / (high - low)
  }
  
  // MARK: Other
  func wedgeImageViewFromValue(value: Int) -> UIImageView? {
    
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