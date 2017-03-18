/*:
 
 # Apple WWDC17 Scholarship submission
 
 ## 1. Playground as a visualisation tool
 
 
 */

import Cocoa
import SceneKit
import PlaygroundSupport

let rubiksCube = RubiksCube()

let width: CGFloat = 500
let height: CGFloat = 500

let frame = CGRect(x: 0, y: 0, width: width, height: height)
let sceneView = SCNView(frame: frame)
sceneView.scene = SCNScene()
sceneView.backgroundColor = .lightGray

let rootNode = sceneView.scene!.rootNode

rubiksCube.scene = sceneView.scene
rootNode.addChildNode(rubiksCube)

// create and add camera to the scene
let camera = SCNCamera()
camera.automaticallyAdjustsZRange = true
let cameraNode = SCNNode()
cameraNode.camera = camera
rootNode.addChildNode(cameraNode)

// place the camera
cameraNode.position = SCNVector3Make(0, 0, 0)
cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -8)

PlaygroundPage.current.liveView = sceneView

let cubeMoveNotations = ["U'", "L", "R2'", "F", "B'", "R", "D", "L'", "F2"]
let cubeMoves: [CubeMove] = cubeMoveNotations.flatMap(CubeMove.init)
let reversedCubeMoves = Array(cubeMoves.reversed())
    .map{ (move: CubeMove) -> CubeMove in
    return move.reversed
}

// Temp ViewController

class Controller: NSViewController {
    
    let scene: SCNScene
    
    init(scene: SCNScene) {
        self.scene = scene
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didPan(_ gesture: NSPanGestureRecognizer) {
        let xVelocity = Float(gesture.velocity(in: sceneView).x)
        let yVelocity = Float(gesture.velocity(in: sceneView).y)
        
        let oldRot = cameraNode.rotation as SCNQuaternion
        var rot = GLKQuaternionMakeWithAngleAndAxis(Float(oldRot.w), Float(oldRot.x), Float(oldRot.y), Float(oldRot.z))
        
        let rotX = GLKQuaternionMakeWithAngleAndAxis(-xVelocity / Float(width) * 5, 0, 1, 0)
        let rotY = GLKQuaternionMakeWithAngleAndAxis(-yVelocity / Float(height) * 5, 1, 0, 0)
        let netRot = GLKQuaternionMultiply(rotX, rotY)
        rot = GLKQuaternionMultiply(rot, netRot)
        
        let axis = GLKQuaternionAxis(rot)
        let angle = GLKQuaternionAngle(rot)
        
        cameraNode.rotation = SCNVector4Make(CGFloat(axis.x), CGFloat(axis.y), CGFloat(axis.z), CGFloat(angle))
    }
}

let vc = Controller(scene: sceneView.scene!)

// Add gesture recognizers

let panGesture = NSPanGestureRecognizer(target: vc, action: #selector(Controller.didPan(_:)))

sceneView.addGestureRecognizer(panGesture)

//rubiksCube.animateRotateMoves(cubeMoves + reversedCubeMoves,
//                              scene: sceneView.scene!)


//: [Next Topic](@next)
