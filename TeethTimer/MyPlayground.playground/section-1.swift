import UIKit




struct Tester {
  var prop: Double {
    didSet {
      prop = prop + 100
    }
  }
}


let test = Tester(prop: 10)
test.prop = 10

test.prop






