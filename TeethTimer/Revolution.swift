import Foundation

// A number that represents the degrees or radians around a circle.
class Revolution: NSObject {
  
  let revolution: CGFloat
  
  init(radians: CGFloat) {
    revolution = radians
    super.init()
  }
  
  convenience init(preset: RevolutionPreset) {
    switch preset {
    case .full:
      self.init(radians: CGFloat(M_PI) * CGFloat(2.00))
    case .half:
      self.init(radians: CGFloat(M_PI))
    case .quarter:
      self.init(radians: CGFloat(M_PI) * CGFloat(0.50))
    case .threeQuarter:
      self.init(radians: CGFloat(M_PI) * CGFloat(1.50))
    }
  }
  
  convenience init(degrees: CGFloat) {
    self.init(radians: degrees * CGFloat(M_PI) / 180.0)
  }
  
  func toRadians() -> CGFloat {
    return revolution
  }
  
  func toDegrees() -> CGFloat {
    return radian2Degree(revolution)
  }
  
  private func radian2Degree(radian:CGFloat) -> CGFloat {
    return radian * 180.0 / CGFloat(M_PI)
  }
  
  private func degreesToRadians (value:CGFloat) -> CGFloat {
    return value * CGFloat(M_PI) / 180.0
  }
  
}


