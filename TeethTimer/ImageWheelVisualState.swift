import UIKit

final class ImageWheelVisualState {
  var wedgeOpacityList = Dictionary<Int, CGFloat>()
  var wedgeAngleList = Dictionary<Int, Angle>()

  init() {
    clearWedgeOpacityList()
    clearWedgeAngleList()
  }
  
  func clearWedgeOpacityList() {
    wedgeOpacityList = Dictionary<Int, CGFloat>()
  }
  
  func clearWedgeAngleList() {
    wedgeAngleList = Dictionary<Int, Angle>()
  }
  
  func initOpacityListWithWedges( wedges: [WedgeRegion]) {
    for wedge in wedges {
      wedgeOpacityList[wedge.value] = CGFloat(0)
    }
  }
  
  func initAngleListWithWedges( wedges: [WedgeRegion]) {
    for wedge in wedges {
      wedgeAngleList[wedge.value] = Angle(0.0)
    }
  }
  
  func setAnglesOfWedgeImageViews(views: [WedgeImageView]) {
    assert(wedgeAngleList.count == views.count, "setAnglesOfWedgeImageViews requires both the wedgeAngleList and views arrays to each have the same number of elements. Wedge Count: \(wedgeAngleList.count)  View Count: \(views.count)")
    for view in views {
      if let angle = wedgeAngleList[view.tag] {
        view.angleWidth = angle
      }
    }
  }
  
  func setOpacityOfWedgeImageViews(views: [WedgeImageView]) {
   assert(wedgeOpacityList.count == views.count, "setOpacityOfWedgeImageViews requires both the wedgeOpacityList and views arrays to each have the same number of elements.")
    for view in views {
      if let opacityValue = wedgeOpacityList[view.tag] {
        view.alpha = opacityValue
      }
    }
  }

}