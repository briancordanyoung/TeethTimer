import UIKit


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


public enum Polarity: String, Printable  {
    case Positive = "Positive"
    case Negative  = "Negative"
    
    public var description: String {
      return self.rawValue
    }
  }
