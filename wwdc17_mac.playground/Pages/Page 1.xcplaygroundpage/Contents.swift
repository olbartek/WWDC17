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
    
    enum PanDirection {
        case topToBottom
        case bottomToTop
        case leftToRight
        case rightToLeft
    }
    
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
        setupGestures()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print("DID APPEAR")
        
//        let animation = CABasicAnimation(keyPath: "rotation.w")
//        animation.toValue = 2 * CGFloat.pi
//        animation.duration = 2
//        animation.repeatCount = .infinity
//        rubiksCube.addAnimation(animation, forKey: "some animation")
        
        let foreverMovingCameraAction = SCNAction.repeatForever(SCNAction.rotate(by: 2 * CGFloat.pi, around: SCNVector3(0, 1, 0), duration: 2.0))
        cameraNode.runAction(foreverMovingCameraAction, forKey: "rotateCameraAction")
        
        rubiksCube.rotateMoves(cubeMoves + reversedCubeMoves, autorepeat: true)
    }
    
    // MARK: - Scene setup
    
    fileprivate func setupScene() {
        setupCameraNode()
        setupRubiksCube()
        //addLights()
        //addFlor()
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
    
    fileprivate func addFlor() {
//        let floor = SCNFloor()
//        let floorNode = SCNNode(geometry: floor)
//        floorNode.position = SCNVector3(-3, 0, 0)
//        scene.rootNode.addChildNode(floorNode)
        
        let floor2 = SCNFloor()
        let floorNode2 = SCNNode(geometry: floor2)
        floorNode2.opacity = 0.5
        floorNode2.castsShadow = true
        floorNode2.position = SCNVector3(-4, 0, 0)
        floorNode2.rotation = SCNVector4(0,0,0,1)
        floorNode2.eulerAngles.z = -CGFloat.pi / 2
        scene.rootNode.addChildNode(floorNode2)
    }
    
    fileprivate func presentScene() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -12)
        
        SCNTransaction.commit()
    }
    
    // MARK: - Gestures
    
    fileprivate func setupGestures() {
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(CubeController.didPan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    fileprivate func panDirection(from gesture: NSPanGestureRecognizer) -> PanDirection {
        let translation = gesture.translation(in: gesture.view)
        print(translation)
        if abs(translation.y) > abs(translation.x) {
            return translation.y > 0 ? .bottomToTop : .topToBottom
        } else {
            return translation.x > 0 ? .rightToLeft : .leftToRight
        }
    }
    
    var panDirection: PanDirection?
    
    func didPan(_ gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            panDirection = panDirection(from: gesture)
        case .changed:
            break
        case .ended:
            guard let panDirection = panDirection else { return }
            let location = gesture.location(in: sceneView)
            let vector: SCNVector3
            let angle: CGFloat
            let isLeftSidePan = location.x < CubeController.viewSize.width / 2
            switch panDirection {
            case .topToBottom:
                if isLeftSidePan {
                    vector = SCNVector3(1, 0, 0)
                    angle = -CGFloat.pi / 2
                } else {
                    vector = SCNVector3(0, 0, 1)
                    angle = CGFloat.pi / 2
                }
                print("Top to bottom")
            case .bottomToTop:
                if isLeftSidePan {
                    vector = SCNVector3(1, 0, 0)
                    angle = CGFloat.pi / 2
                } else {
                    vector = SCNVector3(0, 0, 1)
                    angle = -CGFloat.pi / 2
                }
                print("Bottom to top")
            case .leftToRight:
                vector = SCNVector3(0, 1, 0)
                angle = CGFloat.pi / 2
                print("Left to right")
            case .rightToLeft:
                vector = SCNVector3(0, 1, 0)
                angle = -CGFloat.pi / 2
                print("Right to left")
            }
            rubiksCube.rotate(around: vector, by: angle, duration: 2)
            self.panDirection = nil
        default:
            break
        }
        
    }
}

let rubiksCube = RubiksCube()
let vc = CubeController(cube: rubiksCube)
PlaygroundPage.current.liveView = vc


//: [Next Topic](@next)
