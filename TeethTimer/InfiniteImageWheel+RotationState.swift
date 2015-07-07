import UIKit

extension InfiniteImageWheel {
  struct RotationState {
    
    let rotation:        Rotation
    let wedgeSeries:     WedgeSeries
    
    let d = Developement()
    
    init(    rotation: Rotation,
          wedgeSeries: WedgeSeries) {
        
        self.rotation    = Rotation(rotation)
        self.wedgeSeries = WedgeSeries(wedgeSeries)
    }
    
    init( state: RotationState) {
      self.rotation    = Rotation(state.rotation)
      self.wedgeSeries = WedgeSeries(state.wedgeSeries)
    }
    
    // MARK: Computed Properties
    var layoutRotation: Rotation {
      return rotation * -1
    }

    // wheelShape connivence properties.
    var wedgeCount: Int {
      return wedgeSeries.wedgeCount
    }
    
    var wedgeMaxIndex: Int {
      return wedgeSeries.wedgeCount - 1
    }
    
    var seriesWidth: Rotation {
      return wedgeSeries.seriesWidth
    }
    
    var wedgeSeperation: Angle {
      return wedgeSeries.wedgeSeperation
    }
    
    var layoutDirection: LayoutDirection {
      return wedgeSeries.direction
    }
    
    
    var polarity: Polarity {
      if layoutRotation >= 0 {
        return .Positive
      } else {
        return .Negative
      }
    }
    
    // WedgeIndex is from 0 to (count-of-images - 1)
    var wedgeIndex: WedgeIndex {
      //      if remainingRotation >= 0 {
      switch polarity {
      case .Positive:
        return countOfWedgesInRemainder
      case .Negative:
        // First invert the index
        var wedgeIndex = wedgeMaxIndex - countOfWedgesInRemainder
        // Then shift it up one index
        // This counteracts the 1/2 wedgeSeperation offset that is factored in
        // to the the offsetRotation property.
        var next = wedgeIndex + 1
        if next > wedgeMaxIndex {
          next = 0
        }
        return next
      }
    }
    
    var distanceOfCompletRotations: Rotation {
      return abs(seriesWidth * rotationCount)
    }
  
    var distanceWithinPartialRotation: Rotation {
      let distance =  Rotation(wedgeSeperation) * Rotation(countOfWedgesInRemainder)
      return abs(distance)
    }
    
    var wedgeCenter: Rotation {
      let distanceToWedgeCenter = distanceOfCompletRotations +
                                  distanceWithinPartialRotation
      
      switch polarity {
      case .Positive:
        return distanceToWedgeCenter * -1
        
      case .Negative:
        return distanceToWedgeCenter
      }
    }
    
    var directionRotatedOffWedgeCenter: RotationDirection {
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
    var offsetRotation: Rotation {
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
    // How many complete rotations the wheel been rotated from the start.
    var rotationCount: Int {
      var rotations            = offsetRotation.radians
      var width                = seriesWidth.radians
      var rotationCount        = rotations / width
      var roundedRotationCount = Int(rotationCount)
      return abs(roundedRotationCount)
    }
    
    var remainingRotation: Rotation {
      return abs(offsetRotation % seriesWidth)
    }
    
    // The number of wedges in the remainder of the remainingRotation property
    var countOfWedgesInRemainder: Int {
      let wedgesInRemainder = remainingRotation / wedgeSeperation
      let countOfWedgesInRemainder = Int(wedgesInRemainder.value)
      return abs(countOfWedgesInRemainder)
    }
    
    
    // MARK: Methods
    func angleOffCenterFromLayoutDirection(direction: LayoutDirection) -> Angle {
      let angleOffCenter = layoutRotation - wedgeCenter
    
      switch direction {
      case .Clockwise:
        return Angle(angleOffCenter)
      case .CounterClockwise:
        return Angle(angleOffCenter * -1)
      }
    }
    
  }
}



extension InfiniteImageWheel {
  enum Polarity: String, Printable  {
    case Positive = "Positive"
    case Negative  = "Negative"
    
    var description: String {
      return self.rawValue
    }
  }
}