

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
    
    // MARK: Computed Properties
    var layoutRotation: Rotation {
      return self.rotation * -1
    }

    // wheelShape connivence properties.
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
    
    // MARK: Lazy Computed & Stored Properties
    
    
    // WedgeIndex is from 0 to (count-of-images - 1)
    lazy var wedgeIndex: WedgeIndex = {
      if self.remainingRotation >= 0 {
        return self.countOfWedgesInRemainder
      } else {
        return self.wedgeCount + self.countOfWedgesInRemainder - 1
      }
    }()
    
    lazy var wedgeCenter: Rotation = {
      let distanceWithinPartialRotation = self.wedgeSeperation * self.wedgeIndex
      let distanceOfCompletRotations    = self.seriesWidth * self.rotationCount
      return distanceOfCompletRotations + distanceWithinPartialRotation
    }()
    
    lazy var directionRotatedOffWedgeCenter: RotationDirection = {
      if self.layoutRotation > self.wedgeCenter {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }()


    
    // MARK: Private Lazy Computed & Stored Properties
    
    // Much of the math to compute these properties assumes that the
    // begining rotation of the wedge seriesWidth is at 0.  But, seriesWidth is
    // actually a half wedgeSeperation off, so that when rotation = 0, the 
    // first wedge is centered at the top of the wheel.
    // offsetRotation is the rotation shifted so the it the wedge min or max
    // is at the top of the wheel
    private lazy var offsetRotation: Rotation = {
      return self.layoutRotation + (self.wedgeSeperation / 2)
    }()
    
    
    // The remainder (modulus) of the seriesWidth in to the rotation.
    // This remainder is transforms a rotation of any size in to a rotation
    // between 0 and seriesWidth.
    private lazy var remainingRotation: Rotation = {
      return self.offsetRotation % self.seriesWidth
    }()
    
    // MARK: Private Computed Properties
    
    // How many complete rotations the wheel been rotated from the start.
    private var rotationCount: Int {
      let positiveRotationCount = Int((self.offsetRotation / self.seriesWidth).value)
      let negitiveRotationCount = (positiveRotationCount - 1)
      
      if self.offsetRotation >= 0 {
        return positiveRotationCount
      } else {
        return negitiveRotationCount
      }
    }
    
    // The number of wedges in the remainder of the remainingRotation property
    private var countOfWedgesInRemainder: Int {
      let wedgesInRemainder = self.remainingRotation / self.wedgeSeperation
      let countOfWedgesInRemainder = Int(wedgesInRemainder.value)
      return countOfWedgesInRemainder
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

