import UIKit

typealias WedgeIndex = Int


final class InfiniteImageWheel: UIView {

  
  
  var rotation = Rotation(0.0) {
    didSet {
//      updateAppearanceForRotation(rotation)
    }
  }
  
  var layoutDirection: Direction = .Clockwise
  
}




// MARK: - Various enums and structs used throughout the InfiniteImageWheel Class
extension InfiniteImageWheel {
  
  struct Wedge: Printable {
  
    let center:   Rotation
    let width:    Angle
    let view:     WedgeImageView
    let imageURL: NSURL
    
    
    var description: String {
      return "TODO: impliment me"
    }
  }

  struct ImageWedgeSeries: Printable {
    let wedges:      [Wedge]
    let direction:   Direction
    let seriesWidth: Rotation
    
    var wedgeSeperation: Angle {
      let wedgeWidth = seriesWidth.cgRadians / CGFloat(wedges.count)
      return Angle(wedgeWidth)
    }
    
    var seriesStartRotation: Rotation {
      let offset = Rotation(wedgeSeperation) / 2
      let result: Rotation
      switch direction {
        case .Clockwise:
          result = -offset
        case .CounterClockwise:
          result =  offset
      }
      return result
    }
    
    var seriesEndRotation: Rotation {
      let result: Rotation
      switch direction {
      case .Clockwise:
        result = seriesStartRotation + seriesWidth
      case .CounterClockwise:
        result = seriesStartRotation - seriesWidth
      }
      return result
    }
    
    func centerOfWedge(index: WedgeIndex,
            usingWedgeSeperation wedgeSeperation: Angle,
                        andDirection direction: Direction) -> Rotation {
      
      let stepsToWedge = index - 1
      let distanceFromFirstWedge = Rotation(wedgeSeperation) * stepsToWedge
                          
      let result: Rotation
      switch direction {
      case .Clockwise:
        result =  distanceFromFirstWedge
      case .CounterClockwise:
        result = -distanceFromFirstWedge
      }
      return result
    }
    
    
    func minOfWedge(index: WedgeIndex,
      usingWedgeSeperation wedgeSeperation: Angle,
                    andDirection direction: Direction) -> Rotation {
        
        let center = centerOfWedge( index,
              usingWedgeSeperation: wedgeSeperation,
                      andDirection: direction)
        
        let offset = wedgeSeperation / 2
        return center - offset
    }

    
    
    func maxOfWedge(index: WedgeIndex,
      usingWedgeSeperation wedgeSeperation: Angle,
                    andDirection direction: Direction) -> Rotation {
        
        let center = centerOfWedge( index,
              usingWedgeSeperation: wedgeSeperation,
                      andDirection: direction)
        
        let offset = wedgeSeperation / 2
        return center + offset
    }

    func wedgeIndexForRotation(rotation: Rotation,
           usingSeriesWidth seriesWidth: Rotation,
                        wedgeSeperation: Angle,
                 andDirection direction: Direction) -> WedgeIndex {
        
        let steps = WedgeIndex((seriesWidth / wedgeSeperation).value)
        
        let remainingRotation: Rotation
        switch direction {
        case .Clockwise:
          let offsetRotation    = rotation + wedgeSeperation
          remainingRotation = offsetRotation % seriesWidth
          
        case .CounterClockwise:
          let offsetRotation    = rotation - wedgeSeperation
          remainingRotation = offsetRotation % seriesWidth
        }
        
        let result: WedgeIndex
        
        if remainingRotation >= 0 {
          let wedgesInRemainder = remainingRotation / wedgeSeperation
          result = WedgeIndex(wedgesInRemainder.value) + 1
        } else {
          let wedgesInRemainder = remainingRotation / wedgeSeperation
          result =  steps + WedgeIndex(wedgesInRemainder.value)
        }
        
        return result
    }
    

    
    
    
    
    var description: String {
      return ""
    }
  }
}



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
  private lazy var offsetRotation: Rotation = {
    switch self.direction {
    case .Clockwise:
      return self.rotation + (self.wedgeSeperation / 2)
    case .CounterClockwise:
      return self.rotation - (self.wedgeSeperation / 2)
    }
  }()
  
  
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
