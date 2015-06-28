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

    let wedges = imageNames.map({
      Wedge(imageName: $0)
    })

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
                        visibleAngle: Angle(degrees: 90))
    
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
      }
    }
    if printDebug { println("") }

  }
  
  func layoutWedge(wedge: Wedge, var atIndex index: WedgeIndex,
                       withRotationState rotationState: RotationState) {
                        
    let wedgeState = WedgeState(rotationState: rotationState,
                                   wedgeIndex: index)
    if wedgeState.distanceToRotation < wedgeSeries.halfVisibleAngle {
      wedge.layoutAngle = wedgeState.layoutAngle
      wedge.width       = wedgeState.shapeAngle

      if printDebug {
        println("W: \(p2(index)) dist: \(pad(wedgeState.distanceToRotation)) vis angle \(pad(wedgeState.shapeAngle.degrees))")
      }
    
    } else {
      wedge.hide()

      if printDebug {
        println("w: \(p2(index)) dist: \(pad(wedgeState.distanceToRotation)) vis angle \(pad(wedgeState.shapeAngle.degrees))")
      }
      
    }
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
