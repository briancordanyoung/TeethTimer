


extension InfiniteImageWheel {
  class RotationState: NSObject, Printable {
    
    let rotation:        Rotation
    let wedgeSeries:     WedgeSeries
    
    init(    rotation: Rotation,
          wedgeSeries: WedgeSeries) {
        self.rotation   = rotation
        self.wedgeSeries = wedgeSeries
    }
    
    init( state: RotationState) {
      self.rotation    = state.rotation
      self.wedgeSeries = state.wedgeSeries
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
    
    var direction: Direction {
      return wedgeSeries.direction
    }
    
    // Computed Properties to compute once and store each result
    lazy var wedgeIndex: WedgeIndex = {
      switch self.direction {
      case .Clockwise:
        return self.wedgeIndexClockwise
      case .CounterClockwise:
        return self.wedgeIndexCounterClockwise
      }
    }()
    
    lazy var wedgeCenter: Rotation = {
      return (self.seriesWidth * self.rotationCount)  +
             (Rotation(self.wedgeSeperation.value) * self.wedgeIndex)
    }()
    
    lazy var directionRotatedOffWedgeCenter: Direction = {
      if self.rotation > self.wedgeCenter {
        return .Clockwise
      } else {
        return .CounterClockwise
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
      switch self.direction {
      case .Clockwise:
        return self.rotation + (self.wedgeSeperation / 2)
      case .CounterClockwise:
        return self.rotation - (self.wedgeSeperation / 2)
      }
    }()
    
    // How many complete rotations the wheel been rotated from the start.
    // Positive rotations are in the same direction as the direction property
    private lazy var rotationCount: Int = {
      let reciprocity: Int
      switch self.direction {
      case .Clockwise:
        reciprocity = 1
      case .CounterClockwise:
        reciprocity = -1
      }
      
      let positiveRotationCount = Int((self.offsetRotation / self.seriesWidth).value)
      if self.remainingRotation >= 0 {
        return  positiveRotationCount      * reciprocity
      } else {
        return (positiveRotationCount - 1) * reciprocity
      }
    }()
    
    
    // The remainder (modulus) of the seriesWidth in to the rotation.
    // This remainder is transforms a rotation of any size in to a rotation
    // between 0 and seriesWidth.
    private lazy var remainingRotation: Rotation = {
      return self.offsetRotation % self.seriesWidth
    }()
    
    
    // The number of wedges in the remainder of the remainingRotation property
    private lazy var countOfWedgesInRemainder: WedgeIndex = {
      let wedgesInRemainder = self.remainingRotation / self.wedgeSeperation
      let countOfWedgesInRemainder = WedgeIndex(wedgesInRemainder.value)
      return countOfWedgesInRemainder
    }()
    
    // The WedgeIndex if the wheel is laid out clockwise
    private lazy var wedgeIndexClockwise: WedgeIndex = {
      if self.remainingRotation >= 0 {
        return self.countOfWedgesInRemainder + 1
      } else {
        return self.wedgeCount + self.countOfWedgesInRemainder
      }
    }()
    
    // The WedgeIndex if the wheel is laid out counter clockwise
    private lazy var wedgeIndexCounterClockwise: WedgeIndex = {
      return self.wedgeCount + 1 - self.wedgeIndexClockwise
    }()
    
    
    
  }
}


//extension InfiniteImageWheel {
//  enum Placement: Printable {
//    case hidden
//    case placeAt((placement:Angle,width:Angle))
//    
//    var description: String {
//      switch self {
//      case hidden:
//        return "hidden"
//      case placeAt(let angles):
//        return "Placement around Wheel: \(angles.placement) with a wedge width of \(angles.width)"
//      }
//    }
//  }
//}
