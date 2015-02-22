// Playground - noun: a place where people can play

import UIKit



typealias ImageIndex = Int
typealias WedgeValue = Int
enum DirectionToRotate {
    case Clockwise
    case CounterClockwise
    case Closest
}

enum DirectionRotated {
    case Clockwise
    case CounterClockwise
}

enum Parity {
    case Even
    case Odd
}

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

var wedges: [WedgeRegion] = []
for i in 1...6 {
    let w = WedgeRegion(WithMin: 0.0, AndMax: 0.0, AndMid: 0.0, AndValue: i)
    wedges.append(w)
}

func wedgeFromValue(value: Int) -> WedgeRegion {
    
    var returnWedge: WedgeRegion?
    
    for wedge in wedges {
        if wedge.value == value {
            returnWedge = wedge
        }
    }
    
    assert(returnWedge != nil, "wedgeFromValue():  No wedge found with value \(value)")
    return returnWedge!
}

func wedgeForImage(image: ImageIndex) -> WedgeRegion {
    var wedgeValue = image % wedges.count
    if wedgeValue == 0 {
        wedgeValue = wedges.count
    }
    return wedgeFromValue(wedgeValue)
}

func nextWedgeValue(var value: Int) -> Int {
    ++value
    if value > wedges.count {
        value = 1
    }
    return value
}

func previousWedgeValue(var value: Int) -> Int {
    --value
    if value < 1 {
        value = wedges.count
    }
    return value
}

func nextWedge(wedge: WedgeRegion) -> WedgeRegion {
    let value = nextWedgeValue(wedge.value)
    return wedgeFromValue(value)
}

func previousWedge(wedge: WedgeRegion) -> WedgeRegion {
    let value = previousWedgeValue(wedge.value)
    return wedgeFromValue(value)
}

func countFromWedgeValue( fromValue: Int,
    ToWedgeValue toValue: Int,
    inDirection direction: DirectionRotated) -> Int {
        
        var value = fromValue
        var count = 0
        while true {
            if value == toValue {
                break
            }
            if direction == .Clockwise {
                value = nextWedgeValue(value)
            } else {
                value = previousWedgeValue(value)
            }
            ++count
        }
        return count
}



func resolveDirectionAndCountToWedge(wedge: WedgeRegion,
    GivenCurrentWedge currentWedge: WedgeRegion,
    var inDirection direction: DirectionToRotate)
    -> (direction: DirectionToRotate, count: Int) {
        
        let count: Int
        
        switch direction {
        case .Closest:
            let positiveCount = countFromWedgeValue( currentWedge.value,
                ToWedgeValue: wedge.value,
                inDirection: .Clockwise)
            let negitiveCount = countFromWedgeValue( currentWedge.value,
                ToWedgeValue: wedge.value,
                inDirection: .CounterClockwise)
            
            if positiveCount <= negitiveCount {
                count     = positiveCount
                direction = .Clockwise
            } else {
                count     = negitiveCount
                direction = .CounterClockwise
            }
            
        case .Clockwise:
            count = countFromWedgeValue( currentWedge.value,
                ToWedgeValue: wedge.value,
                inDirection: .Clockwise)
            
        case .CounterClockwise:
            count = countFromWedgeValue( currentWedge.value,
                ToWedgeValue: wedge.value,
                inDirection: .CounterClockwise)
        }
        
        return (direction, count)
        
}


func imageForWedge(             wedge: WedgeRegion,
    WhileCurrentImageIs currentImage: ImageIndex) -> ImageIndex {
        
        var currentWedge = wedgeForImage(currentImage)
        let resolved = resolveDirectionAndCountToWedge( wedge,
            GivenCurrentWedge: currentWedge,
            inDirection: .Closest)
        
        var image: ImageIndex
        if resolved.direction == .Clockwise {
            image = currentImage + resolved.count
        } else {
            image = currentImage - resolved.count
        }
        
        if image == 0 {
            image = wedges.count
        }
        
        return image
}

func wedgesI(i:Int) -> WedgeRegion {
        return wedges[i - 1]
}


for i in 1...wedges.count {
    imageForWedge(wedgesI(i),
        WhileCurrentImageIs: 5)
}









