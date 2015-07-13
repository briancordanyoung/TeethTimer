import UIKit

extension InfiniteImageWheel {
  
  func indexFromRotation(rotation: Rotation) -> WedgeIndex {
    let state = RotationState(rotation: rotation,
                           wedgeSeries: wedgeSeries)
    return state.wedgeIndex
  }
}
