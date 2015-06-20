import UIKit
typealias WedgeIndex = Int
typealias Rotation = AccumulatedAngle

enum Direction: String, Printable {
  case Clockwise        = "Clockwise"
  case CounterClockwise = "CounterClockwise"
  
  var description: String {
    return self.rawValue
  }
}

let numberFormater = NSNumberFormatter()
numberFormater.minimumIntegerDigits  = 2
numberFormater.maximumIntegerDigits  = 2
numberFormater.minimumFractionDigits = 3
numberFormater.maximumFractionDigits = 3
numberFormater.positivePrefix = " "


func pad(number: Double) -> String {
  return numberFormater.stringFromNumber(number)!
}

func pad(number: Int) -> String {
  return pad(Double(number))
}


func degrees2radians(degrees:Double) -> Double {
  return degrees * Double(M_PI) / 180.0
}

extension RotationState {
  enum Direction: String, Printable {
    case Clockwise        = "Clockwise"
    case CounterClockwise = "CounterClockwise"
    
    var description: String {
      return self.rawValue
    }
  }
}

func wedgeIndexForRotation(rotation: Rotation,
       usingSeriesWidth seriesWidth: Rotation,
                   #wedgeSeperation: Angle,
             andDirection direction: Direction) -> WedgeIndex {
    
    let steps = WedgeIndex((seriesWidth / wedgeSeperation).value)
    
    //
    let remainingRotation: Rotation
    switch direction {
    case .Clockwise:
      let offsetRotation = rotation + (wedgeSeperation / 2)
      remainingRotation  = offsetRotation % seriesWidth
      
    case .CounterClockwise:
      let offsetRotation = rotation - (wedgeSeperation / 2)
      remainingRotation  = offsetRotation % seriesWidth
    }
    
    let wedgeIndex: WedgeIndex
    
    if remainingRotation >= 0 {
      let wedgesInRemainder = remainingRotation / wedgeSeperation
      wedgeIndex = WedgeIndex(wedgesInRemainder.value) + 1
    } else {
      let wedgesInRemainder = remainingRotation / wedgeSeperation
      wedgeIndex =  steps + WedgeIndex(wedgesInRemainder.value)
    }
    
    let result: WedgeIndex
    switch direction {
    case .Clockwise:
      result = wedgeIndex
      
    case .CounterClockwise:
      result = (steps + 1) - wedgeIndex
    }
    
    result
    
    return result
}

let quarter = (M_PI * 0.5)

var result: [String] = []

//for i in 0...500 {
//  let ii = (i * 4) - 1000
//  let radian = degrees2radians(Double(ii) * quarter - Double(0.0000000))
//  let rot = Rotation(radian)
//
//  let anAngle = Angle(rot.value).value
//  
//  let one = wedgeIndexForRotation(rot, usingSeriesWidth: Rotation(M_PI * 4),
//                                        wedgeSeperation: Angle(quarter),
//                                           andDirection: .CounterClockwise)
//  result.append(pad(one))
//}
//

enum Direction: String, Printable {
  case Clockwise        = "Clockwise"
  case CounterClockwise = "CounterClockwise"
  
  var description: String {
    return self.rawValue
  }
}


struct InfiniteImageWheelShape: Printable {
  let wedgeCount:      Int
  let wedgeSeperation: Angle
  let direction:       Direction
  
  var seriesWidth: Rotation {
    return Rotation(wedgeSeperation) * wedgeCount
  }
  
  var description: String {
    return "TODO: impliment me"
  }

}

class RotationState: NSObject, Printable {
  
  let rotation:        Rotation
  let wheelShape:      InfiniteImageWheelShape
  
  init(      rotation: Rotation,
           wheelShape: InfiniteImageWheelShape) {
      self.rotation   = rotation
      self.wheelShape = wheelShape
  }
  
//  convenience init(    rotation: Rotation,
//                     wedgeCount: Int,
//                wedgeSeperation: Angle,
//                      direction: Direction) {
//      
//    let wheelShape = InfiniteImageWheelShape( wedgeCount: seriesWidth,
//                                         wedgeSeperation: wedgeSeperation,
//                                               direction: direction)
//    self.init(rotation: rotation, wheelShape: wheelShape)
//  }
  
  // Computed Properties to access wheelShape properties easily.
  var wedgeCount: Int {
    return wheelShape.wedgeCount
  }

  var seriesWidth: Rotation {
    return wheelShape.seriesWidth
  }
  
  var wedgeSeperation: Angle {
    return wheelShape.wedgeSeperation
  }
  
  var direction: Direction {
    return wheelShape.direction
  }
  
//  override var description: String {
//    return "TODO: impliment me"
//  }
  
  // Computed Properties to compute once and store each aspect
  lazy var offsetRotation: Rotation = {
    switch self.direction {
    case .Clockwise:
      return self.rotation + (self.wedgeSeperation / 2)
    case .CounterClockwise:
      return self.rotation - (self.wedgeSeperation / 2)
    }
  }()
  
  
//  lazy var wedgeCount: Int = {
//    return Int((self.seriesWidth / self.wedgeSeperation).value)
//  }()
  
  
  lazy var rotationCount: Int = {
      let reciprocity: Int
      switch self.direction {
      case .Clockwise:
        reciprocity = 1
      case .CounterClockwise:
        reciprocity = -1
      }
    
      let positiveRotationCount = Int((self.offsetRotation / self.seriesWidth).value)
      if self.remainingRotation >= 0 {
        return  positiveRotationCount      * reciprocity
      } else {
        return (positiveRotationCount - 1) * reciprocity
      }
  }()
  
  
  lazy var remainingRotation: Rotation = {
      return self.offsetRotation % self.seriesWidth
  }()
  
  lazy var wedgesInRemainder: Rotation = {
    return self.remainingRotation / self.wedgeSeperation
  }()
  
  lazy var wedgeIndexClockwise: WedgeIndex = {
    let countOfWedgesInRemainder = WedgeIndex(self.wedgesInRemainder.value)
    if self.remainingRotation >= 0 {
      return countOfWedgesInRemainder + 1
    } else {
      return self.wedgeCount + countOfWedgesInRemainder
    }
  }()
  
  lazy var wedgeIndexCounterClockwise: WedgeIndex = {
    return self.wedgeCount + 1 - self.wedgeIndexClockwise
  }()
  
  lazy var wedgeIndex: WedgeIndex = {
    switch self.direction {
    case .Clockwise:
      return self.wedgeIndexClockwise
    case .CounterClockwise:
      return self.wedgeIndexCounterClockwise
    }
  }()
  
  lazy var wedgeCenter: Rotation = {
    return (self.seriesWidth * self.rotationCount)  +
      (Rotation(self.wedgeSeperation.value) * self.wedgeIndex)
   }()



}



//let state = RotationState(rotation: -27.416,
//                       seriesWidth: Rotation(M_PI * 4),
//                   wedgeSeperation: Angle(quarter),
//                         direction: .CounterClockwise)
//
//state.wedgeIndex
//state.wedgeCount
//state.rotationCount

for i in 0...1000 {
  let ii = (i * 4) - 2000
  let radian = degrees2radians(Double(ii) * quarter - Double(0.0000000))
  let rot = Rotation(radian)

  let wheel = InfiniteImageWheelShape(wedgeCount: 8,
                                 wedgeSeperation: Angle(quarter),
                                       direction: .CounterClockwise)
  
  let state = RotationState(rotation: rot,
                          wheelShape: wheel)

  state.rotation.value
  state.wedgeCenter.value
  state.wedgeIndex
  state.rotationCount

}

result
