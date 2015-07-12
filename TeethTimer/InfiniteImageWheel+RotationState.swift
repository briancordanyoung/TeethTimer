import UIKit

extension InfiniteImageWheel {
  struct RotationState {
    
    let rotation:        Rotation
    let wedgeSeries:     WedgeSeries
    
    
    // MARK:
    // MARK: Center Rotation and wedgeIndex for rotation
    // WedgeIndex is from 0 to (count-of-images - 1)
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

    var wedgeIndex: WedgeIndex {
      switch (layoutDirection , polarity) {
      case (.ClockwiseLayout , .Positive):
        return invertedShiftedCountOfWedgesInRemainder
      case (.CounterClockwiseLayout , .Positive ):
        return countOfWedgesInRemainder
      case (.ClockwiseLayout , .Negative):
        return countOfWedgesInRemainder
      case (.CounterClockwiseLayout , .Negative):
        return invertedShiftedCountOfWedgesInRemainder
      }
    }

    private var invertedShiftedCountOfWedgesInRemainder: WedgeIndex {
      // First invert the index
      var wedgeIndex = wedgeMaxIndex - countOfWedgesInRemainder
      // Then shift it up one index
      // This counteracts the 1/2 wedgeSeperation offset that is factored in
      // to the the offsetRotation property.
      // A Rotation of 0 will be an index of 0 in both layoutDirections.
      return nextIndex(wedgeIndex)
    }
    
    
    // The number of wedges in the remainder of the remainingRotation property
    private var countOfWedgesInRemainder: Int {
      let remainingRotation = abs(offsetRotation % seriesWidth)
      let wedgesInRemainder = remainingRotation / wedgeSeperation
      let countOfWedgesInRemainder = Int(wedgesInRemainder.value)
      return abs(countOfWedgesInRemainder)
    }

    
    private var distanceOfCompleteRotations: Rotation {
      let rotations            = offsetRotation.radians
      let width                = seriesWidth.radians
      let rawRotationCount     = rotations / width
      let flooredRotationCount = Int(rawRotationCount)
      let rotationCount        = abs(flooredRotationCount)
      return seriesWidth * rotationCount
    }
  
