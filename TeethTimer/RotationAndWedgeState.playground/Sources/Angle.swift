import UIKit


// MARK: Angle - A number that represents an angle in both
//               degrees or radians.
//       Unlike AccumulatedAngle, Angle is limited to representing
//       a single circle from -PI to PI
public struct Angle: AngularType {
  
  public var value: Double {
    didSet(oldValue) {
      value = Angle.limit(value)
    }
  }
  
  public init(_ value: Double) {
    self.value = Angle.limit(value)
  }
  
  
  // All other initilizers call the above init()
  public init(_ angle: Angle) {
    self.init(angle.value)
  }
  
  public init(_ angle: AccumulatedAngle) {
    self.init(angle.value)
  }
  
  public init(_ value: CGFloat) {
    self.init(Double(value))
  }
  
  public init(_ value: Int) {
    self.init(Double(value))
  }
  
  public init(transform: CGAffineTransform) {
    let b = transform.b
    let a = transform.a
    let angle = atan2(b, a)
    self.init(radians: angle)
  }
  
  public init(radians: Double) {
    self.init(radians)
  }
  
  public init(radians: CGFloat) {
    self.init(Double(radians))
  }
  
  public init(radians: Int) {
    self.init(Double(radians))
  }
  
  
  public init(degrees: Double) {
    self.init(radians: Angle.degrees2radians(degrees))
  }
  
  public init(degrees: CGFloat) {
    self.init(degrees: Double(degrees))
  }
  
  public init(degrees: Int) {
    self.init(degrees: Double(degrees))
  }
  
  
  public var radians: Double  {
    return value
  }
  
  public var degrees: Double {
    return Angle.radians2Degrees(value)
  }
  
  public var accumulatedAngle: AccumulatedAngle {
    return AccumulatedAngle(radians)
  }

  public var rotation: AccumulatedAngle {
    return AccumulatedAngle(radians)
  }

  public var description: String {
    return "\(value)"
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
    let pi  = M_PI
    let tau = M_PI * 2
    
    if angle >  pi {
      angle += pi
      let totalRotations = floor(angle / tau)
      angle  = angle - (tau * totalRotations)
      angle -= pi
    }
    
    if angle < -pi {
      angle -= pi
      let totalRotations = floor(abs(angle) / tau)
      angle  = angle + (tau * totalRotations)
      angle += pi
    }
    
    return angle
  }
}

// Convenience Computed Properties to convert to CGFloat
extension Angle {
  public var cgRadians: CGFloat  {
    return CGFloat(radians)
  }

  public var cgDegrees: CGFloat {
    return CGFloat(degrees)
  }
}


// MARK: Protocol Conformance
extension Angle: IntegerLiteralConvertible {
  public init(integerLiteral: IntegerLiteralType) {
    self.init(Double(integerLiteral))
  }
}

extension Angle: FloatLiteralConvertible {
  public init(floatLiteral: FloatLiteralType) {
    self.init(Double(floatLiteral))
  }
}


// MARK: Extend Int to initialize with an Angle
extension Int {
  public init(_ angle: Angle) {
    self = Int(angle.value)
  }
}




func isWithinAngleLimits(value: Double) -> Bool {
  var isWithinLimits = true
  
  if value > M_PI {
    isWithinLimits = false
  }
  
  if value < -M_PI {
    isWithinLimits = false
  }
  
  return isWithinLimits
}

func isWithinAngleLimits(value: CGFloat) -> Bool {
  var isWithinLimits = true
  
  if value > CGFloat(M_PI) {
    isWithinLimits = false
  }
  
  if value < CGFloat(-M_PI) {
    isWithinLimits = false
  }
  
  return isWithinLimits
}



// MARK: Angle & Int specific overloads

public func % (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value % Double(rhs))
}


public func + (lhs: Int, rhs: Angle) -> Angle {
  return Angle(Double(lhs) + rhs.value)
}

public func - (lhs: Int, rhs: Angle) -> Angle {
  return Angle(Double(lhs) - rhs.value)
}

public func + (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value + Double(rhs))
}

public func - (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value - Double(rhs))
}




public func < (lhs: Int, rhs: Angle) -> Bool {
  return Double(lhs) < rhs.value
}

public func == (lhs: Int, rhs: Angle) -> Bool {
  return Double(lhs) == rhs.value
}

public func < (lhs: Angle, rhs: Int) -> Bool {
  return lhs.value < Double(rhs)
}

public func == (lhs: Angle, rhs: Int) -> Bool {
  return lhs.value == Double(rhs)
}



public func += (inout lhs: Angle, rhs: Int) {
  lhs.value = lhs.value + Double(rhs)
}

public func -= (inout lhs: Angle, rhs: Int) {
  lhs.value = lhs.value - Double(rhs)
}

public func / (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value / Double(rhs))
}

public func * (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value * Double(rhs))
}
