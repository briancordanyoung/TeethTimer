
struct WedgeRegion {
    var minRadian: Float
    var maxRadian: Float
    var midRadian: Float
    var value: Int
    
    init(WithMin min: Float, AndMax max: Float, AndMid mid: Float, AndValue valueIn: Int) {
        minRadian = min
        maxRadian = max
        midRadian = mid
        value = valueIn
    }
    
    func description() -> String {
        return "\(value) | \(minRadian), \(midRadian), \(maxRadian)"
    }
}