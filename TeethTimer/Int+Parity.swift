import Swift

extension Int {

  enum Parity: String, Printable  {
    case Even = "Even"
    case Odd  = "Odd"
    
    var description: String {
      return self.rawValue
    }
  }

  var parity: Parity {
    var result: Parity
    if self % 2 == 0 {
      result = .Even
    } else {
      result = .Odd
    }
    return result
  }
}
