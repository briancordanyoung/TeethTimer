import UIKit

extension InfiniteImageWheel {
  
  func rotationForIndex(index: WedgeIndex) -> Rotation {
    
    let wedgeSeperation               = Rotation(wedgeSeries.wedgeSeperation)
    let invertedIndex                 = rotationState.wedgeMaxIndex - index
    let distanceOfCompletRotations    = rotationState.distanceOfCompletRotations

    let distanceWithinPartialRotation: Rotation
    
    switch wedgeSeries.direction {
    case .ClockwiseLayout:
      distanceWithinPartialRotation = abs(wedgeSeperation * index)
    case .CounterClockwiseLayout:
      distanceWithinPartialRotation = abs(wedgeSeperation * invertedIndex)
    }
    
    let distanceToWedgeCenter = distanceOfCompletRotations +
                                distanceWithinPartialRotation

    return polarityAdjustedRotation(distanceToWedgeCenter)
  }
  
  func polarityAdjustedRotation(distanceToWedgeCenter: Rotation) -> Rotation {
    switch rotationState.polarity {
    case .Positive:
      return abs(distanceToWedgeCenter)
      
    case .Negative:
      return abs(distanceToWedgeCenter) * -1
    }
  }
  
  func indexFromRotation(rotation: Rotation) -> WedgeIndex {
    let state = RotationState(rotation: rotation,
                           wedgeSeries: wedgeSeries)
    return state.wedgeIndex
  }
}
