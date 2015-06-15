import Foundation

typealias Rotation = AccumulatedAngle
// MARK: AccumulatedAngle - A number that represents an angle in both 
//                          degrees or radians.
struct AccumulatedAngle: NumericType, Printable {
  
  var value: Double
  
  init(_ value: Double) {
    self.value = value
  }
  
  
  // All other initilizers call the above init()
  init(_ angle: Angle) {
    self.init(Double(angle.value))
  }

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
  
  var angle: Angle {
    return Angle(radians)
  }
  
  var description: String {
    return "\(value)"
  }
  
}

// Convenience Computed Properties to convert to CGFloat
extension AccumulatedAngle  {
  var cgRadians: CGFloat  {
    return CGFloat(radians)
  }
  
  var cgDegrees: CGFloat {
    return CGFloat(degrees)
  }
}


// MARK: Protocol Conformance
extension AccumulatedAngle: IntegerLiteralConvertible {
  init(integerLiteral: IntegerLiteralType) {
    self.init(Double(integerLiteral))
  }
}

extension AccumulatedAngle: FloatLiteralConvertible {
  init(floatLiteral: FloatLiteralType) {
    self.init(Double(floatLiteral))
  }
}


// MARK: Extend Int to initialize with an AccumulatedAngle
extension Int {
  init(_ accumulatedAngle: AccumulatedAngle) {
    self = Int(accumulatedAngle.radians)
  }
}


extension AccumulatedAngle {
  static var pi: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.pi))
    return AccumulatedAngle(M_PI)
  }

  static var tau: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.tau))
    return AccumulatedAngle(M_PI * 2)
  }

  static var full: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.full))
    return AccumulatedAngle(M_PI * 2)
  }

  static var half: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.half))
    return AccumulatedAngle(M_PI)
  }

  static var quarter: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.quarter))
    return AccumulatedAngle(M_PI * 0.50)
  }

  static var threeQuarter: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.threeQuarter))
    return AccumulatedAngle(M_PI * 1.50)
  }
}

