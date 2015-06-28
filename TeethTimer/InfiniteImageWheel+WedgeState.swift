extension InfiniteImageWheel {
  struct WedgeState {
    
    // MARK: Properties
    let rotationState: RotationState
    let index: WedgeIndex
    
    init( rotationState: RotationState,
             wedgeIndex: WedgeIndex     ) {
      self.rotationState = rotationState
      self.index = wedgeIndex
    }
    
    
    // MARK: Calculated Properties
    var layoutAngle: Angle {
      switch direction {
      case .Clockwise:
        return Angle(rotationState.wedgeCenter - centerDistanceToSelectedWedge)
        
      case .CounterClockwise:
        return Angle(rotationState.wedgeCenter + centerDistanceToSelectedWedge)
      }
    }
    
    var percentToNextWedge: Double {
      
      let invercePercentage = percentOfWidth( Angle(distanceToRotation),
                        forState: rotationState)
      
      return 1 - invercePercentage
    }
    
    var shapeAngle: Angle {
      return (rotationState.wedgeSeperation * 2) * Angle(percentToNextWedge)
    }
    
    // The rotation distance between the center of this wedge and the
    // rotation that the rotationState returns
    var distanceToRotation: Rotation {
      let offcenter = rotationState.angleOffCenterFromLayoutDirection(direction)
      let distanceToRotation = centerDistanceToSelectedWedge + offcenter
      return abs(distanceToRotation)
    }
    
    
    // MARK: Private Calculated Properties
    
    // The rotation distance between the center of this wedge and the
    // selected wedge that the rotationState returns
    private var centerDistanceToSelectedWedge: Rotation {
      return Rotation(rotationState.wedgeSeperation) * steps
    }
    
    //
    private var laidoutIndex: Int {
      if rotationState.layoutDirection == .Clockwise {
        return index
      } else {
        return rotationState.wedgeCount - 1 - index
      }
    }
    
    private var steps: Int {
      return min(clockwiseSteps,counterClockwiseSteps)
    }
    
    private var direction: LayoutDirection {
      if clockwiseSteps < counterClockwiseSteps {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }
    
    private var clockwiseSteps: Int {
      let maximumIndex = rotationState.wedgeCount - 1
      
      var count   = 0
      var next    = laidoutIndex
      while next != rotationState.wedgeIndex {
        count++
        next++
        if next > maximumIndex {
          next = 0
        }
        assert(count <= maximumIndex,
                              "clockwiseSteps closure is stuck in a while loop")
      }
      return count
    }
    
    
    private var counterClockwiseSteps: Int {
      let maximumIndex = self.rotationState.wedgeCount - 1

      var count   = 0
      var next    = laidoutIndex
      while next != rotationState.wedgeIndex {
        count++
        next--
        if next < 0  {
          next = maximumIndex
        }
        assert(count <= maximumIndex,
                       "counterClockwiseSteps closure is stuck in a while loop")
      }
      return count
    }
    
    
    func percentOfWidth(value: Angle, forState state: RotationState) -> Double {
      let absoluteValue = Angle(abs(value.value))
      return percentValue(value, isBetweenLow: Angle(0),
                                      AndHigh: state.wedgeSeperation)
      
    }
    
    func percentValue<T:AngularType>(value: T,
                        isBetweenLow   low: T,
                        AndHigh       high: T ) -> Double {
        return (value.value - low.value) / (high.value - low.value)
    }
  
  
    
  }
}
