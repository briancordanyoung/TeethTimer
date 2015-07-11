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
    var laidoutIndex: Int {
      return index
    }

    var layoutAngle: Angle {
      switch rotationState.layoutDirection {
        case .ClockwiseLayout:
          return clockwiseLayoutAngle
        case .CounterClockwiseLayout:
          return counterClockwiseLayoutAngle
      }
    }
    
    var counterClockwiseLayoutAngle: Angle {
      let selectedWedgeCenter = Angle(rotationState.wedgeCenter * -1)
      
      switch directionFromSelectedWedge {
      case .Clockwise:
        return selectedWedgeCenter + Angle(centerDistanceToSelectedWedge)
      case .CounterClockwise:
        return selectedWedgeCenter - Angle(centerDistanceToSelectedWedge)
      }
    }
    
    var clockwiseLayoutAngle: Angle {
      let selectedWedgeCenter = Angle(rotationState.wedgeCenter * -1)
      
      switch directionFromSelectedWedge {
      case .Clockwise:
        return selectedWedgeCenter - Angle(centerDistanceToSelectedWedge)
      case .CounterClockwise:
        return selectedWedgeCenter + Angle(centerDistanceToSelectedWedge)
      }
    }
    
    var shapeAngle: Angle {
       return (rotationState.wedgeSeperation * 2) * Angle(percentToNextWedge)
    }
    
    // The rotation distance between the center of this wedge and the
    // rotation that the rotationState returns
    var distanceToRotation: Rotation {
      let offcenter = rotationState.offsetFromWedgeCenter
      let distanceToRotation = centerDistanceToSelectedWedge + offcenter
      return abs(distanceToRotation)
    }
    
    
    // MARK:
    
    // The rotation distance between the center of this wedge and the
    // center of the selected wedge that the rotationState returns
    var centerDistanceToSelectedWedge: Rotation {
      return Rotation(rotationState.wedgeSeperation) * steps
    }
    

    
    var directionFromSelectedWedge: RotationDirection {
      if clockwiseSteps < counterClockwiseSteps {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }
    
    
    // MARK: Count the steps from the current index
    var steps: Int {
      return min(clockwiseSteps,counterClockwiseSteps)
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
    

    
    
    
    // MARK: How much a wedge is rotated off of bing the current index as a %
    var percentToNextWedge: Double {
      
      let invercePercentage = percentOfWidth( Angle(distanceToRotation),
                                    forState: rotationState)
      return 1 - invercePercentage
    }
    
    func percentOfWidth(value: Angle, forState state: RotationState) -> Double {
//      let absoluteValue = Angle(abs(value))
      return percentValue(value, isBetweenLow: Angle(0),
                                      AndHigh: state.wedgeSeperation)
      
    }

    func percentValue<T:AngularType>(value: T,
                        isBetweenLow   low: T,
                        AndHigh       high: T ) -> Double {
        return (value.value - low.value) / (high.value - low.value)
    }

    
    
    // MARK: Neighbor Properties/Methods.
    // swift 2: add to a protocol and conform RotationState & WedgeState to it
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
