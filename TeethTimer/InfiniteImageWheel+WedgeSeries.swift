

extension InfiniteImageWheel {
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
      self.wedgeSeperation = Angle(wedgeSeperation)
      self.visibleAngle    = Angle(visibleAngle)
    }

    init( _ wedgeSeries: WedgeSeries ) {
      self.wedges          = wedgeSeries.wedges
      self.direction       = wedgeSeries.direction
      self.wedgeSeperation = Angle(wedgeSeries.wedgeSeperation)
      self.visibleAngle    = Angle(wedgeSeries.visibleAngle)
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
      return "TODO: impliment description"
    }
  }
}


