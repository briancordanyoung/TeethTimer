import UIKit

extension InfiniteImageWheel {
  
  // Given a rotation, what is the current index
  func indexFromRotation(rotation: Rotation) -> WedgeIndex {
    let state = RotationState(rotation: rotation,
                           wedgeSeries: wedgeSeries)
    return state.wedgeIndex
  }
}
