import UIKit

typealias Rotation = AccumulatedAngle

// MARK: AccumulatedAngle - A number that represents an angle in both 
//                          degrees or radians.
struct AccumulatedAngle: AngularType, Printable {
  
  var value: Double
  
  init(_ value: Double) {
    self.value = value
  }
  
  
  // All other initilizers call the above init()
  init(_ accumulatedAngle: AccumulatedAngle) {
    self.init(Double(accumulatedAngle.value))
  }
  
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

// Extend CGFloat to convert from radians
extension CGFloat {
  init(_ rotation: Rotation) {
    self.init(CGFloat(rotation.radians))
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
  enum Preset {
    case circle
    case halfCircle
    case quarterCircle
    case threeQuarterCircle
    case tau
    case pi
  }
}

// MARK: Class Methods
extension AccumulatedAngle {
  static func preset(preset: Preset) -> AccumulatedAngle {
    switch preset {
    case .circle,
         .tau:
      return AccumulatedAngle(M_PI * 2)
    case .halfCircle,
         .pi:
      return AccumulatedAngle(M_PI)
    case .quarterCircle:
      return AccumulatedAngle(M_PI * 0.50)
    case .threeQuarterCircle:
      return AccumulatedAngle(M_PI * 1.50)
    }
  }
  
  static var pi: AccumulatedAngle {
    return AccumulatedAngle.preset(.pi)
  }
  
  static var tau: AccumulatedAngle {
    return AccumulatedAngle.preset(.tau)
  }
  
  static var circle: AccumulatedAngle {
    return AccumulatedAngle.preset(.circle)
  }
  
  static var halfCircle: AccumulatedAngle {
    return AccumulatedAngle.preset(.halfCircle)
  }
  
  static var quarterCircle: AccumulatedAngle {
    return AccumulatedAngle.preset(.quarterCircle)
  }
  
  static var threeQuarterCircle: AccumulatedAngle {
    return AccumulatedAngle.preset(.threeQuarterCircle)
  }
}



// MARK: AccumulatedAngle & Angle specific overloads

func % (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value % rhs.value)
}


func + (lhs: Angle, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value + rhs.value)
}

func - (lhs: Angle, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value - rhs.value)
}

func + (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value + rhs.value)
}

func - (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value - rhs.value)
}



func < (lhs: Angle, rhs: AccumulatedAngle) -> Bool {
  return lhs.value < rhs.value
}

func == (lhs: Angle, rhs: AccumulatedAngle) -> Bool {
  return lhs.value == rhs.value
}

func < (lhs: AccumulatedAngle, rhs: Angle) -> Bool {
  return lhs.value < rhs.value
}

func == (lhs: AccumulatedAngle, rhs: Angle) -> Bool {
  return lhs.value == rhs.value
}



func += (inout lhs: AccumulatedAngle, rhs: Angle) {
  lhs.value = lhs.value + rhs.value
}

func -= (inout lhs: AccumulatedAngle, rhs: Angle) {
  lhs.value = lhs.value - rhs.value
}

func / (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value / rhs.value)
}

func * (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value * rhs.value)
}




// MARK: AccumulatedAngle & Int specific overloads

func % (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value % Double(rhs))
}


func + (lhs: Int, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(Double(lhs) + rhs.value)
}

func - (lhs: Int, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(Double(lhs) - Double(rhs.value))
}

func + (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value + Double(rhs))
}

func - (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value - Double(rhs))
}



func < (lhs: Int, rhs: AccumulatedAngle) -> Bool {
  return Double(lhs) < rhs.value
}

func == (lhs: Int, rhs: AccumulatedAngle) -> Bool {
  return Double(lhs) == rhs.value
}

func < (lhs: AccumulatedAngle, rhs: Int) -> Bool {
  return lhs.value < Double(rhs)
}

func == (lhs: AccumulatedAngle, rhs: Int) -> Bool {
  return lhs.value == Double(rhs)
}



func += (inout lhs: AccumulatedAngle, rhs: Int) {
  lhs.value = lhs.value + Double(rhs)
}

func -= (inout lhs: AccumulatedAngle, rhs: Int) {
  lhs.value = lhs.value - Double(rhs)
}

func / (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value / Double(rhs))
}

func * (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value * Double(rhs))
}


