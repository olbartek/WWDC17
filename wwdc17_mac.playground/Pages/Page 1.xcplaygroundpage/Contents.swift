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
        sceneView.backgroundColor = NSColor.lightGray
        self.view = sceneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        //setupGestures()
        //rubiksCube.rotateMoves(cubeMoves, scene: scene)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.rubiksCube.rotate(around: SCNVector3(0, 1, 0), by: CGFloat.pi / 4, duration: 2)
        }
        
    }
    
    // MARK: - Scene setup
    
    fileprivate func setupScene() {
        setupCameraNode()
        setupRubiksCube()
        addLights()
        addFlor()
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
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -15)
    }
    
    fileprivate func setupRubiksCube() {
        rubiksCube.scene = scene
        scene.rootNode.addChildNode(rubiksCube)
    }
    
    fileprivate func addLights() {
        // add an ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = NSColor(white: 0.05, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        //add a key light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .spot
        lightNode.light?.castsShadow = true
        lightNode.light?.color = NSColor(white: 0.8, alpha: 1.0)
        lightNode.position = SCNVector3(0, 80, 30)
        lightNode.rotation = SCNVector4(1, 0, 0, -CGFloat.pi / 2.8);
        lightNode.light?.spotInnerAngle = 0
        lightNode.light?.spotOuterAngle = 50
        lightNode.light?.shadowColor = NSColor.black
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
    
    // MARK: - Gestures
    
    fileprivate func setupGestures() {
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(CubeController.didPan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    var previousPanTranslation: NSPoint?
    let maxRotation: Float = GLKMathDegreesToRadians(360)
    
    func didPan(_ recognizer: NSPanGestureRecognizer) {
        
        switch recognizer.state
        {
        case .began:
            self.previousPanTranslation = .zero
            
        case .changed:
            guard let previous = self.previousPanTranslation else
            {
                assertionFailure("Attempt to unwrap previous pan translation failed.")
                
                return
            }
            
            // Calculate how much translation occurred between this step and the previous step
            let translation = recognizer.translation(in: recognizer.view)
            let translationDelta = CGPoint(x: translation.x - previous.x, y: translation.y - previous.y)
            
            let orientation = cameraNode.orientation
            
            // Use the pan translation along the x axis to adjust the camera's rotation about the y axis (side to side navigation).
            let yScalar = Float(translationDelta.x / sceneView.bounds.size.width * 5)
            let yRadians = yScalar * maxRotation
            
            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis (up and down navigation).
            let xScalar = Float(translationDelta.y / sceneView.bounds.size.height * 5)
            let xRadians = xScalar * maxRotation
            
            // Represent the orientation as a GLKQuaternion
            var glQuaternion = GLKQuaternionMake(Float(orientation.x), Float(orientation.y), Float(orientation.z), Float(orientation.w))
            
            // Perform up and down rotations around *CAMERA* X axis (note the order of multiplication)
            let xMultiplier = GLKQuaternionMakeWithAngleAndAxis(xRadians, 1, 0, 0)
            glQuaternion = GLKQuaternionMultiply(glQuaternion, xMultiplier)
            
            // Perform side to side rotations around *WORLD* Y axis (note the order of multiplication, different from above)
            let yMultiplier = GLKQuaternionMakeWithAngleAndAxis(yRadians, 0, 1, 0)
            glQuaternion = GLKQuaternionMultiply(yMultiplier, glQuaternion)
            
            cameraNode.orientation = SCNQuaternion(x: CGFloat(glQuaternion.x), y: CGFloat(glQuaternion.y), z: CGFloat(glQuaternion.z), w: CGFloat(glQuaternion.w))
            self.previousPanTranslation = translation
            
        case .ended, .cancelled, .failed:
            self.previousPanTranslation = nil
            
        case .possible:
            break
        }
        
        
//        let xVelocity = Float(gesture.velocity(in: sceneView).x)
//        let yVelocity = Float(gesture.velocity(in: sceneView).y)
//        
//        let oldRot = cameraNode.rotation as SCNQuaternion
//        var rot = GLKQuaternionMakeWithAngleAndAxis(Float(oldRot.w), Float(oldRot.x), Float(oldRot.y), Float(oldRot.z))
//        
//        let rotX = GLKQuaternionMakeWithAngleAndAxis(-xVelocity / Float(sceneView.bounds.size.width) * 5, 0, 1, 0)
//        let rotY = GLKQuaternionMakeWithAngleAndAxis(-yVelocity / Float(sceneView.bounds.size.height) * 5, 1, 0, 0)
//        let netRot = GLKQuaternionMultiply(rotX, rotY)
//        rot = GLKQuaternionMultiply(rot, netRot)
//        
//        let axis = GLKQuaternionAxis(rot)
//        let angle = GLKQuaternionAngle(rot)
//        
//        cameraNode.rotation = SCNVector4Make(CGFloat(axis.x), CGFloat(axis.y), CGFloat(axis.z), CGFloat(angle))
    }
}

let vc = CubeController(cube: rubiksCube)
PlaygroundPage.current.liveView = vc


//: [Next Topic](@next)
