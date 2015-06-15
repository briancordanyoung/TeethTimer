import Foundation


// MARK: Angle - A number that represents an angle in both
//               degrees or radians.
//       Unlike AccumulatedAngle, Angle is limited to representing
//       a single circle from -PI to PI
struct Angle: NumericType {
  
  var value: Double
  
  init(_ value: Double) {
    self.value = Angle.limit(value)
  }
  
  
  // All other initilizers call the above init()
  init(_ value: CGFloat) {
    self.init(Double(value))
  }
  
  init(_ value: Int) {
    self.init(Double(value))
  }
  
  
  init(radians: Double) {
    self.init(radians)
  }
  
  init(radians: CGFloat) {
    self.init(Double(radians))
  }
  
  init(radians: Int) {
    self.init(Double(radians))
  }
  
  
  init(degrees: Double) {
    self.init(radians: Angle.degrees2radians(degrees))
  }
  
  init(degrees: CGFloat) {
    self.init(degrees: Double(degrees))
  }
  
  init(degrees: Int) {
    self.init(degrees: Double(degrees))
  }
  
  
  var radians: Double  {
    return value
  }
  
  var degrees: Double {
    return Angle.radians2Degrees(value)
  }
}

// Angle conversions:
// degrees <--> radians
extension Angle {
  static func radians2Degrees(radians:Double) -> Double {
    return radians * 180.0 / Double(M_PI)
  }
  
  static func degrees2radians(degrees:Double) -> Double {
    return degrees * Double(M_PI) / 180.0
  }

  static func limit(var angle:Double) -> Double {
//    let pi  = M_PI
//    let tau = pi * 2
//    
//    if angle >  pi {
//      angle += pi
//      let totalRotations = floor(angle / tau)
//      angle  = angle - (tau * totalRotations)
//      angle -= pi
//    }
//    
//    if angle < -pi {
//      angle -= pi
//      let totalRotations = floor(abs(angle) / tau)
//      angle  = angle + (tau * totalRotations)
//      angle += pi
//    }
    
    return angle
  }
}


// Convenience Computed Properties to convert to CGFloat
extension Angle {
  var cgRadians: CGFloat  {
    return CGFloat(radians)
  }

  var cgDegrees: CGFloat {
    return CGFloat(degrees)
  }
}


// MARK: Protocol Conformance
extension Angle: IntegerLiteralConvertible {
  init(integerLiteral: IntegerLiteralType) {
    self.init(Double(integerLiteral))
  }
}

extension Angle: FloatLiteralConvertible {
  init(floatLiteral: FloatLiteralType) {
    self.init(Double(floatLiteral))
  }
}


// MARK: Extend Int to initialize with an Angle
extension Int {
  init(_ angle: Angle) {
    self = Int(angle.value)
  }
}

