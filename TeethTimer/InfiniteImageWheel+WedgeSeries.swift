

extension InfiniteImageWheel {
  
  // These objects describe how images are laidout on the wheel.
  // It is essentail an array of wedge objects. (which contain image urls)
  // It is also describes the angle between each wedge (wedgeSeperation)
  // the direction the images are laid out in (Clockwise vs. Counter Clockwise)
  // and how many wedges should be visiable at any one time,
  // described as visibleAngle.  visibleAngle is largely a optimazation,
  // reducing how many underlying PieSliceLayers new to re-draw their mask.
  
  struct WedgeSeries: Printable {
    let wedges:          [Wedge]
    let direction:       LayoutDirection
    let wedgeSeperation: Angle
    let visibleAngle:    Angle
    
    init(      wedges: [Wedge],
            direction: LayoutDirection,
      wedgeSeperation: Angle,
         visibleAngle: Angle) {
      self.wedges          = wedges
      self.direction       = direction
      self.wedgeSeperation = wedgeSeperation
      self.visibleAngle    = visibleAngle
    }

    init( _ wedgeSeries: WedgeSeries ) {
      self.wedges          = wedgeSeries.wedges
      self.direction       = wedgeSeries.direction
      self.wedgeSeperation = wedgeSeries.wedgeSeperation
      self.visibleAngle    = wedgeSeries.visibleAngle
    }
    
    var wedgeCount: Int {
      return wedges.count
    }
    
    var wedgeMaxIndex: Int {
      return abs(wedges.count - 1)
    }
    
    var seriesWidth: Rotation {
      return Rotation(wedgeSeperation) * wedges.count
    }
    
    var description: String {
      return "\(wedgeCount) wedges, laidout \(direction) with \(wedgeSeperation.degrees)° between each wedge, always filling at least \(visibleAngle.degrees)° of the wheel."
    }
  }
}


