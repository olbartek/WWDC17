import SceneKit

public class RubiksDemoSceneView: SCNView {
    
    static let viewSize: CGSize = CGSize(width: 300, height: 300)
    fileprivate weak var cube: RubiksCube?
    
    required public init(rubiksCube: RubiksCube) {
        super.init(frame: CGRect(origin: .zero,
                                 size: RubiksDemoSceneView.viewSize))
        self.cube = rubiksCube
        scene = SCNScene()
        scene!.background.contents = NSImage(named: "radial_gradient_bg")
        backgroundColor = NSColor(white: 0.05, alpha: 1.0)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scene!.rootNode.addChildNode(cameraNode)
        
        rubiksCube.eulerAngles.x = CGFloat.pi / 4
        rubiksCube.eulerAngles.y = CGFloat.pi / 4
        rubiksCube.eulerAngles.z = CGFloat.pi / 4
        scene!.rootNode.addChildNode(rubiksCube)
        
        shuffle()
        
    }
    
    fileprivate func shuffle() {
        let randMoves = CubeMove.randomMoves(withNumber: 10)
        let quickRandMoves = randMoves.map{ randMove -> (CubeMove) in
            var move = randMove
            move.animationDuration = 0.1
            return move
        }
        cube?.rotateMoves(quickRandMoves)
    }
    
    override init(frame: NSRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
