import UIKit

public typealias WedgeIndex = Int

//
//
//public final class InfiniteImageWheel: UIView {
//
//  // Primary Properties
//  public let wedgeSeries:   WedgeSeries
//  public var rotationState: RotationState
//  
//  public var rotation = Rotation(0.0) {
//    didSet {
//      rotationState = RotationState( rotation: rotation,
//                                  wedgeSeries: wedgeSeries)
//      
//    transformWedgesWithRotationState(rotationState)
//    }
//  }
//  
//  // Computed Properties
//  public var wedgeCenter: Rotation {
//    return rotationState.wedgeCenter
//  }
//  
//  
//  // MARK: Initialization
//  public init(imageNames: [String], seperatedByAngle wedgeSeperation: Angle,
//                                        inDirection direction: LayoutDirection ) {
//
//    let wedges = imageNames.map({
//      Wedge(imageName: $0)
//    })
//
//    wedgeSeries = WedgeSeries(wedges: wedges,
//                           direction: direction,
//                     wedgeSeperation: wedgeSeperation,
//                        visibleAngle: Angle(degrees: 90))
//    rotationState = RotationState( rotation: 0.0,
//                      wedgeSeries: wedgeSeries)
//    
//    super.init(frame: CGRect())
//    
//    assert(wedgeSeries.seriesWidth >= Rotation(degrees: 360),
//      "InfiniteImageWheel requires enough images and seperation betwen the wedges to at least make a complete circle.")
//    self.userInteractionEnabled = false
//    rotation = Rotation(0.0)
//  }
//  
//  public convenience init(imageNames: [String], seperatedByAngle wedgeSeperation: Angle ) {
//    self.init(imageNames: imageNames, seperatedByAngle: wedgeSeperation,
//                                           inDirection: .Clockwise)
//  }
//  
//  public required init(coder: NSCoder) {
//    wedgeSeries = WedgeSeries(wedges: [],
//                           direction: .Clockwise,
//                     wedgeSeperation: Angle(0),
//                        visibleAngle: Angle(degrees: 90))
//    
//    rotationState = RotationState( rotation: 0.0,
//                      wedgeSeries: wedgeSeries)
//    
//    super.init(coder: coder)
//    transformWedgesWithRotationState(rotationState)
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//
//  // MARK: UIView Methods
//  public override func didMoveToSuperview() {
//    addSelfContraints()
//    createWedgeImageViews()
//    transformWedgesWithRotationState(rotationState)
//  }
//
//  // MARK: Contraints
//  public func addSelfContraints() {
//    self.setTranslatesAutoresizingMaskIntoConstraints(false)
//    if let superview = self.superview {
//      let viewsDictionary = ["wheel":self]
//      
//      let height:[AnyObject] =
//      NSLayoutConstraint.constraintsWithVisualFormat( "V:|[wheel]|",
//                                             options: NSLayoutFormatOptions(0),
//                                             metrics: nil,
//                                               views: viewsDictionary)
//      
//      let width:[AnyObject] =
//      NSLayoutConstraint.constraintsWithVisualFormat( "H:|[wheel]|",
//                                             options: NSLayoutFormatOptions(0),
//                                             metrics: nil,
//                                               views: viewsDictionary)
//      
//      superview.addConstraints(height)
//      superview.addConstraints(width)
//    }
//  }
//  
//  public func createWedgeImageViews() {
//    if let superview = superview {
//      for wedge in wedgeSeries.wedges {
//        wedge.createWedgeImageViewWithSuperview(superview)
//      }
//    }
//  }
//
//  public func removeWedgeImageViews() {
//    for wedge in wedgeSeries.wedges {
//      wedge.removeWedgeImageView()
//    }
//  }
//
//  
//  
//  
//  
//  
//  
//  public func transformWedgesWithRotationState(rotationState: RotationState) {
//    let state = RotationState(state: rotationState)
////    println("wedgeIndex: \(state.wedgeIndex)")
//    
//    for (index, wedge) in enumerate(wedgeSeries.wedges) {
//      if wedge.viewExists {
//        layoutWedge(wedge, atIndex: index, withRotationState: state)
//      }
//    }
////    println("")
//  }
//  
//  public func layoutWedge(wedge: Wedge, var atIndex index: WedgeIndex,
//                       withRotationState rotationState: RotationState) {
//                        
//    let wedgeState = WedgeState(rotationState: rotationState,
//                                   wedgeIndex: index)
//                        
//                        
////    if wedgeState.distanceToRotation < wedgeSeries.visibleAngle {
//    let i = rotationState.wedgeIndex
//    if i == index || i == wedgeState.nextNeighbor || i == wedgeState.prevNeighbor  {
//      wedge.layoutAngle = wedgeState.layoutAngle
//      wedge.width       = wedgeState.shapeAngle
////      println("\(wedgeState.description)")
//    } else {
//      wedge.hide()
//
//    }
//  }
//
//
////  if state.wedgeIndex == index || (state.wedgeIndex + 1) == index {
//  
//  
//  
//  
//  
//}
//
// Direction Enum
// MARK: Direction Enum
  public enum RotationDirection: String, Printable {
    case Clockwise        = "       Clockwise"
    case CounterClockwise = "CounterClockwise"
    
    public var description: String {
      return self.rawValue
    }
    
    public var asLayoutDirection: LayoutDirection {
      switch self {
        case .Clockwise:
          return .Clockwise
        case .CounterClockwise:
          return .CounterClockwise
      }
    }
  }
  
  public enum LayoutDirection: String, Printable {
    case Clockwise        = "       Clockwise"
    case CounterClockwise = "CounterClockwise"
    
    public var description: String {
      return self.rawValue
    }
    
    public var asRotationDirection: RotationDirection {
      switch self {
      case .Clockwise:
        return .Clockwise
      case .CounterClockwise:
        return .CounterClockwise
      }
    }
  }

