import SceneKit

fileprivate struct Material {
    static func material(withColor color: NSColor) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = color
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

    public weak var scene: SCNScene?
    
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

extension RubiksCube {
    
    public func animateRotateMoves(_ moves: [CubeMove], scene: SCNScene) {
        let rotateNode = SCNNode()
        scene.rootNode.addChildNode(rotateNode)
        
        var actions: [SCNAction] = []
        for move in moves {
            let action = rotateAction(with: move, from: rotateNode, insideScene: scene)
            actions.append(action)
        }
        actions.append(SCNAction.removeFromParentNode())
        let sequence = SCNAction.sequence(actions)
        rotateNode.runAction(sequence)
    }
    
    func rotateAction(with move: CubeMove, from rotateNode: SCNNode, insideScene scene: SCNScene) -> SCNAction {
        
        let preAction = SCNAction.run { (rotateNode) in
            
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
            
            let cubeletsToAnimate = self.cubelets.filter { node in
                return comparisonClosure(node)
            }
            _ = cubeletsToAnimate.map { rotateNode.addChildNode($0) }
        }
        
        let vector: SCNVector3
        switch move.faceType {
        case .left, .right:
            vector = SCNVector3(1, 0, 0)
        case .up, .down:
            vector = SCNVector3(0, 1, 0)
        case .front, .back:
            vector = SCNVector3(0, 0, 1)
        }
        let action = SCNAction.rotate(by: -move.angle, around: vector, duration: move.animationDuration)
        
        let postAction = SCNAction.run { (rotateNode) in
            rotateNode.enumerateChildNodes { cubelet, _ in
                cubelet.transform = cubelet.worldTransform
                cubelet.removeFromParentNode()
                scene.rootNode.addChildNode(cubelet)
            }
            rotateNode.eulerAngles = SCNVector3(0, 0, 0)
        }

        return SCNAction.sequence([preAction, action, postAction])
    }
}
