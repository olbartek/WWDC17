import SceneKit

fileprivate struct Material {
    static func material(withColor color: NSColor) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.diffuse.wrapS = .clampToBorder
        mat.diffuse.wrapT = .clampToBorder
        mat.specular.contents = NSColor.white
        return mat
    }
    
    static let green = material(withColor: .green)
    static let red = material(withColor: .red)
    static let blue = material(withColor: .blue)
    static let orange = material(withColor: .orange)
    static let white = material(withColor: .white)
    static let yellow = material(withColor: .yellow)
    static let black = material(withColor: .black)
}

public class RubiksCube: SCNNode {
    
    // MARK: - Properties
    
    let cubeWidth: Float = 0.95
    let spaceBetweenCubes: Float = 0.05

    public weak var scene: SCNScene?
    
    fileprivate var cubeOffsetDistance: Float {
        return (cubeWidth + spaceBetweenCubes) / 2
    }
    fileprivate var cubelets: [SCNNode] = []
    
    // MARK: - Initialization
    
    override public init() {
        super.init()
        
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    let box = SCNBox()
                    box.chamferRadius = 0.1
                    box.materials = [
                        z == 1 ? Material.green : Material.black,
                        x == 1 ? Material.red : Material.black,
                        z == -1 ? Material.blue : Material.black,
                        x == -1 ? Material.orange : Material.black,
                        y == 1 ? Material.white : Material.black,
                        y == -1 ? Material.yellow : Material.black,
                    ]
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
                    addChildNode(node)
                    cubelets += [node]
                }
            }
        }
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public extension RubiksCube {
    
    fileprivate func animateMove(_ move: CubeMove) {
        guard let scene = scene else { return }
        print("Animate move started " + move.moveNotation)
        let rotateNode = SCNNode()
        scene.rootNode.addChildNode(rotateNode)
        
        let comparisonClosure: (_ node: SCNNode) -> Bool = { node in
            let position: CGFloat
            let offset: CGFloat
            switch move.faceType {
            case .up:
                position = node.position.y
                offset = 1
            case .down:
                position = node.position.y
                offset = -1
            case .back:
                position = node.position.z
                offset = -1
            case .front:
                position = node.position.z
                offset = 1
            case .left:
                position = node.position.x
                offset = -1
            case .right:
                position = node.position.x
                offset = 1
            }
            return abs(position - offset) < 0.001
        }
        
        let cubeletsToAnimate = cubelets.filter { node in
            return comparisonClosure(node)
        }
        _ = cubeletsToAnimate.map { rotateNode.addChildNode($0) }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = move.animationDuration
        
        switch move.faceType {
        case .left, .right:
            rotateNode.eulerAngles.x += move.angle
        case .up, .down:
            rotateNode.eulerAngles.y += move.angle
        case .front, .back:
            rotateNode.eulerAngles.z += move.angle
        }
        
        SCNTransaction.completionBlock = {
            rotateNode.enumerateChildNodes { cubelet, _ in
                cubelet.transform = cubelet.worldTransform
                cubelet.removeFromParentNode()
                scene.rootNode.addChildNode(cubelet)
            }
            rotateNode.removeFromParentNode()
            print("Animate move finished " + move.moveNotation)
        }
        SCNTransaction.commit()
    }
    
    func animateMoveString(_ moveNotation: String) {
        guard let cubeMove = CubeMove(moveNotation: moveNotation) else { return }
        animateMove(cubeMove)
    }
    
    public func animateMoves(_ moves: [CubeMove]) {
        for (index, move) in moves.enumerated() {
            perform(#selector(animateMoveString(_:)), with: move.moveNotation, afterDelay: TimeInterval(Double(index) * (move.animationDuration + move.animationDelay)))
        }
    }
    
}
