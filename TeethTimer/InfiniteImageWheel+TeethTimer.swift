import UIKit

extension InfiniteImageWheel {
  
  func rotationForIndex(index: WedgeIndex) -> Rotation {
    let wedgeSeperation = Rotation(wedgeSeries.wedgeSeperation)
    
    switch wedgeSeries.direction {
    case .ClockwiseLayout:
      return wedgeSeperation * index
    case .CounterClockwiseLayout:
      return wedgeSeperation * (rotationState.wedgeMaxIndex - index)
    }
  }
  
  func indexFromRotation(rotation: Rotation) -> WedgeIndex {
    let state = RotationState(rotation: rotation,
                           wedgeSeries: wedgeSeries)
    return state.wedgeIndex
  }
}
