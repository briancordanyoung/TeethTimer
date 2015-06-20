import UIKit

typealias WedgeIndex = Int



final class InfiniteImageWheel: UIView {

  // Primary Properties
  let wedgeSeries:   WedgeSeries
  var rotationState: RotationState
  
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
  init(imageNames: [String], seperatedByAngle wedgeSeperation: Angle ) {
    // Gavin Poses-s01
    let wedges = imageNames.map({Wedge(imageName: $0)})
    let tao = M_PI * 2
    wedgeSeries = WedgeSeries(wedges: wedges,
                           direction: .Clockwise,
                     wedgeSeperation: wedgeSeperation,
                        visibleAngle: Angle(degrees: 90))
    rotationState = RotationState( rotation: 0.0,
                      wedgeSeries: wedgeSeries)
    
    super.init(frame: CGRect())
    
    assert(wedgeSeries.seriesWidth >= Rotation(degrees: 360),"InfiniteImageWheel requires enough images and seperation betwen the wedges to at least make a complete circle.")
    self.userInteractionEnabled = false
    rotation = Rotation(0.0)
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
        transformWedge(wedge, atIndex: index, withRotationState: state)
      }
    }
  }
  
  
  func transformWedge(wedge: Wedge, atIndex index: WedgeIndex,
                          withRotationState state: RotationState) {
    
    let steps = countFromIndex( index, toIndex: state.wedgeIndex,
                                   withinSteps: state.wedgeCount)
    let distanceOnCenter: Rotation
    let direction: Direction
                            
    if steps.clockwise < steps.counterClockwise {
      direction = .Clockwise
      distanceOnCenter = Rotation(state.wedgeSeperation) * steps.clockwise
    } else {
      direction = .CounterClockwise
      distanceOnCenter = Rotation(state.wedgeSeperation) * steps.counterClockwise
    }
                            
    let distance: Rotation
    let angle:    Angle
    let width:    Angle// = Angle(degrees: 90)

    let msg: String
    switch direction {
    case .Clockwise:
      let offcenter = angleOffCenterFromDirection( direction,
                                 forRotationState: state)
      distance = distanceOnCenter + offcenter
      angle = Angle(state.wedgeCenter - distanceOnCenter)
      
      let percent = 1 - percentOfWidth(Angle(distance), forState: state)
      width = (state.wedgeSeperation * 2) * Angle(percent)
    case .CounterClockwise:
      let offcenter = angleOffCenterFromDirection( direction,
                                 forRotationState: state)
      distance = distanceOnCenter + offcenter
      angle = Angle(state.wedgeCenter + distanceOnCenter)

      
      let percent = 1 - percentOfWidth(Angle(distance), forState: state)
      width = (state.wedgeSeperation * 2) * Angle(percent)
    }
                            
    if distance < wedgeSeries.halfVisibleAngle {
      wedge.transform(angle)
      wedge.width = width
    } else {
      wedge.hide()
    }
  }

  
  func angleOffCenterFromDirection(direction: Direction,
                    forRotationState state: RotationState) -> Angle {
                      
      let angleOffCenter = state.rotation - state.wedgeCenter
    
      switch direction {
      case .Clockwise:
          return Angle(angleOffCenter)
      case .CounterClockwise:
        return Angle(angleOffCenter * -1)
    }
  }
  
  
  func countFromIndex( start: WedgeIndex, toIndex end: WedgeIndex,
                                    withinSteps steps: WedgeIndex)
                       -> (clockwise: WedgeIndex, counterClockwise: WedgeIndex) {
      
    let clockwise = countFromIndex( start, toIndex: end,
                                       withinSteps: steps,
                                       inDirection: .Clockwise)
                              
    let counterClockwise = countFromIndex( start, toIndex: end,
                                              withinSteps: steps,
                                              inDirection: .CounterClockwise)
      
    return (clockwise: clockwise, counterClockwise: counterClockwise)
  }
  
  
  func countFromIndex( start: WedgeIndex, toIndex end: WedgeIndex,
                                    withinSteps steps: WedgeIndex,
                                inDirection direction: Direction) -> WedgeIndex {
      var increment: (int: Int) -> Int
      var compare:   (lhs: Int, rhs: Int)  -> Bool
      var wrapTo:     WedgeIndex
      var wrapAt:     WedgeIndex

      switch direction {
      case .Clockwise:
        increment = add
        compare   = more
        wrapTo    = 1
        wrapAt    = steps
      case .CounterClockwise:
        increment = subtract
        compare   = less
        wrapTo    = steps
        wrapAt    = 1
      }

      var count = 0
      var next  = start
      while next != end {
        count = count + 1
        next  = increment(int: next)
        if compare(lhs: next, rhs: wrapAt)  {
          next = wrapTo
        }
      }
      return count
  }


  func add(int: Int) -> Int {
    return int + 1
  }
  func subtract(int: Int) -> Int {
    return int - 1
  }
  func less(lhs: Int, rhs: Int) -> Bool {
    return lhs < rhs
  }
  func more(lhs: Int, rhs: Int) -> Bool {
    return lhs > rhs
  }
  
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
  enum Direction: String, Printable {
    case Clockwise        = "Clockwise"
    case CounterClockwise = "CounterClockwise"
    
    var description: String {
      return self.rawValue
    }
  }
}
