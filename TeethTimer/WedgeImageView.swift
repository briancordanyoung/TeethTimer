
import UIKit

class WedgeImageView: PieImageView {
  
  var percentCoverage: CGFloat {
    get {
      return pieSliceLayer.percentCoverage
    }
    set(newPercentCoverage) {
      pieSliceLayer.percentCoverage = newPercentCoverage
      pieSliceLayer.usePercentage = true;
    }
  }
  
  var angleWidth: CGFloat {
    get {
      return pieSliceLayer.angleWidth
    }
    set(newAngleWidth) {
      pieSliceLayer.angleWidth = newAngleWidth
      pieSliceLayer.usePercentage = false;
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  convenience init(image: UIImage) {
    self.init(frame:CGRectZero)
    self.image = image
    setLayerProperties()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setLayerProperties()
  }
  
  
  func setLayerProperties() {
    pieSliceLayer.usePercentage = false;
    pieSliceLayer.angleWidth    = Circle.full / 6;
  }
}