//: Playground - noun: a place where people can play

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

let cubeMoveNotations = ["L", "R2", "L", "R2", "L", "R2"]
let cubeMoves: [CubeMove] = cubeMoveNotations.flatMap(CubeMove.init)
cubeMoves

let reversedCubeMoves = Array(cubeMoves.reversed())
    .map{ (move: CubeMove) -> CubeMove in
    return move.reversed
}
reversedCubeMoves

rubiksCube.animateMoves(cubeMoves + reversedCubeMoves)
