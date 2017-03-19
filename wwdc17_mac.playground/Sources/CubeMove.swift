import Foundation

public struct CubeMove {
    
    // MARK: - Enums
    
    enum FaceType: String {
        case up     = "U"
        case down   = "D"
        case front  = "F"
        case back   = "B"
        case left   = "L"
        case right  = "R"
        
        static var allFaceTypes: [FaceType] {
            return [.up, .down, .front, .back, .left, .right]
        }
        
        static var characterSet: CharacterSet {
            let charactersString = allFaceTypes.reduce("") { (result, faceType) -> String in
                return result + faceType.rawValue
            }
            return CharacterSet(charactersIn: charactersString)
        }
    }
    
    // MARK: - Properties
    
    let faceType: CubeMove.FaceType
    let clockwise: Bool
    var angle: CGFloat {
        return clockwise ? _angle : -_angle
    }
    var moveNotation: String {
        return faceType.rawValue
            + (_angle == CGFloat.pi ? "2" : "")
            + (clockwise ? "" : "'")
    }
    public var reversed: CubeMove {
        let newClockwise = !clockwise
        let moveNotation = faceType.rawValue
            + (_angle == CGFloat.pi ? "2" : "")
            + (newClockwise ? "" : "'")
        print(moveNotation)
        return CubeMove(moveNotation: moveNotation)!
    }
    public var animationDuration: Double
    public var animationDelay: Double
    
    fileprivate let _angle: CGFloat
    fileprivate let scanner: Scanner
    fileprivate static let defaultAnimationDuration: Double = 0.3
    fileprivate static let defaultAnimationDelay: Double = 0.1
    
    // MARK: - Initialization
    
    public init?(moveNotation: String) {
        scanner = Scanner(string: moveNotation)
        var faceNSString: NSString? = ""
        guard scanner.scanCharacters(from: FaceType.characterSet, into: &faceNSString),
            let faceString = faceNSString as? String,
            let faceType = FaceType(rawValue: faceString) else { return nil }
        self.faceType = faceType
        var int: Int = 0
        if scanner.scanInt(&int), int == 2 {
            _angle = CGFloat.pi
        } else {
            _angle = CGFloat.pi / 2
        }
        clockwise = !scanner.scanString("'", into: nil)
        self.animationDuration = CubeMove.defaultAnimationDuration
        self.animationDelay = CubeMove.defaultAnimationDelay
    }
    
    public init?(moveNotation: String, animationDuration: Double, animationDelay: Double) {
        self.init(moveNotation: moveNotation)
        self.animationDuration = animationDuration
        self.animationDelay = animationDelay
    }
    
}

extension CubeMove: CustomDebugStringConvertible {
    public var debugDescription: String {
        return moveNotation
    }
}

extension CubeMove: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return PlaygroundQuickLook(reflecting: moveNotation)
    }
}

extension CubeMove {
    
    static func randomMoves(withNumber number: Int) -> [CubeMove] {
        return (0..<number).map{ _ in return randomMove() }
    }
    
    fileprivate static func randomMove() -> CubeMove {
        let randomInt = arc4random_uniform(UInt32(FaceType.allFaceTypes.count))
        let randomNotation_faceType = FaceType.allFaceTypes[Int(randomInt)].rawValue
        let randomNotation_angle = arc4random_uniform(1) == 0 ? "" : "2"
        let randomNotation_reverse = arc4random_uniform(1) == 1 ? "'" : ""
        let randomNotation = randomNotation_faceType +
                            randomNotation_angle +
                            randomNotation_reverse
        return CubeMove(moveNotation: randomNotation)!
    }
    
}
