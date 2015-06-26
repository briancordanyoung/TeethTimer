

extension InfiniteImageWheel {
  class RotationState: NSObject, Printable {
    
    let rotation:        Rotation
    let wedgeSeries:     WedgeSeries
    
    init(    rotation: Rotation,
          wedgeSeries: WedgeSeries) {
        
        self.rotation    = Rotation(rotation)
        self.wedgeSeries = WedgeSeries(wedgeSeries)
    }
    
    init( state: RotationState) {
      self.rotation    = Rotation(state.rotation)
      self.wedgeSeries = WedgeSeries(state.wedgeSeries)
    }
    
    // Computed Properties to access wheelShape properties easily.
    var wedgeCount: Int {
      return wedgeSeries.wedgeCount
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
    
    // Computed Properties to compute once and store each result
    
    lazy var layoutRotation: Rotation = {
      return self.rotation * -1
    }()
    
    lazy var wedgeCenterDistance: Rotation = {
      let distanceWithinPartialRotation =
                 self.wedgeSeperation * self.wedgeIndexInPositiveLayoutDirection
      let distanceOfCompleteRotations    = self.seriesWidth * self.rotationCount

      return distanceOfCompleteRotations + distanceWithinPartialRotation
    }()
    

    lazy var wedgeCenter: Rotation = {
      switch self.layoutDirection {
      case .Clockwise:
        return self.wedgeCenterDistance
      case .CounterClockwise:
        return self.wedgeCenterDistance * -1
      }
    }()
    
    lazy var directionRotatedOffWedgeCenter: RotationDirection = {
      if self.layoutRotation > self.wedgeCenter {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }()

    
    // WedgeIndex is from 0 to (count-of-images - 1)
    var wedgeIndex: WedgeIndex {
      return self.wedgeIndexInLayoutDirection
    }
    
    
    
    // WedgeIndex is from 0 to (count-of-images - 1)
    lazy var wedgeIndexInLayoutDirection: WedgeIndex = {
      if self.layoutRotation >= 0 {            // positive rotation
                                               // in the direction of the layout
        return self.wedgeIndexInPositiveLayoutDirection
        
      } else {                                 // negitive rotation in
                                               // the direction of the layout
        return self.wedgeCount - (self.wedgeIndexInPositiveLayoutDirection + 1)
        
      }
      }()
    
    
    // Private Computed Properties to compute once and store each result
    
    // Much of the math to compute these properties assumes that the
    // begining rotation of the wedge seriesWidth is at 0.  But, seriesWidth is
    // actually a half wedgeSeperation off, so that when rotation = 0, the 
    // first wedge is centered at the top of the wheel.
    // offsetRotation is the rotation shifted so the it the wedge min or max
    // is at the top of the wheel
    private lazy var offsetRotation: Rotation = {
      switch self.layoutDirection {
      case .Clockwise:
        return self.layoutRotation + (self.wedgeSeperation / 2)
      case .CounterClockwise:
        return self.layoutRotation - (self.wedgeSeperation / 2)
      }
    }()
    
    // How many complete rotations the wheel been rotated from the start.
    // Positive rotations are in the same direction as self.layoutDirection
//     lazy var rotationCount: Int = {
//      let reciprocity: Int
//      switch self.layoutDirection {
//      case .Clockwise:
//        reciprocity = 1
//      case .CounterClockwise:
//        reciprocity = -1
//      }
//      
//      let positiveRotationCount = Int((self.offsetRotation / self.seriesWidth).value)
//      let negitiveRotationCount = (positiveRotationCount - 1)
//      if self.remainingRotation >= 0 {
//        return positiveRotationCount * reciprocity
//      } else {
//        return negitiveRotationCount * reciprocity
//      }
//    }()
    
    lazy var rotationCount: Int = {
        return Int((abs(self.offsetRotation) / self.seriesWidth).value)
    }()
    
    // The remainder (modulus) of the seriesWidth in to the rotation.
    // This remainder transforms a rotation of any size in to a rotation
    // between 0 and seriesWidth.
    private lazy var remainingRotation: Rotation = {
      return self.offsetRotation % self.seriesWidth
    }()
    
    
    // The number of wedges in the remainder of the remainingRotation property
    private lazy var wedgeIndexInPositiveLayoutDirection: Int = {
      let index = Int(abs(self.remainingRotation) / self.wedgeSeperation)
      assert(index < self.wedgeCount, "wedgeIndex is greater than wedgeCount")
      return index
    }()
    
//    private lazy var wedgeIndexInPositiveLayoutDirection: WedgeIndex = {
//      let wedgeIndex = WedgeIndex(abs(self.wedgeCountInPartialRotation - 1))
//      assert(wedgeIndex >= 0, "wedgeIndex is less than 0")
//      assert(wedgeIndex < self.wedgeCount, "wedgeIndex is greater than wedgeCount")
//      return wedgeIndex
//      }()
    

    
    
    
    
    
    
    
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

