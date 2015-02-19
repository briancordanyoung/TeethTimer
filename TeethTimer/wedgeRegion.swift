import CoreGraphics

typealias WedgeValue = Int

struct WedgeRegion {
    var minRadian: CGFloat
    var maxRadian: CGFloat
    var midRadian: CGFloat
    var value: WedgeValue
    
    init(WithMin min: CGFloat,
          AndMax max: CGFloat,
          AndMid mid: CGFloat,
    AndValue valueIn: Int) {
        minRadian = min
        maxRadian = max
        midRadian = mid
        value = valueIn
    }
    
    func description() -> String {
        return "\(value) | \(minRadian), \(midRadian), \(maxRadian)"
    }
}