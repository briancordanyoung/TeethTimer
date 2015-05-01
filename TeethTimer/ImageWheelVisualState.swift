import UIKit

final class ImageWheelVisualState {
  var wedgeOpacityList = Dictionary<Int, CGFloat>()
  
  init() {
    clearWedgeOpacityList()
  }
  
  func clearWedgeOpacityList() {
    wedgeOpacityList = Dictionary<Int, CGFloat>()
  }
  
  func initOpacityListWithWedges( wedges: [WedgeRegion]) {
    for wedge in wedges {
      wedgeOpacityList[wedge.value] = CGFloat(0)
//      wedgeOpacityList[wedge.value] = CGFloat(1)
    }
  }
  
  func setOpacityOfWedgeImageViews(views: [WedgeImageView]) {
//    assert(wedgeOpacityList.count == views.count, "setOpacityOfWedgeImageViews requires both the wedgeOpacityList and views arrays to each have the same number of elements.")
    for view in views {
      if let opacityValue = wedgeOpacityList[view.tag] {
        if opacityValue == 0.0 {
          if !view.hidden { view.hidden = true }
        } else {
          if view.hidden { view.hidden = false }
          view.percentCoverage = opacityValue
//          view.alpha = opacityValue
          // view.layer.mask = maskForPercentageVisible(opacityValue)
        }
      }
    }
  }
  
//  func maskForPercentageVisible(percentage: CGFloat) -> CALayer {
//    
//  }
}