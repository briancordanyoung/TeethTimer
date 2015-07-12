import UIKit

extension InfiniteImageWheel {
  
  func rotationForIndex(index: WedgeIndex) -> Rotation {
    let wedgewidth = Rotation(wedgeSeries.wedgeSeperation)
    let rotation = wedgewidth * index
    
    // LayoutDirection 9from wedgeSeries) is opposite rotation direction
    switch wedgeSeries.direction {
      case .Clockwise:
      return rotation * -1
      case .CounterClockwise:
      return rotation
    }
  }
  
  func imageIndexForRotation(rotation: Rotation) -> WedgeIndex {
    let tmpRotation = RotationState(rotation: rotation,
                                 wedgeSeries: wedgeSeries)
    return tmpRotation.wedgeIndex
  }
}
