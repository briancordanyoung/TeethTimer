import UIKit

extension InfiniteImageWheel {
  
  func rotationForIndex(index: WedgeIndex) -> Rotation {
    let wedgewidth = Rotation(wedgeSeries.wedgeSeperation)
    let stepsFrom0 = Rotation(index - 1)
    let rotation = wedgewidth * stepsFrom0
    
    switch wedgeSeries.direction {
      case .Clockwise:
      return rotation
      case .CounterClockwise:
      return rotation * -1
    }
  }
  
  func imageIndexForRotation(rotation: Rotation) -> WedgeIndex {
    let tmpRotation = RotationState(rotation: rotation,
                                 wedgeSeries: wedgeSeries)
    return tmpRotation.wedgeIndex
  }
}
