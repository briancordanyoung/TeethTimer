
import UIKit

class WedgeImageView: UIImageView {
  
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
  
  override var image: UIImage? {
    didSet {
      setLayerImage(image)
    }
  }
  
  var pieSliceLayer: PieSliceLayer {
    get {
      return self.layer as! PieSliceLayer
    }
  }
  
  override init(image: UIImage!) {
    super.init(image: image)
    setLayerImage(image)
    setLayerProperties()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setLayerImage(image)
    setLayerProperties()
  }
  
  
  override class func layerClass() -> AnyClass {
    return PieSliceLayer.self
  }
  
  func setLayerImage(image: UIImage?) {
    if let image = self.image {
      pieSliceLayer.image = image.CGImage
    } else {
      pieSliceLayer.image = nil
    }
  }
  
  func setLayerProperties() {
    pieSliceLayer.usePercentage = true;
    pieSliceLayer.percentCoverage = 1.0;
  }
}