import UIKit

extension InfiniteImageWheel {
  
  func rotationForIndex(index: WedgeIndex) -> Rotation {
    let wedgewidth = Rotation(wedgeSeries.wedgeSeperation)
    
    switch wedgeSeries.direction {
    case .ClockwiseLayout:
      return wedgewidth * index
    case .CounterClockwiseLayout:
      return wedgewidth * (rotationState.wedgeMaxIndex - index)
    }
  }
  
  func imageIndexForRotation(rotation: Rotation) -> WedgeIndex {
    let tmpRotation = RotationState(rotation: rotation,
                                 wedgeSeries: wedgeSeries)
    return tmpRotation.wedgeIndex
  }
}
