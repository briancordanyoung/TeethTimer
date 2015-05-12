import UIKit

func expandRange<T where T: Comparable, T: ArithmeticType>(var range: (start: T,end: T),ByAmount amount: T)
  -> (start: T,end: T) {
    
    if range.start > range.end {
      range.start += amount
      range.end   -= amount
    } else {
      range.start -= amount
      range.end   += amount
    }
    return range
}

let workingRange = (start: CGFloat(-5.0), end: CGFloat(1.0))
let range = expandRange(workingRange, ByAmount: 1)

range.start
range.end