import UIKit


extension InfiniteImageWheel {
  struct WedgeState {
    
    // MARK: Properties
    let rotationState: RotationState
    let index: WedgeIndex
    
    
    // MARK: Convenience
    var wedgeSeries: WedgeSeries {
      return rotationState.wedgeSeries
    }

    // MARK: Layout
    var layoutAngle: Angle {
      switch wedgeSeries.direction {
        case .ClockwiseLayout:
          return clockwiseLayoutAngle
        case .CounterClockwiseLayout:
          return counterClockwiseLayoutAngle
      }
    }
    
    private var counterClockwiseLayoutAngle: Angle {
      let selectedWedgeCenter = Angle(rotationState.wedgeCenter * -1)
      
      switch directionFromSelectedWedge {
      case .Clockwise:
        return selectedWedgeCenter + Angle(distanceToSelectedWedgeOnCenter)
      case .CounterClockwise:
        return selectedWedgeCenter - Angle(distanceToSelectedWedgeOnCenter)
      }
    }
    
    private var clockwiseLayoutAngle: Angle {
      let selectedWedgeCenter = Angle(rotationState.wedgeCenter * -1)
      
      switch directionFromSelectedWedge {
      case .Clockwise:
        return selectedWedgeCenter - Angle(distanceToSelectedWedgeOnCenter)
      case .CounterClockwise:
        return selectedWedgeCenter + Angle(distanceToSelectedWedgeOnCenter)
      }
    }
    
    // MARK: Shape
    var shapeAngle: Angle {
      return (wedgeSeries.wedgeSeperation * 2) * Angle(percentToNextWedge)
    }
    
    
    // MARK: Calcuations to curent Rotation & Wedge Center
    // The rotation distance between the center of this wedge and the
    // rotation that the rotationState returns
    private var distanceToRotation: Rotation {
      let offcenter = rotationState.offsetAngleFromWedgeCenter
      let distanceToRotation = distanceToSelectedWedgeOnCenter + offcenter
      return abs(distanceToRotation)
    }
    
    // The rotation distance between the center of this wedge and the
    // center of the selected wedge that the rotationState returns
    private var distanceToSelectedWedgeOnCenter: Rotation {
      return Rotation(wedgeSeries.wedgeSeperation) * steps
    }

    
    private var directionFromSelectedWedge: RotationDirection {
      if clockwiseSteps < counterClockwiseSteps {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }
    
    
    // MARK: Steps from the current index
    private var steps: Int {
      return min(clockwiseSteps,counterClockwiseSteps)
    }

    private var clockwiseSteps: Int {
      var count   = 0
      var next    = index
      while next != rotationState.wedgeIndex {
        count++
        next = nextIndex(next)
      }
      return count
    }
    
    private var counterClockwiseSteps: Int {
      var count   = 0
      var prev    = index
      while prev != rotationState.wedgeIndex {
        count++
        prev = prevIndex(prev)
      }
      return count
    }
    

    
    
    // MARK: How much a wedge is rotated off of being the current index (in %)
    private var percentToNextWedge: Double {
      
      let invercePercentage = percentOfWidth( Angle(distanceToRotation),
                                    forState: rotationState)
      return 1 - invercePercentage
    }
    
    private func percentOfWidth(value: Angle,
               forState state: RotationState) -> Double {
                
      return percentValue(value, isBetweenLow: Angle(0),
                                      AndHigh: wedgeSeries.wedgeSeperation)
    }

    private func percentValue<T:AngularType>(value: T,
                        isBetweenLow   low: T,
                        AndHigh       high: T ) -> Double {
        return (value.value - low.value) / (high.value - low.value)
    }

    
    
    // MARK: Neighbor Properties/Methods.
    // swift 2-do: add to a protocol and conform RotationState & WedgeState to it
    private var nextNeighbor: WedgeIndex {
      return nextIndex(index)
    }
    
    private var prevNeighbor: WedgeIndex {
      return prevIndex(index)
    }
    
    private func nextIndex(index: Int) -> Int {
      var next = index + 1
      if next > wedgeSeries.wedgeMaxIndex {
        next = 0
      }
      return next
    }
    
    private func prevIndex(index: Int) -> Int {
      var prev = index - 1
      if prev < 0 {
        prev = wedgeSeries.wedgeMaxIndex
      }
      return prev
    }
    
  }
}
