import UIKit

extension InfiniteImageWheel {
  struct RotationState {
    
    let rotation:        Rotation
    let wedgeSeries:     WedgeSeries
    
    
    // MARK:
    // MARK: wedgeCenter rotation for given rotation
    // WedgeIndex is from 0 to (count-of-images - 1)
    var wedgeCenter: Rotation {
      return wedgeCenterForIndex(wedgeIndex)
    }

    // MARK: wedgeIndex for given rotation
    var wedgeIndex: WedgeIndex {
      
      // Calculate the by determining the percentage the current rotation
      // is between the min and max rotations of a series.
      
      // Transform the current rotation to be within a space between:
      //  min: 0.0
      //  max: wedgeSeries.seriesWidth
      let min = minimumRotationWithinWedgeSeries
      let rot: Rotation
      if min < 0 {
        rot = rotation + abs(min)
      } else {
        rot = rotation - abs(min)
      }
      
      // Calc the index based on the percentage
      let percent = percentValue(rot, isBetweenLow: 0,
                                 AndHigh: wedgeSeries.seriesWidth)
      let index   = WedgeIndex(floor(percent * 10))

      // Invert the index if the layout is Clockwise
      switch layoutDirection {
      case .ClockwiseLayout:
        return wedgeMaxIndex - index
      case .CounterClockwiseLayout:
        return index
      }
      
    }
    
    private func percentValue<T:AngularType>(value: T,
      isBetweenLow   low: T,
      AndHigh       high: T ) -> Double {
        return (value.value - low.value) / (high.value - low.value)
    }
    
    
    
    
    
    // MARK:
    // MARK: Properties reletive to wedgeIndex/wedgeCenter.
    
    // The 2nd closest wedgeIndex to rotation.
    var wedgeIndexNeighbor: WedgeIndex {
      switch (directionRotatedOffWedgeCenter,layoutDirection) {
      case (.Clockwise        , .CounterClockwiseLayout):
        return nextNeighbor
      case (.CounterClockwise , .CounterClockwiseLayout):
        return prevNeighbor
        
      case (.Clockwise        , .ClockwiseLayout):
        return prevNeighbor
      case (.CounterClockwise , .ClockwiseLayout):
        return nextNeighbor
      }
    }
    
    // The Angle between the rotation and the center of the current wedge
    var offsetAngleFromWedgeCenter: Angle {
      let angleOffCenter = rotation - wedgeCenter
      return Angle(angleOffCenter)
    }
    
    
    // The direction the wheel is rotated off center of the current wedge
    private var directionRotatedOffWedgeCenter: RotationDirection {
      if rotation > wedgeCenter {
        return .Clockwise
      } else {
        return .CounterClockwise
      }
    }
    
    
    // MARK:
    // MARK: Neighbor Helper Properties/Methods.
    // swift 2-do: add to a protocol with these methods and conform 
    // RotationState & WedgeState to it
    private var nextNeighbor: WedgeIndex {
      return nextIndex(wedgeIndex)
    }
    
    private var prevNeighbor: WedgeIndex {
      return prevIndex(wedgeIndex)
    }
    
    private func nextIndex(index: Int) -> Int {
      var next = index + 1
      if next > wedgeMaxIndex {
        next = 0
      }
      return next
    }
    
    private func prevIndex(index: Int) -> Int {
      var prev = index - 1
      if prev < 0 {
        prev = wedgeMaxIndex
      }
      return prev
    }
    
    
    
    // MARK:
    // MARK: Min and Max Rotations for current wedgeSeries
    var minimumRotationWithinWedgeSeries: Rotation {
      var minimumRotation: Rotation
      switch layoutDirection {
      case .ClockwiseLayout:
        minimumRotation = seriesOriginRotation - seriesWidth
      case .CounterClockwiseLayout:
        minimumRotation = seriesOriginRotation
      }
      minimumRotation += (seriesWidth * wedgeSeriesMultiplier)
      
      let msg = "minimumRotation must be less than rotation"
      assert(minimumRotation <= rotation, msg)
      
      return minimumRotation
    }
    
