import UIKit

// Swift2: These should be methods on the FloatLiteralConvertible Protocal
extension CGFloat {
  
  // Behavious to check is is a Whole Number
  var isWholeNumber: Bool {
    if (self % 1).isZero {
      return true
    } else {
      return false
    }
  }
  
  var isNotWholeNumber: Bool {
    return !isWholeNumber
  }
  
  // Behavious to check if it is a multiple of _
  var isMultipleOf2: Bool {
    return (self / 2).isWholeNumber
  }
  var isMultipleOf4: Bool {
    return (self / 4).isWholeNumber
  }
  var isMultipleOf8: Bool {
    return (self / 8).isWholeNumber
  }
  var isMultipleOf16: Bool {
    return (self / 16).isWholeNumber
  }

  var isNotMultipleOf2: Bool {
    return !self.isMultipleOf2
  }
  var isNotMultipleOf4: Bool {
    return !self.isMultipleOf4
  }
  var isNotMultipleOf8: Bool {
    return !self.isMultipleOf8
  }
  var isNotMultipleOf16: Bool {
    return !self.isMultipleOf16
  }

}

