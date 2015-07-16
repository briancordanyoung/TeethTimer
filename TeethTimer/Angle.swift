import UIKit


// MARK: Angle - A number that represents an angle in both
//               degrees or radians.
//       Unlike AccumulatedAngle, Angle is limited to representing
//       a single circle from -π to π
struct Angle: AngularType {
  
  var value: Double {
    didSet(oldValue) {
      value = Angle.limit(value)
    }
  }
  
  init(_ value: Double) {
    self.value = Angle.limit(value)
  }
  
  
  // All other initilizers call the above init()
  init(_ angle: Angle) {
    self.init(angle.value)
  }
  
  init(_ angle: AccumulatedAngle) {
    self.init(angle.value)
  }
  
  init(_ value: CGFloat) {
    self.init(Double(value))
  }
  
  init(_ value: Int) {
    self.init(Double(value))
  }
  
  init(transform: CGAffineTransform) {
    let b = transform.b
    let a = transform.a
    let angle = atan2(b, a)
    self.init(radians: angle)
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
  
  var accumulatedAngle: AccumulatedAngle {
    return AccumulatedAngle(radians)
  }

  var rotation: AccumulatedAngle {
    return AccumulatedAngle(radians)
  }

  var description: String {
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

// Extend CGFloat to convert from radians
extension CGFloat {
  init(_ angle: Angle) {
    self.init(CGFloat(angle.radians))
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



extension Angle {
  enum Preset {
    case halfCircle
    case quarterCircle
    case pi
  }
}

// MARK: Static Methods
extension Angle {
  static func preset(preset: Preset) -> Angle {
    switch preset {
    case .halfCircle,
         .pi:
      return Angle(M_PI)
    case .quarterCircle:
      return Angle(M_PI * 0.50)
    }
  }
  
  static var pi: Angle {
    return Angle.preset(.pi)
  }
  
  static var halfCircle: Angle {
    return Angle.preset(.halfCircle)
  }
  
  static var quarterCircle: Angle {
    return Angle.preset(.quarterCircle)
  }
}




// MARK: Angle & Int specific overloads

func % (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value % Double(rhs))
}


func + (lhs: Int, rhs: Angle) -> Angle {
  return Angle(Double(lhs) + rhs.value)
}

func - (lhs: Int, rhs: Angle) -> Angle {
  return Angle(Double(lhs) - rhs.value)
}

func + (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value + Double(rhs))
}

func - (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value - Double(rhs))
}




func < (lhs: Int, rhs: Angle) -> Bool {
  return Double(lhs) < rhs.value
}

func == (lhs: Int, rhs: Angle) -> Bool {
  return Double(lhs) == rhs.value
}

func < (lhs: Angle, rhs: Int) -> Bool {
  return lhs.value < Double(rhs)
}

func == (lhs: Angle, rhs: Int) -> Bool {
  return lhs.value == Double(rhs)
}



func += (inout lhs: Angle, rhs: Int) {
  lhs.value = lhs.value + Double(rhs)
}

func -= (inout lhs: Angle, rhs: Int) {
  lhs.value = lhs.value - Double(rhs)
}

func / (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value / Double(rhs))
}

func * (lhs: Angle, rhs: Int) -> Angle {
  return Angle(lhs.value * Double(rhs))
}
