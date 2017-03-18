/*:
 
 # Apple WWDC17 Scholarship submission
 
 ## 1. Playground as a visualisation tool
 
 
 */


import Cocoa
import SceneKit
import PlaygroundSupport

let rubiksCube = RubiksCube()



let cubeMoveNotations = ["U'", "L", "R2'", "F", "B'", "R", "D", "L'", "F2"]
let cubeMoves: [CubeMove] = cubeMoveNotations.flatMap(CubeMove.init)
let reversedCubeMoves = Array(cubeMoves.reversed())
    .map{ (move: CubeMove) -> CubeMove in
    return move.reversed
}

// Temp ViewController

class CubeController: NSViewController {
    
    // MARK: - Properties
    
    static let viewSize: CGSize = CGSize(width: 500.0, height: 500.0)

    private let rubiksCube: RubiksCube
    
    var sceneView: SCNView {
        return view as! SCNView
    }
    var scene: SCNScene {
        return sceneView.scene!
    }
    var cameraNode: SCNNode!
    
    // MARK: - Initializers
    
    init?(cube: RubiksCube) {
        self.rubiksCube = cube
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        let sceneView = SCNView(frame: CGRect(origin: .zero, size: CubeController.viewSize))
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = NSColor.darkGray
        self.view = sceneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupGestures()
    }
    
    // MARK: - Scene setup
    
    fileprivate func setupScene() {
        setupRubiksCube()
        setupCameraNode()
    }
    
    fileprivate func setupRubiksCube() {
        rubiksCube.scene = scene
        rubiksCube.scale = SCNVector3(0.5, 0.5, 0.5)
        scene.rootNode.addChildNode(rubiksCube)
    }
    
    fileprivate func setupCameraNode() {
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -8)
        self.cameraNode = cameraNode
    }
    
    // MARK: - Gestures
    
    fileprivate func setupGestures() {
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(CubeController.didPan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    func didPan(_ gesture: NSPanGestureRecognizer) {
        let xVelocity = Float(gesture.velocity(in: sceneView).x)
        let yVelocity = Float(gesture.velocity(in: sceneView).y)
        
        let oldRot = cameraNode.rotation as SCNQuaternion
        var rot = GLKQuaternionMakeWithAngleAndAxis(Float(oldRot.w), Float(oldRot.x), Float(oldRot.y), Float(oldRot.z))
        
        let rotX = GLKQuaternionMakeWithAngleAndAxis(-xVelocity / Float(sceneView.bounds.size.width) * 5, 0, 1, 0)
        let rotY = GLKQuaternionMakeWithAngleAndAxis(-yVelocity / Float(sceneView.bounds.size.height) * 5, 1, 0, 0)
        let netRot = GLKQuaternionMultiply(rotX, rotY)
        rot = GLKQuaternionMultiply(rot, netRot)
        
        let axis = GLKQuaternionAxis(rot)
        let angle = GLKQuaternionAngle(rot)
        
        cameraNode.rotation = SCNVector4Make(CGFloat(axis.x), CGFloat(axis.y), CGFloat(axis.z), CGFloat(angle))
    }
}

let vc = CubeController(cube: rubiksCube)
PlaygroundPage.current.liveView = vc!.view


//rubiksCube.animateRotateMoves(cubeMoves + reversedCubeMoves,
//                              scene: sceneView.scene!)


//: [Next Topic](@next)
