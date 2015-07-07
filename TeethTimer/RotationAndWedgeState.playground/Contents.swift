import UIKit

// Utility:
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
  return "num-\(paddedTwoDigitNumber(i))"
}


func arrayOfNames(count: Int) -> [String] {
  var imageNames: [String] = []
  for i in 0..<count {
    imageNames.append(imageNameForNumber(i))
  }
  return imageNames
}




public struct RotationState {
  
  public let rotation:        Rotation
  public let wedgeSeries:     WedgeSeries
  
  public init(    rotation: Rotation,
    wedgeSeries: WedgeSeries) {
      
      self.rotation    = Rotation(rotation)
      self.wedgeSeries = WedgeSeries(wedgeSeries)
  }
  
  public init( state: RotationState) {
    self.rotation    = Rotation(state.rotation)
    self.wedgeSeries = WedgeSeries(state.wedgeSeries)
  }
  
  // MARK: Computed Properties
  public var layoutRotation: Rotation {
    return rotation * -1
  }
  
  // wheelShape connivence properties.
  public var wedgeCount: Int {
    return wedgeSeries.wedgeCount
  }
  
  public var wedgeMaxIndex: Int {
    return wedgeSeries.wedgeCount - 1
  }
  
  public var seriesWidth: Rotation {
    return wedgeSeries.seriesWidth
  }
  
  public var wedgeSeperation: Angle {
    return wedgeSeries.wedgeSeperation
  }
  
  public var layoutDirection: LayoutDirection {
    return wedgeSeries.direction
  }
  
  
  public var polarity: Polarity {
    if layoutRotation >= 0 {
      return .Positive
    } else {
      return .Negative
    }
  }
  
  // WedgeIndex is from 0 to (count-of-images - 1)
  public var wedgeIndex: WedgeIndex {
    //      if remainingRotation >= 0 {
    switch polarity {
    case .Positive:
      return countOfWedgesInRemainder
    case .Negative:
      // First invert the index
      var wedgeIndex = wedgeMaxIndex - countOfWedgesInRemainder
      // Then shift it up one index
      var next = wedgeIndex + 1
      if next > wedgeMaxIndex {
        next = 0
      }
      return next
    }
  }
  
  public var distanceWithinPartialRotation: Rotation {
    let distance =  Rotation(wedgeSeperation) * Rotation(countOfWedgesInRemainder)
    return abs(distance)
  }
  
  public var distanceOfCompletRotations: Rotation {
    return abs(seriesWidth * Rotation(rotationCount))
  }
  
  public var wedgeCenter: Rotation {
    
    let wedgeCenter: Rotation
    
    switch polarity {
    case .Positive:
      wedgeCenter = (distanceOfCompletRotations +
                     distanceWithinPartialRotation ) * -1
      
    case .Negative:
      wedgeCenter = distanceOfCompletRotations +
                    distanceWithinPartialRotation
    }
    
    return wedgeCenter
  }
  
  public var directionRotatedOffWedgeCenter: RotationDirection {
    if layoutRotation > wedgeCenter {
      return .Clockwise
    } else {
      return .CounterClockwise
    }
  }
  
  
  
  // Much of the math to compute these properties assumes that the
  // begining rotation of the wedge seriesWidth is at 0.  But, seriesWidth is
  // actually a half wedgeSeperation off, so that when rotation = 0, the
  // first wedge is centered at the top of the wheel.
  // offsetRotation is the rotation shifted so the it the wedge min or max
  // is at the top of the wheel
  public var offsetRotation: Rotation {
    switch polarity {
    case .Positive:
      return layoutRotation + (wedgeSeperation / 2)
    case .Negative:
      return layoutRotation - (wedgeSeperation / 2)
    }
  }
  
  
  // The remainder (modulus) of the seriesWidth in to the rotation.
  // This remainder is transforms a rotation of any size in to a rotation
  // between 0 and seriesWidth.
  public var remainingRotation: Rotation {
    return abs(offsetRotation % seriesWidth)
  }
  