    var maximumRotationWithinWedgeSeries: Rotation {
      var maximumRotation: Rotation
      switch layoutDirection {
      case .ClockwiseLayout:
        maximumRotation = seriesOriginRotation
      case .CounterClockwiseLayout:
        maximumRotation = seriesOriginRotation + seriesWidth
      }
      maximumRotation += (seriesWidth * wedgeSeriesMultiplier)
      
      let msg = "maximumRotation must be greater than rotation"
      assert(maximumRotation >= rotation, msg)
      
      return maximumRotation
    }

    // MARK: 
    // MARK: wedgeSeries related properties/methods
    // The rotation the first wedgeSeries begins to be laidout from.  Since the
    // first wedge is always centered on a rotation of 0,
    // the first series (wedgeSeriesMultiplier = 0) begins half-a-wedge off
    // in either direction, based on the layout direction.
    private var seriesOriginRotation: Rotation {
      switch layoutDirection {
      case .ClockwiseLayout:
        return Rotation(wedgeSeperation / 2)
      case .CounterClockwiseLayout:
        return Rotation(wedgeSeperation / 2) * -1
      }
    }
    
    
    // This is a count ( + or - ) signifying how many wedgeSeries the wheel has
    // rotated off from the first (origin) series.
    private var wedgeSeriesMultiplier: Int {
      let normalizeRotation = rotation - seriesOriginRotation
      var index = Int(normalizeRotation / seriesWidth)
      
      if rotation > seriesOriginRotation {
        index = index + 1
      }
      
      switch layoutDirection {
      case .ClockwiseLayout:
        return index
      case .CounterClockwiseLayout:
        return index - 1
      }
    }

    // calculate the center of a wedge from any index
    func wedgeCenterForIndex(index: WedgeIndex) -> Rotation {
      let maxIndexMsg = "Index \(index) may not be greater than \(wedgeMaxIndex)"
      assert(index < wedgeSeries.wedgeCount, maxIndexMsg)
      let minIndexMsg = "Index \(index) may not be less than 0"
      assert(index >= 0, maxIndexMsg)
      
      let wedgeSeperation = Rotation(self.wedgeSeperation)
      let distanceWithinSeries = wedgeSeperation * index
      let min = minimumRotationWithinWedgeSeries
      let max = maximumRotationWithinWedgeSeries

      let wedgeCenterForIndex: Rotation
      
      switch layoutDirection {
        
      case .ClockwiseLayout:
        let index0WedgeCenter = max - (wedgeSeperation / 2)
        wedgeCenterForIndex   = index0WedgeCenter - distanceWithinSeries
        
      case .CounterClockwiseLayout:
        let index0WedgeCenter = min + (wedgeSeperation / 2)
        wedgeCenterForIndex   = index0WedgeCenter + distanceWithinSeries
      }
      
      let greaterMsg = "WedgeCenter \(wedgeCenterForIndex) for index \(index) is too low"
      assert(wedgeCenterForIndex > minimumRotationWithinWedgeSeries, greaterMsg)
      let lessMsg = "WedgeCenter \(wedgeCenterForIndex) for index \(index) is too high"
      assert(wedgeCenterForIndex < maximumRotationWithinWedgeSeries, lessMsg)
      
      return wedgeCenterForIndex
    }

    
    // MARK:
    // MARK: wedgeSeries convenience properties.
    private var wedgeCount: Int {
      return wedgeSeries.wedgeCount
    }
    
    private var wedgeMaxIndex: Int {
      return wedgeSeries.wedgeMaxIndex
    }
    
    private var seriesWidth: Rotation {
      return wedgeSeries.seriesWidth
    }
    
    private var wedgeSeperation: Angle {
      return wedgeSeries.wedgeSeperation
    }
    
    private var layoutDirection: LayoutDirection {
      return wedgeSeries.direction
    }
    
  }
}
