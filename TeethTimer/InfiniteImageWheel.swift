import UIKit

typealias WedgeIndex = Int



final class InfiniteImageWheel: UIView {

  // Primary Properties
  let wedgeSeries:   WedgeSeries
  var rotationState: RotationState
  let f = NSNumberFormatter()
  let f2 = NSNumberFormatter()
  var printDebug = false
  
  var rotation = Rotation(0.0) {
    didSet {
      rotationState = RotationState( rotation: rotation,
                                  wedgeSeries: wedgeSeries)
    transformWedgesWithRotationState(rotationState)
    }
  }
  
  // Computed Properties
  var wedgeCenter: Rotation {
    return rotationState.wedgeCenter
  }
  
  
  // MARK: Initialization
  init(imageNames: [String], seperatedByAngle wedgeSeperation: Angle,
                                        inDirection direction: LayoutDirection ) {

    let wedges = imageNames.map({Wedge(imageName: $0)})

    wedgeSeries = WedgeSeries(wedges: wedges,
                           direction: direction,
                     wedgeSeperation: wedgeSeperation,
                        visibleAngle: Angle(degrees:  90))
    rotationState = RotationState( rotation: 0.0,
                      wedgeSeries: wedgeSeries)
    
    super.init(frame: CGRect())
    
    assert(wedgeSeries.seriesWidth >= Rotation(degrees: 360),
      "InfiniteImageWheel requires enough images and seperation betwen the wedges to at least make a complete circle.")
    self.userInteractionEnabled = false
    rotation = Rotation(0.0)
                                          
    f.minimumIntegerDigits  = 3
    f.maximumIntegerDigits  = 3
    f.minimumFractionDigits = 3
    f.maximumFractionDigits = 3
    f.positivePrefix = " "
    f.negativePrefix = "-"
    f.paddingCharacter = " "
    f2.minimumIntegerDigits  = 2
    f2.maximumIntegerDigits  = 2
    f2.minimumFractionDigits = 0
    f2.maximumFractionDigits = 0
    f2.positivePrefix = ""
    f2.negativePrefix = ""
    f2.paddingCharacter = " "
  }

  func pad(number: Double) -> String {
    return f.stringFromNumber(number)!
  }
  
  func pad(number: Rotation) -> String {
    return pad(number.value)
  }
  
  func pad(number: Angle) -> String {
    return pad(number.value)
  }
  
  func pad2(number: Double) -> String {
    return f2.stringFromNumber(number)!
  }

  func p2(number: Int) -> String {
    return pad2(Double(number))
  }
  
  func pad2(number: Rotation) -> String {
    return pad2(number.value)
  }
  
  func pad2(number: Angle) -> String {
    return pad2(number.value)
  }
  
  convenience init(imageNames: [String], seperatedByAngle wedgeSeperation: Angle ) {
    self.init(imageNames: imageNames, seperatedByAngle: wedgeSeperation,
                                           inDirection: .Clockwise)
  }
  
  required init(coder: NSCoder) {
    // TODO: impliment coder and decoder
    wedgeSeries = WedgeSeries(wedges: [],
                           direction: .Clockwise,
                     wedgeSeperation: Angle(0),
                        visibleAngle: Angle(degrees: 180))
    
    rotationState = RotationState( rotation: 0.0,
                      wedgeSeries: wedgeSeries)
    
    super.init(coder: coder)
    transformWedgesWithRotationState(rotationState)
    fatalError("init(coder:) has not been implemented")
  }
  

  // MARK: UIView Methods
  override func didMoveToSuperview() {
    addSelfContraints()
    createWedgeImageViews()
    transformWedgesWithRotationState(rotationState)
  }

  // MARK: Contraints
  func addSelfContraints() {
    self.setTranslatesAutoresizingMaskIntoConstraints(false)
    if let superview = self.superview {
      let viewsDictionary = ["wheel":self]
      
      let height:[AnyObject] =
      NSLayoutConstraint.constraintsWithVisualFormat( "V:|[wheel]|",
                                             options: NSLayoutFormatOptions(0),
                                             metrics: nil,
                                               views: viewsDictionary)
      
      let width:[AnyObject] =
      NSLayoutConstraint.constraintsWithVisualFormat( "H:|[wheel]|",
                                             options: NSLayoutFormatOptions(0),
                                             metrics: nil,
                                               views: viewsDictionary)
      
      superview.addConstraints(height)
      superview.addConstraints(width)
    }
  }
  
  func createWedgeImageViews() {
    if let superview = superview {
      for wedge in wedgeSeries.wedges {
        wedge.createWedgeImageViewWithSuperview(superview)
      }
    }
  }

  func removeWedgeImageViews() {
    for wedge in wedgeSeries.wedges {
      wedge.removeWedgeImageView()
    }
  }

  
  
  
  
  
  
