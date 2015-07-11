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
    

    // wedgeSeries connivence properties.
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
      if rotation >= 0 {
        return .Positive
      } else {
        return .Negative
      }
    }
    
    
    
    
    
    
    // WedgeIndex is from 0 to (count-of-images - 1)
    var wedgeIndex: WedgeIndex {
      switch layoutDirection {
      case .ClockwiseLayout:
        return clockwiseWedgeIndex
      case .CounterClockwiseLayout:
        return counterClockwiseWedgeIndex
      }
    }
    
    var counterClockwiseWedgeIndex: WedgeIndex {
      switch polarity {
      case .Positive:
        return countOfWedgesInRemainder
      case .Negative:
        return invertedShiftedCountOfWedgesInRemainder
      }
    }
    
    var clockwiseWedgeIndex: WedgeIndex {
      switch polarity {
      case .Positive:
        return invertedShiftedCountOfWedgesInRemainder
      case .Negative:
        return countOfWedgesInRemainder
      }
    }

    
    var invertedShiftedCountOfWedgesInRemainder: WedgeIndex {
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
    
    
    
    
    var distanceOfCompleteRotations: Rotation {
      return abs(seriesWidth * rotationCount)
    }
  
    var distanceWithinPartialRotation: Rotation {
      let distance =  Rotation(wedgeSeperation) * Rotation(countOfWedgesInRemainder)
      return abs(distance)
    }
    
    var wedgeCenter: Rotation {
      let distanceToWedgeCenter = distanceOfCompleteRotations +
                                  distanceWithinPartialRotation
      
      switch polarity {
      case .Positive:
        return distanceToWedgeCenter
        
      case .Negative:
        return distanceToWedgeCenter * -1
      }
    }
    
    var directionRotatedOffWedgeCenter: RotationDirection {
      let center = (wedgeCenter * -1)
      
      switch (rotation > center , layoutDirection) {
      case (true, .CounterClockwiseLayout):
        return .CounterClockwise
      case (false, .CounterClockwiseLayout):
        return .Clockwise
      case (true, .ClockwiseLayout):
        return .Clockwise
      case (false, .ClockwiseLayout):
        return .CounterClockwise
      default:
        assertionFailure("directionRotatedOffWedgeCenter should already have been exhaustive and not reached the default case.")
        return .Clockwise
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
        return rotation + (wedgeSeperation / 2)
      case .Negative:
        return rotation - (wedgeSeperation / 2)
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

    
    
    
    
    
    
    
    // Shifts distanceOfCompletRotations back a half wedge
    var resetDistanceOfCompleteRotations: Rotation {
      return distanceOfCompleteRotations - (wedgeSeperation / 2)
    }
    
    var rotationBoundsAWithinWedgeSeries: Rotation {
      switch polarity {
      case .Positive:
        return resetDistanceOfCompleteRotations
        
      case .Negative:
        return resetDistanceOfCompleteRotations * -1
      }
    }
    
    var rotationBoundsBWithinWedgeSeries: Rotation {
      switch polarity {
      case .Positive:
        return  resetDistanceOfCompleteRotations + seriesWidth
        
      case .Negative:
        return (resetDistanceOfCompleteRotations + seriesWidth) * -1
      }
    }
    
    var minimumRotationWithinWedgeSeries: Rotation {
      let minRotation =  min(rotationBoundsAWithinWedgeSeries,
                             rotationBoundsBWithinWedgeSeries)
      return shiftForLayoutDirection(minRotation)
    }

    var maximumRotationWithinWedgeSeries: Rotation {
      let maxRotation =  max(rotationBoundsAWithinWedgeSeries,
                             rotationBoundsBWithinWedgeSeries)
      return shiftForLayoutDirection(maxRotation)
    }
    
    func shiftForLayoutDirection(rotation: Rotation) -> Rotation {
      switch layoutDirection {
      case .ClockwiseLayout:
        return rotation + wedgeSeperation
      
      case .CounterClockwiseLayout:
        return rotation
      }
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
    
    var wedgeIndexNeighbor: WedgeIndex {
      switch (directionRotatedOffWedgeCenter,layoutDirection) {
      case (.Clockwise        , .CounterClockwiseLayout):
        return prevNeighbor
      case (.CounterClockwise , .CounterClockwiseLayout):
        return nextNeighbor
        
      case (.Clockwise        , .ClockwiseLayout):
        return nextNeighbor
      case (.CounterClockwise , .ClockwiseLayout):
        return prevNeighbor
      }
    }
    
    var offsetFromWedgeCenter: Angle {
      let angleOffCenter = rotation - wedgeCenter
    
      switch layoutDirection {
      case .ClockwiseLayout:
        return Angle(angleOffCenter * -1)
      case .CounterClockwiseLayout:
        return Angle(angleOffCenter)
      }
    }

    var nextNeighbor: WedgeIndex {
      return nextIndex(wedgeIndex)
    }
    
    var prevNeighbor: WedgeIndex {
      return prevIndex(wedgeIndex)
    }
    
    // MARK: Methods
    func nextIndex(index: Int) -> Int {
      var next = index + 1
      if next > wedgeMaxIndex {
        next = 0
      }
      return next
    }
    
    func prevIndex(index: Int) -> Int {
      var prev = index - 1
      if prev < 0 {
        prev = wedgeMaxIndex
      }
      return prev
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