    private var distanceWithinPartialRotation: Rotation {
      let distance =  Rotation(wedgeSeperation) * Rotation(countOfWedgesInRemainder)
      return distance
    }

    
    // Much of the math to compute these properties assumes that the
    // begining rotation of the wedge seriesWidth is at 0.  But, seriesWidth is
    // actually a half wedgeSeperation off, so that when rotation = 0, the
    // first wedge is centered at the top of the wheel.
    // offsetRotation is the rotation shifted so the it the wedge min or max
    // is at the top of the wheel
    private var offsetRotation: Rotation {
      switch polarity {
      case .Positive:
        return rotation + (wedgeSeperation / 2)
      case .Negative:
        return rotation - (wedgeSeperation / 2)
      }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK:
    // MARK: Properties reletive to wedgeIndex/wedgeCenter.
    
    // The 2nd closest wedgeIndex to rotation.
    var wedgeIndexNeighbor: WedgeIndex {
      switch (directionRotatedOffWedgeCenter,layoutDirection) {
      case (.Clockwise        , .CounterClockwiseLayout):
        return nextNeighbor
      case (.CounterClockwise , .CounterClockwiseLayout):
        return prevNeighbor
        
      case (.Clockwise        , .ClockwiseLayout):
        return prevNeighbor
      case (.CounterClockwise , .ClockwiseLayout):
        return nextNeighbor
      }
    }
    
    var offsetAngleFromWedgeCenter: Angle {
      let angleOffCenter = rotation - wedgeCenter
      return Angle(angleOffCenter)
    }
    
    
    private var directionRotatedOffWedgeCenter: RotationDirection {
      if rotation > wedgeCenter {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }


    
    
    // MARK:
    // MARK: Neighbor Helper Properties/Methods.
    // swift 2: add to a protocol and conform RotationState & WedgeState to it
    private var nextNeighbor: WedgeIndex {
      return nextIndex(wedgeIndex)
    }
    
    private var prevNeighbor: WedgeIndex {
      return prevIndex(wedgeIndex)
    }
    
    private func nextIndex(index: Int) -> Int {
      var next = index + 1
      if next > wedgeMaxIndex {
        next = 0
      }
      return next
    }
    
    private func prevIndex(index: Int) -> Int {
      var prev = index - 1
      if prev < 0 {
        prev = wedgeMaxIndex
      }
      return prev
    }
    
    
    
    
    
    // MARK:
    // MARK: Min and Max Rotations for current wedgeSeries
    
    var minimumRotationWithinWedgeSeries: Rotation {
      var minimumRotation: Rotation
      switch layoutDirection {
      case .ClockwiseLayout:
        minimumRotation = seriesStartingRotation - seriesWidth
      case .CounterClockwiseLayout:
        minimumRotation = seriesStartingRotation
      }
      minimumRotation += (seriesWidth * wedgeSeriesMultiplier)
      
      let msg = "minimumRotation must be less than rotation"
      assert(minimumRotation < rotation, msg)
      
      return minimumRotation
    }
    
    var maximumRotationWithinWedgeSeries: Rotation {
      var maximumRotation: Rotation
      switch layoutDirection {
      case .ClockwiseLayout:
        maximumRotation = seriesStartingRotation
      case .CounterClockwiseLayout:
        maximumRotation = seriesStartingRotation + seriesWidth
      }
      maximumRotation += (seriesWidth * wedgeSeriesMultiplier)
      
      let msg = "maximumRotation must be greater than rotation"
      assert(maximumRotation > rotation, msg)
      
      return maximumRotation
    }
    
    private var seriesStartingRotation: Rotation {
      switch layoutDirection {
      case .ClockwiseLayout:
        return Rotation(0) + (wedgeSeperation / 2)
      case .CounterClockwiseLayout:
        return Rotation(0) - (wedgeSeperation / 2)
      }
    }
    
    
    private var wedgeSeriesMultiplier: Int {
      let normalizeRotation = rotation - seriesStartingRotation
      var index = Int(normalizeRotation / seriesWidth)
      
      if rotation > seriesStartingRotation {
        index = index + 1
      }
      
      switch layoutDirection {
      case .ClockwiseLayout:
        return index
      case .CounterClockwiseLayout:
        return index - 1
      }
    }

    
    func wedgeCenterForIndex(index: WedgeIndex) -> Rotation {
      let maxIndexMsg = "Index \(index) may not be greater than \(wedgeMaxIndex)"
      assert(index < wedgeSeries.wedgeCount, maxIndexMsg)
      let minIndexMsg = "Index \(index) may not be less than 0"
      assert(index >= 0, maxIndexMsg)
      
      let wedgeSeperation = Rotation(self.wedgeSeperation)
      let distanceWithinSeries = wedgeSeperation * index
      let min = minimumRotationWithinWedgeSeries
      let max = maximumRotationWithinWedgeSeries

      let wedgeCenterForIndex: Rotation
      
      switch layoutDirection {
        
      case .ClockwiseLayout:
        let index0WedgeCenter = max - (wedgeSeperation / 2)
        wedgeCenterForIndex   = index0WedgeCenter - distanceWithinSeries
        
      case .CounterClockwiseLayout:
        let index0WedgeCenter = min + (wedgeSeperation / 2)
        wedgeCenterForIndex   = index0WedgeCenter + distanceWithinSeries
      }
      
      let greaterMsg = "WedgeCenter \(wedgeCenterForIndex) for index \(index) is too low"
      assert(wedgeCenterForIndex > minimumRotationWithinWedgeSeries, greaterMsg)
      let lessMsg = "WedgeCenter \(wedgeCenterForIndex) for index \(index) is too high"
      assert(wedgeCenterForIndex < maximumRotationWithinWedgeSeries, lessMsg)
      
      if index == wedgeIndex {
        let msg = "\(wedgeCenterForIndex) is not \(wedgeCenter) for index: \(index)"
        assert(wedgeCenter == wedgeCenterForIndex, msg)
      }
      
      return wedgeCenterForIndex
    }

    
    // MARK:
    // MARK: wedgeSeries connivence properties.
    private var wedgeCount: Int {
      return wedgeSeries.wedgeCount
    }
    
    private var wedgeMaxIndex: Int {
      return wedgeSeries.wedgeMaxIndex
    }
    
    private var seriesWidth: Rotation {
      return wedgeSeries.seriesWidth
    }
    
    private var wedgeSeperation: Angle {
      return wedgeSeries.wedgeSeperation
    }
    
    private var layoutDirection: LayoutDirection {
      return wedgeSeries.direction
    }
    
    
    // MARK:
    // MARK: Helpers
    private var polarity: Polarity {
      if rotation >= 0 {
        return .Positive
      } else {
        return .Negative
      }
    }

    
    
  }
}

// MARK:
// MARK: enums


extension InfiniteImageWheel {
  enum Polarity: String, Printable  {
    case Positive = "Positive"
    case Negative  = "Negative"
    
    var description: String {
      return self.rawValue
    }
  }
}