  // MARK: Private Computed Properties
  
  // How many complete rotations the wheel been rotated from the start.
  public var rotationCount: Int {
    return abs(Int((offsetRotation / seriesWidth).value))
  }
  
  // The number of wedges in the remainder of the remainingRotation property
  public var countOfWedgesInRemainder: Int {
    let wedgesInRemainder = remainingRotation / wedgeSeperation
    let countOfWedgesInRemainder = Int(wedgesInRemainder.value)
    return abs(countOfWedgesInRemainder)
  }
  
  
  // MARK: Methods
  public func angleOffCenterFromLayoutDirection(direction: LayoutDirection) -> Angle {
    let angleOffCenter = layoutRotation - wedgeCenter
    
    switch direction {
    case .Clockwise:
      return Angle(angleOffCenter)
    case .CounterClockwise:
      return Angle(angleOffCenter * -1)
    }
  }
  
}




func rotationsAreClose(a: Rotation, b: Rotation) -> Bool {
  var rotA = Int64(a.value * 10000)
  var rotB = Int64(b.value * 10000)
  return rotA == rotB
}


// Return a Rotation that is randomly between -(rotation/2) & (rotation/2)
func randomRotationWithinRotation(rotation: Rotation) -> Rotation {
  // arc4random works with integers. Before turning degrees (a double) in to
  // an Int (UInt32), first multiply it by 'precision'
  let precision       = UInt32(1)
  
  let degrees         = rotation.degrees
  let randomRange     = UInt32(degrees * 0.999 * Double(precision))
  let halfRange       = degrees * 0.4995
  
  // Divide by 'precision' to return to the same order of magnitude that the
  // original degrees were in.
  let randomOffset    = Double(arc4random_uniform(randomRange)) /
    Double(precision)
  
  // subtract half the range to center the random number around 0
  let randomOffsetDegrees = randomOffset - halfRange
  
  return Rotation(degrees: randomOffsetDegrees)
}





//////////////////////////////////////////////////////


let imageNames = arrayOfNames(10)
let wedges = imageNames.map({
  Wedge(imageName: $0)
})


let series = WedgeSeries(wedges: wedges,
                      direction: .Clockwise,
                wedgeSeperation: Angle(degrees: 90),
                   visibleAngle: Angle(degrees: 90))

//////////////////////////////////////////////////////
//for i in -72...72 {
//  
//  let rotation = Rotation(degrees: (i * 10))
//  rotation.degrees
//  let rotState = RotationState(rotation: rotation,
//                            wedgeSeries: series)
//  
//  rotState.wedgeCenter.degrees
//  let string = "\(rotation.degrees) \(rotState.wedgeCenter.degrees)"
//}


//////////////////////////////////////////////////////

let imageSeperation = Angle(degrees: 90)
let imageCount      = Int(10)
let maxIndex        = imageCount - 1

let testCount           = imageCount * 6
let startingRotation    = Rotation(imageSeperation) * Rotation(imageCount * 3 * -1)
var previousWedgeCenter = startingRotation - Rotation(imageSeperation)

for i in 0..<testCount {
  
  let additionalRotation   = Rotation(imageSeperation) * Rotation(i)
  let currentRotation      = startingRotation + additionalRotation
  
  let randomOffset         = randomRotationWithinRotation(imageSeperation.rotation)
  let randomizedRotation   = currentRotation + randomOffset
  
  
  let state = RotationState(    rotation: randomizedRotation,
                             wedgeSeries: series)
  
  let test = rotationsAreClose(state.wedgeCenter, currentRotation)
  let string = "\(randomizedRotation.degrees) \(state.wedgeCenter.degrees) \(currentRotation.degrees)"
 
}

  let state = RotationState(    rotation: Rotation(degrees: 34.135),
                             wedgeSeries: series)
  state.wedgeCenter

