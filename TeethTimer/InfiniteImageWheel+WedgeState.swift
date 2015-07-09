import UIKit


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
      switch directionFromSelectedWedge {
      case .ClockwiseLayout:
        return Angle(rotationState.wedgeCenter + centerDistanceToSelectedWedge)
        
      case .CounterClockwiseLayout:
        return Angle(rotationState.wedgeCenter - centerDistanceToSelectedWedge)
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
      let offcenter = rotationState.angleOffCenterFromLayoutDirection(directionFromSelectedWedge)
      let distanceToRotation = centerDistanceToSelectedWedge + offcenter
      return abs(distanceToRotation)
    }
    
    
    // MARK: Calculated Properties
    
    // The rotation distance between the center of this wedge and the
    // selected wedge that the rotationState returns
    var centerDistanceToSelectedWedge: Rotation {
      return Rotation(rotationState.wedgeSeperation) * steps
    }
    
    var laidoutIndex: Int {
      switch rotationState.layoutDirection {
      case .ClockwiseLayout:
        return index
        
      case .CounterClockwiseLayout:
        return rotationState.wedgeMaxIndex - index
      }
    }


    var steps: Int {
      return min(clockwiseSteps,counterClockwiseSteps)
    }
    
    var directionFromSelectedWedge: LayoutDirection {
      if clockwiseSteps < counterClockwiseSteps {
        return .ClockwiseLayout
      } else {
        return .CounterClockwiseLayout
      }
    }
    
    var clockwiseSteps: Int {
      
      var count   = 0
      var next    = laidoutIndex
      while next != rotationState.wedgeIndex {
        count++
        next = nextIndex(next)
      }
      return count
    }
    
    var counterClockwiseSteps: Int {

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
      return nextIndex(laidoutIndex)
    }
    
    var prevNeighbor: WedgeIndex {
      return prevIndex(laidoutIndex)
    }
    
    func nextIndex(index: Int) -> Int {
      var next = index + 1
      if next > rotationState.wedgeMaxIndex {
        next = 0
      }
      return next
    }
    
    func prevIndex(index: Int) -> Int {
      var prev = index - 1
      if prev < 0 {
        prev = rotationState.wedgeMaxIndex
      }
      return prev
    }
    
  }
}
