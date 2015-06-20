

extension InfiniteImageWheel {
  struct WedgeSeries: Printable {
    let wedges:          [Wedge]
    let direction:       Direction
    let wedgeSeperation: Angle
    let visibleAngle:    Angle
    
    var wedgeCount: Int {
      return wedges.count
    }
    
    var halfVisibleAngle: Angle {
      return visibleAngle
    }
    
    var seriesWidth: Rotation {
      return Rotation(wedgeSeperation) * wedges.count
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
    
    
    
    
    var description: String {
      return "TODO: impliment me"
    }
  }
}
