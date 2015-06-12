
import UIKit


class SnapshotView: UIView {
  
  override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
    
    if let subview: AnyObject = self.subviews.first {
      let castSubview = subview as! UIView
      
      for wedgeView in castSubview.subviews {
        let castWedgeView = wedgeView as! UIView
        let pointForTargetView = castWedgeView.convertPoint(point, fromView:self )
        if CGRectContainsPoint(castWedgeView.bounds, pointForTargetView) {
          return castWedgeView.hitTest(pointForTargetView, withEvent: event)
        }
      }
      
      let pointForTargetView = castSubview.convertPoint(point, fromView:self )
      if CGRectContainsPoint(castSubview.bounds, pointForTargetView) {
        return castSubview.hitTest(pointForTargetView, withEvent: event)
      }
      
    }
    
    return super.hitTest(point, withEvent: event)
  }
}