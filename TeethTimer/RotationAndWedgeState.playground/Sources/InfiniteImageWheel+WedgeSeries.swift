

  public struct WedgeSeries: Printable {
    public let wedges:          [Wedge]
    public let direction:       LayoutDirection
    public let wedgeSeperation: Angle
    public let visibleAngle:    Angle
    
    public init(      wedges: [Wedge],
            direction: LayoutDirection,
      wedgeSeperation: Angle,
         visibleAngle: Angle) {
      self.wedges          = wedges
      self.direction       = direction
      self.wedgeSeperation = Angle(wedgeSeperation)
      self.visibleAngle    = Angle(visibleAngle)
    }

    public init( _ wedgeSeries: WedgeSeries ) {
      self.wedges          = wedgeSeries.wedges
      self.direction       = wedgeSeries.direction
      self.wedgeSeperation = Angle(wedgeSeries.wedgeSeperation)
      self.visibleAngle    = Angle(wedgeSeries.visibleAngle)
    }
    
    public var wedgeCount: Int {
      return wedges.count
    }
    
    public var seriesWidth: Rotation {
      return Rotation(wedgeSeperation) * wedges.count
    }
    
    public var seriesStartRotation: Rotation {
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
    
    public var seriesEndRotation: Rotation {
      let result: Rotation
      switch direction {
      case .Clockwise:
        result = seriesStartRotation + seriesWidth
      case .CounterClockwise:
        result = seriesStartRotation - seriesWidth
      }
      return result
    }
    
    
    public func centerOfWedge(index: WedgeIndex,
      usingWedgeSeperation wedgeSeperation: Angle,
      andDirection direction: LayoutDirection) -> Rotation {
        
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
    
    
    public func minOfWedge(index: WedgeIndex,
      usingWedgeSeperation wedgeSeperation: Angle,
      andDirection direction: LayoutDirection) -> Rotation {
        
        let center = centerOfWedge( index,
          usingWedgeSeperation: wedgeSeperation,
          andDirection: direction)
        
        let offset = wedgeSeperation / 2
        return center - offset
    }
    
    
    
    public func maxOfWedge(index: WedgeIndex,
      usingWedgeSeperation wedgeSeperation: Angle,
      andDirection direction: LayoutDirection) -> Rotation {
        
        let center = centerOfWedge( index,
          usingWedgeSeperation: wedgeSeperation,
          andDirection: direction)
        
        let offset = wedgeSeperation / 2
        return center + offset
    }
    
    
    
    
    public var description: String {
      return "impliment description"
    }
  }