  func transformWedgesWithRotationState(rotationState: RotationState) {
    let state = RotationState(state: rotationState)
    for (index, wedge) in enumerate(wedgeSeries.wedges) {
      if wedge.viewExists {
        layoutWedge(wedge, atIndex: index, withRotationState: state)
//        transformWedge(wedge, atIndex: index, withRotationState: state)
      }
    }
    if printDebug { println("") }

  }
  
  
  func layoutWedge(wedge: Wedge, atIndex index: WedgeIndex,
                       withRotationState state: RotationState) {
        
    let steps = countFromIndex( index, toIndex: state.wedgeIndex,
                                   withinSteps: state.wedgeCount)
                        
    let direction: RotationDirection
    let stepCount: Int
    
    if steps.clockwise < steps.counterClockwise {
      direction = .Clockwise
      stepCount = steps.clockwise
    } else {
      direction = .CounterClockwise
      stepCount = steps.counterClockwise
    }
    
    let distanceOnCenter = Rotation(state.wedgeSeperation) * stepCount
                        
    let angle = layoutAngleAddingRotation( distanceOnCenter,
                                  toAngle: state.wedgeCenter,
                              inDirection: direction)

    let offcenter =
            state.angleOffCenterFromLayoutDirection(direction.asLayoutDirection)
    let layoutDistanceFromCurrentRotation = abs(distanceOnCenter + offcenter)
                        
                        let tmpOffcenter = "\(offcenter.degrees)"
                        let tmplayoutRotation = "\(state.layoutRotation.degrees)"
                        let tmpwedgeCenter = "\(state.wedgeCenter.degrees)"
                        
    let msg = "\(p2(index + 1)) steps \(p2(stepCount)) \(pad(layoutDistanceFromCurrentRotation.degrees)) \(pad(distanceOnCenter.degrees)) <\(state.layoutRotation.degrees) - \(tmpwedgeCenter) = \(offcenter.degrees) @ \(state.rotationCount)> | Current Wedge: \(p2(state.wedgeIndex + 1))"

    if layoutDistanceFromCurrentRotation < wedgeSeries.halfVisibleAngle {
      wedge.transform(angle)
      if printDebug { println("Show Wedge \(msg)") }
    } else {
      wedge.hide()
      if printDebug { println("Hide Wedge \(msg)") }
    }
  }

  
  
  
  func layoutAngleAddingRotation(distance: Rotation,
                            toAngle angle: Rotation,
                    inDirection direction: RotationDirection) -> Angle {
    
    let returnAngle: Angle
    switch direction {
    case .Clockwise:
      returnAngle = Angle(angle - distance)
      
    case .CounterClockwise:
      returnAngle = Angle(angle + distance)
    }
    
    return returnAngle
     
  }

  
  
  func countFromIndex( start: WedgeIndex, toIndex
                         end: WedgeIndex,
           withinSteps steps: Int)
                       -> (clockwise: WedgeIndex, counterClockwise: WedgeIndex) {
      
    assert(end < steps, "steps should be 1 more than the maximum end index")
    let clockwise = countFromIndexClockwise( start,
                                    toIndex: end,
                                withinSteps: steps)
                              
    let counterClockwise = countFromIndexCounterClockwise( start,
                                                  toIndex: end,
                                              withinSteps: steps)
    
    return (       clockwise: clockwise,
            counterClockwise: counterClockwise)
  }

  
  
  func countFromIndexClockwise( start: WedgeIndex,
                          toIndex end: WedgeIndex,
                    withinSteps steps: Int) -> WedgeIndex {
      var count = 0
      var next  = start
      while next != end {
        count++
        next++
        if next > (steps - 1)  {
          next = 0
        }
        assert(count < steps, "countFromIndex is stuck in a while loop")
      }
      return count
  }
  
