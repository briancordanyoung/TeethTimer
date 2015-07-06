

extension InfiniteImageWheel {
  class RotationState: NSObject, Printable {
    
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
      return self.rotation * -1
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
    
    // MARK: Lazy Computed & Stored Properties
    
    
    // WedgeIndex is from 0 to (count-of-images - 1)
    lazy var wedgeIndex: WedgeIndex = {
      //      if self.remainingRotation >= 0 {
      switch self.polarity {
      case .Positive:
        return self.countOfWedgesInRemainder
      case .Negative:
        return self.wedgeMaxIndex - self.countOfWedgesInRemainder
      }
    }()
    
    var distanceWithinPartialRotation: Rotation {
      let wedgeSeperation = Rotation(self.wedgeSeperation)
      
      let distance: Rotation
      
      switch self.polarity {
      case .Positive:
        distance = wedgeSeperation * self.countOfWedgesInRemainder
      case .Negative:
        distance = wedgeSeperation * abs(self.countOfWedgesInRemainder) - self.wedgeSeperation
      }
      
      return abs(distance)
    }
    
    var distanceOfCompletRotations: Rotation {
      return abs(self.seriesWidth * self.rotationCount)
    }
  
    lazy var wedgeCenter: Rotation = {
      
      let wedgeSeperation = Rotation(self.wedgeSeperation)

      let wedgeSep = wedgeSeperation
      let wedgeDex: Int
      if self.polarity == .Positive {
        wedgeDex = self.countOfWedgesInRemainder
      } else {
        wedgeDex = abs(self.countOfWedgesInRemainder)
      }
      let width    = self.seriesWidth.cgDegrees
      let rotCount = self.rotationCount
      
      
      
      let negativeWedgeCenter = self.distanceOfCompletRotations +
                                self.distanceWithinPartialRotation
      
      let positiveWedgeCenter = negativeWedgeCenter * -1
      
      
      let wedgeCenter: Rotation
      
      switch self.polarity {
      case .Positive:
        wedgeCenter = positiveWedgeCenter
        
      case .Negative:
        // The positiveWedgeCenter value was derived using the offsetRotation,
        // which is offset to 0 by half of the wedgeSeperation,
        // in either positively or nagitively, depending on the polarity of the
        // layoutRotation.
        // When the layoutRotation is nagitive, this offsets wedgeCenter a
        // full wedgeSeperation to compensate and continue the proper
        // wedge layout
//        return positiveWedgeCenter - self.wedgeSeperation
        wedgeCenter = negativeWedgeCenter
      }
      
      println("i: \(self.wedgeIndex) \(self.d.pad(wedgeSep.cgDegrees)) * \(wedgeDex) = \(self.d.pad(self.distanceWithinPartialRotation.cgDegrees)) |+| \(self.d.pad(width)) * \(rotCount) = \(self.d.pad(self.distanceOfCompletRotations.cgDegrees)) |=|\(self.d.pad(wedgeCenter.cgDegrees)) @ \(self.d.pad(self.rotation.cgDegrees))")

      return wedgeCenter
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
    /* private */ lazy var offsetRotation: Rotation = {
      switch self.polarity {
      case .Positive:
        return self.layoutRotation + (self.wedgeSeperation / 2)
      case .Negative:
        return self.layoutRotation - (self.wedgeSeperation / 2)
      }
    }()
    
    
    // The remainder (modulus) of the seriesWidth in to the rotation.
    // This remainder is transforms a rotation of any size in to a rotation
    // between 0 and seriesWidth.
    /* private */ lazy var remainingRotation: Rotation = {
      return abs(self.offsetRotation % self.seriesWidth)
    }()
    
    // MARK: Private Computed Properties
    
    // How many complete rotations the wheel been rotated from the start.
    /* private */ var rotationCount: Int {
      return abs(Int((self.offsetRotation / self.seriesWidth).value))
    }
    
    // The number of wedges in the remainder of the remainingRotation property
    /* private */ var countOfWedgesInRemainder: Int {
      let wedgesInRemainder: Rotation
      switch polarity {
        case .Positive:
        wedgesInRemainder = self.remainingRotation / self.wedgeSeperation
        case .Negative:
        wedgesInRemainder = self.remainingRotation / self.wedgeSeperation
      }
      
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