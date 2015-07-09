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
  init(imageNames: [String], seperatedByAngle wedgeSeperation: Angle,
                                        inDirection direction: LayoutDirection ) {

    let wedges = imageNames.map({
      Wedge(imageName: $0)
    })

    wedgeSeries = WedgeSeries(wedges: wedges,
                           direction: direction,
                     wedgeSeperation: wedgeSeperation,
                        visibleAngle: Angle(degrees: 180))
                                          
    rotationState = RotationState( rotation: 0.0,
                      wedgeSeries: wedgeSeries)
    
    super.init(frame: CGRect())
    
    assert(wedgeSeries.seriesWidth >= Rotation(degrees: 360),
      "InfiniteImageWheel requires enough images and seperation between the wedges to at least make a complete circle.")
    self.userInteractionEnabled = false
    rotation = Rotation(0.0)
  }
  
  convenience init(imageNames: [String], seperatedByAngle wedgeSeperation: Angle ) {
    self.init(imageNames: imageNames, seperatedByAngle: wedgeSeperation,
                                           inDirection: .ClockwiseLayout)
  }
  
  required init(coder: NSCoder) {
    // TODO: impliment coder and decoder
    wedgeSeries = WedgeSeries(wedges: [],
                           direction: .ClockwiseLayout,
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
      }
    }
  }
  
  func layoutWedge(wedge: Wedge, atIndex index: WedgeIndex,
                       withRotationState rotationState: RotationState) {
                        
    let wedgeState = WedgeState(rotationState: rotationState,
                                   wedgeIndex: index)
                        
    if wedgeState.laidoutIndex == rotationState.wedgeIndex         ||
       wedgeState.laidoutIndex == rotationState.wedgeIndexNeighbor   {
        
      wedge.layoutAngle = wedgeState.layoutAngle
//      wedge.width       = wedgeState.shapeAngle
    } else {
      wedge.hide()
    }
  }
  
  
  
  
}

// Direction Enum
// MARK: Direction Enum
extension InfiniteImageWheel {
  enum RotationDirection: String, Printable {
    case Clockwise        = "       Clockwise Rotation"
    case CounterClockwise = "CounterClockwise Rotation"
    
    var description: String {
      return self.rawValue
    }
    
    var asLayoutDirection: LayoutDirection {
      switch self {
        case .Clockwise:
          return .ClockwiseLayout
        case .CounterClockwise:
          return .CounterClockwiseLayout
      }
    }
  }
  
  enum LayoutDirection: String, Printable {
    case ClockwiseLayout        = "       Clockwise Layout"
    case CounterClockwiseLayout = "CounterClockwise Layout"
    
    var description: String {
      return self.rawValue
    }
    
    var asRotationDirection: RotationDirection {
      switch self {
      case .ClockwiseLayout:
        return .Clockwise
      case .CounterClockwiseLayout:
        return .CounterClockwise
      }
    }
  }

}
