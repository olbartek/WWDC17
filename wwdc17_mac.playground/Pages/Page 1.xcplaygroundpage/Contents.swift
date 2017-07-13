/*:
 
 # Apple WWDC17 Scholarship submission
 
 ## 1. Playground as a visualisation tool
 
 
 */


import Cocoa
import SceneKit
import PlaygroundSupport

let demoCube = QuickLookableRubiksCube()

let flatRepresentation = demoCube.flatRepresentation


let cubeMoveNotations = ["R", "L", "U2", "F", "U'", "D", "F2", "R2", "B2", "L", "U2", "F'", "B'", "U", "R2", "D", "F2", "U", "R2", "U"]
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
        sceneView.scene?.background.contents = NSImage(named: "radial_gradient_bg")
        sceneView.backgroundColor = NSColor.lightGray
        self.view = sceneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let foreverMovingCameraAction = SCNAction.repeatForever(SCNAction.rotate(by: 2 * CGFloat.pi, around: SCNVector3(0, 1, 0), duration: 2.0))
        cameraNode.runAction(foreverMovingCameraAction, forKey: "rotateCameraAction")
        
        rubiksCube.rotateMoves(cubeMoves + reversedCubeMoves, autorepeat: true)
    }
    
    // MARK: - Scene setup
    
    fileprivate func setupScene() {
        setupCameraNode()
        setupRubiksCube()
        //addLights()
    }
    
    fileprivate func setupCameraNode() {
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        cameraNode = SCNNode()
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.eulerAngles.y = CGFloat.pi / 4
        cameraNode.eulerAngles.x = -CGFloat.pi / 6
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10)
    }
    
    fileprivate func setupRubiksCube() {
        rubiksCube.scene = scene
        scene.rootNode.addChildNode(rubiksCube)
    }
    
    fileprivate func addLights() {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = NSColor(white: 0.05, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .spot
        lightNode.light?.color = NSColor(white: 0.8, alpha: 1.0)
        lightNode.position = SCNVector3(250, 500, 500)
        lightNode.rotation = SCNVector4(1, 0, 0, -CGFloat.pi / 4);
        lightNode.light?.spotInnerAngle = 0
        lightNode.light?.spotOuterAngle = 50
        lightNode.light?.zFar = 500
        lightNode.light?.zNear = 50
        scene.rootNode.addChildNode(lightNode)
    }
    
    fileprivate func presentScene() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -12)
        SCNTransaction.commit()
    }
    
}

let rubiksCube = RubiksCube()
let vc = CubeController(cube: rubiksCube)
PlaygroundPage.current.liveView = vc


//: [Next Topic](@next)
