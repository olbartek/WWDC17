//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import SceneKit
import Cocoa
import QuartzCore

// create a scene view with an empty scene
var sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
var scene = SCNScene()
sceneView.scene = scene

// start a live preview of that view
PlaygroundPage.current.liveView = RubiksDemoSceneView(rubiksCube: RubiksCube())

// default lighting
sceneView.autoenablesDefaultLighting = true

// a camera
var cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
scene.rootNode.addChildNode(cameraNode)

// a geometry object
var torus = SCNTorus(ringRadius: 0.6, pipeRadius: 0.15)
var torusNode = SCNNode(geometry: torus)
scene.rootNode.addChildNode(torusNode)

// configure the geometry object
torus.firstMaterial?.diffuse.contents  = NSColor.red
torus.firstMaterial?.specular.contents = NSColor.white
torusNode.rotation = SCNVector4(x: 1.0, y: 2.0, z: 0.0, w: 1.0)



//: [Next](@next)
