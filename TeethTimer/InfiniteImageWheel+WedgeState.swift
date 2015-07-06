extension InfiniteImageWheel : Printable {
  struct WedgeState {
    
    // MARK: Properties
    let rotationState: RotationState
    let index: WedgeIndex
    
    init( rotationState: RotationState,
             wedgeIndex: WedgeIndex     ) {
      self.rotationState = rotationState
      self.index = wedgeIndex
    }
    
    
    var description: String {
      let d = Developement()
      let pi = d.pi
      let p  = d.pad

      var description = "rot:\(p(rotationState.rotation.cgDegrees)) "
      description += "(\(rotationState.wedgeIndex))"
      description += "index:\(pi(index)) | "
      description += "layAngle:\(p(layoutAngle.cgDegrees)) "
      description += "dist2Rot:\(p(distanceToRotation.cgDegrees)) "
      description += "centerDist2Rot:\(p(centerDistanceToSelectedWedge.cgDegrees)) "
      description += "laidoutIndex:\(pi(laidoutIndex)) "
      description += "+LaidoutIndex:\(pi(positiveLaidoutIndex)) "
      description += "steps:\(pi(steps)) "
      description += "d: \(directionFromSelectedWedge.description) "
      
      return description
    }
    
    // MARK: Calculated Properties
    var layoutAngle: Angle {
      switch rotationState.polarity {
      case .Positive:
        return positiveLayoutAngle
      case .Negative:
        return negativeLayoutAngle - rotationState.wedgeSeperation
      }
    }
    
    var positiveLayoutAngle: Angle {
      switch directionFromSelectedWedge {
      case .Clockwise:
        return Angle(rotationState.wedgeCenter + centerDistanceToSelectedWedge)
        
      case .CounterClockwise:
        return Angle(rotationState.wedgeCenter - centerDistanceToSelectedWedge)
      }
    }
    
    var negativeLayoutAngle: Angle {
      switch directionFromSelectedWedge {
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
      /* TODO: return to calculation below: */
      // return (rotationState.wedgeSeperation * 2) * Angle(percentToNextWedge)
      return Angle(degrees: 180)
    }
    
    // The rotation distance between the center of this wedge and the
    // rotation that the rotationState returns
    var distanceToRotation: Rotation {
      let offcenter = rotationState.angleOffCenterFromLayoutDirection(directionFromSelectedWedge)
      let distanceToRotation = centerDistanceToSelectedWedge + offcenter
      return abs(distanceToRotation)
    }
    
    
    // MARK: Private Calculated Properties
    
    // The rotation distance between the center of this wedge and the
    // selected wedge that the rotationState returns
    private var centerDistanceToSelectedWedge: Rotation {
      return Rotation(rotationState.wedgeSeperation) * steps
    }
    
    private var positiveLaidoutIndex: Int {
      switch rotationState.layoutDirection {
      case .Clockwise:
        return index
        
      case .CounterClockwise:
        return rotationState.wedgeMaxIndex - index
      }
    }
    
    private var negativeLaidoutIndex: Int {
      switch rotationState.layoutDirection {
      case .Clockwise:
        return rotationState.wedgeMaxIndex - index
        
      case .CounterClockwise:
        return index
      }
    }
    
    
    
    
    private var laidoutIndex: Int {
      switch rotationState.polarity {
      case .Positive:
        return positiveLaidoutIndex
        
      case .Negative:
//        return prevIndex(negativeLaidoutIndex)
        return negativeLaidoutIndex
      }
    }
    
    
    
    
    
    
    private var steps: Int {
      return min(clockwiseSteps,counterClockwiseSteps)
    }
    
    private var directionFromSelectedWedge: LayoutDirection {
      if clockwiseSteps < counterClockwiseSteps {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }
    
    private var clockwiseSteps: Int {
      
      var count   = 0
      var next    = laidoutIndex
      while next != rotationState.wedgeIndex {
        count++
        next = nextIndex(next)
      }
      return count
    }
    
    private var counterClockwiseSteps: Int {

      var count   = 0
      var prev    = laidoutIndex
      while prev != rotationState.wedgeIndex {
        count++
        prev = prevIndex(prev)
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
  
    var nextNeighbor: WedgeIndex {
      return nextIndex(self.index)
    }
    
    var prevNeighbor: WedgeIndex {
      return prevIndex(self.index)
    }
    
    private func nextIndex(index: Int) -> Int {
      var next = index + 1
      if next > rotationState.wedgeMaxIndex {
        next = 0
      }
      return next
    }
    
    private func prevIndex(index: Int) -> Int {
      var prev = index - 1
      if prev < 0 {
        prev = rotationState.wedgeMaxIndex
      }
      return prev
    }
    
  }
}