  func countFromIndexCounterClockwise( start: WedgeIndex,
                                 toIndex end: WedgeIndex,
                           withinSteps steps: Int) -> WedgeIndex {
      var count = 0
      var next  = start
      while next != end {
        count++
        next--
        if next < 0  {
          next = (steps - 1)
        }
        assert(count < steps, "countFromIndex is stuck in a while loop")
      }
      return count
  }
  
  
  
  
  
  
  
  
//  
//  func transformWedge(wedge: Wedge, atIndex index: WedgeIndex,
//                          withRotationState state: RotationState) {
//    
//    let steps = countFromIndex( index, toIndex: state.wedgeIndex,
//                                   withinSteps: state.wedgeCount)
//    let distanceOnCenter: Rotation
//    let direction: RotationDirection
//    let stepCount: Int
//                            
//    if steps.clockwise < steps.counterClockwise {
//      direction = .Clockwise
//      stepCount = steps.clockwise
//      distanceOnCenter = Rotation(state.wedgeSeperation) * stepCount
//    } else {
//      direction = .CounterClockwise
//      stepCount = steps.counterClockwise
//      distanceOnCenter = Rotation(state.wedgeSeperation) * stepCount
//    }
//                            
//    let distance: Rotation
//    let angle:    Angle
//    let width:    Angle
//
//    switch direction {
//    case .Clockwise:
//      let offcenter = angleOffCenterFromDirection( direction,
//                                 forRotationState: state)
//      distance = distanceOnCenter + offcenter
//      angle = Angle(state.wedgeCenter - distanceOnCenter)
//
////      let percent = 1 - percentOfWidth(Angle(distance), forState: state)
////      width = (state.wedgeSeperation * 2) * Angle(percent)
//      
//    case .CounterClockwise:
//      let offcenter = angleOffCenterFromDirection( direction,
//                                 forRotationState: state)
//      distance = distanceOnCenter + offcenter
//        angle = Angle(state.wedgeCenter + distanceOnCenter)
//      
////      let percent = 1 - percentOfWidth(Angle(distance), forState: state)
////      width = (state.wedgeSeperation * 2) * Angle(percent)
//    }
//                            
//   if abs(distance) < wedgeSeries.halfVisibleAngle {
//      wedge.transform(angle)
//    println("wedge \(index + 1) state.wedge \(state.wedgeIndex + 1)")
////      wedge.width = width
//    } else {
//      wedge.hide()
//    }
//  }
//
//  // TODO: Move to an extention of RotationState
//  func angleOffCenterFromDirection(direction: LayoutDirection,
//                      forRotationState state: RotationState) -> Angle {
//                      
//      let angleOffCenter = state.layoutRotation - state.wedgeCenter
//    
//      switch direction {
//      case .Clockwise:
//        return Angle(angleOffCenter)
//      case .CounterClockwise:
//        return Angle(angleOffCenter * -1)
//    }
//  }
//  
  
//  func countFromIndex( start: WedgeIndex, toIndex end: WedgeIndex,
//                                    withinSteps steps: WedgeIndex)
//                       -> (clockwise: WedgeIndex, counterClockwise: WedgeIndex) {
//      
//    let clockwise = countFromIndex( start, toIndex: end,
//                                       withinSteps: steps,
//                                       inDirection: .Clockwise)
//                              
//    let counterClockwise = countFromIndex( start, toIndex: end,
//                                              withinSteps: steps,
//                                              inDirection: .CounterClockwise)
//    
//    return (clockwise: clockwise, counterClockwise: counterClockwise)
//  }
//  func countFromIndex( start: WedgeIndex, toIndex end: WedgeIndex,
//                                    withinSteps steps: WedgeIndex,
//                                inDirection direction: LayoutDirection) -> WedgeIndex {
//      var increment:  (int: Int) -> Int
//      var shouldWrap: (lhs: Int, rhs: Int)  -> Bool
//      var wrapTo:     WedgeIndex
//      var wrapAt:     WedgeIndex
//
//      switch direction {
//      case .Clockwise:
//        increment  = add
//        shouldWrap = more
//        wrapTo     = 0
//        wrapAt     = steps - 1
//      case .CounterClockwise:
//        increment  = subtract
//        shouldWrap = less
//        wrapTo     = steps - 1
//        wrapAt     = 0
//      }
//
//      var count = 0
//      var next  = start
//      while next != end {
//        count++
//        next  = increment(int: next)
//        if shouldWrap(lhs: next, rhs: wrapAt)  {
//          next = wrapTo
//        }
//        assert(count < steps, "countFromIndex is stuck in a while loop")
//      }
//      return count
//  }
//
//
//  func add(int: Int) -> Int {
//    return int + 1
//  }
//  func subtract(int: Int) -> Int {
//    return int - 1
//  }
//  func less(lhs: Int, rhs: Int) -> Bool {
//    return lhs < rhs
//  }
//  func more(lhs: Int, rhs: Int) -> Bool {
//    return lhs > rhs
//  }
  
  func percentOfWidth(value: Angle, forState state: RotationState) -> Double {
    let absoluteValue = Angle(abs(value.value))
    return percentValue(value, isBetweenLow: Angle(0),
                                    AndHigh: state.wedgeSeperation)
  }
  
  func percentValue<T:AngularType>(value: T,
                      isBetweenLow   low: T,
                      AndHigh       high: T ) -> Double {
      return (value.value - low.value) / (high.value - low.value)
  }

}

// Direction Enum
// MARK: Direction Enum
extension InfiniteImageWheel {
  enum RotationDirection: String, Printable {
    case Clockwise        = "       Clockwise"
    case CounterClockwise = "CounterClockwise"
    
    var description: String {
      return self.rawValue
    }
    
    var asLayoutDirection: LayoutDirection {
      switch self {
        case .Clockwise:
          return .Clockwise
        case .CounterClockwise:
          return .CounterClockwise
      }
    }
  }
  
  enum LayoutDirection: String, Printable {
    case Clockwise        = "       Clockwise"
    case CounterClockwise = "CounterClockwise"
    
    var description: String {
      return self.rawValue
    }
    
    var asRotationDirection: RotationDirection {
      switch self {
      case .Clockwise:
        return .Clockwise
      case .CounterClockwise:
        return .CounterClockwise
      }
    }
  }

}
