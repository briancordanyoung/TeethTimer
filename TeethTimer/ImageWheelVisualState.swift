import UIKit

class ImageWheelVisualState {
    var wedgeOpacityList = Dictionary<Int, CGFloat>()
    var imageWheelFullRotations: Int = 0

    init() {
        clearWedgeOpacityList()
    }
    
    func clearWedgeOpacityList() {
        wedgeOpacityList = Dictionary<Int, CGFloat>()
    }
    
    func initOpacityListWithWedges( wedges: [WedgeRegion]) {
        for wedge in wedges {
            wedgeOpacityList[wedge.value] = CGFloat(0)
        }
    }
    
    func setOpacityOfWedgeImageViews(views: [UIImageView]) {
       assert(wedgeOpacityList.count == views.count, "setOpacityOfWedgeImageViews requires both the wedgeOpacityList and views arrays to each have the same number of elements.")
        for view in views {
            if let opacityValue = wedgeOpacityList[view.tag] {
                view.alpha = opacityValue
            }
        }
    }

}