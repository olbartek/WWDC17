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
PlaygroundPage.current.liveView = sceneView

// default lighting
sceneView.autoenablesDefaultLighting = true

// a camera
var cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
scene.rootNode.addChildNode(cameraNode)

// a geometry object
var torus = SCNTorus(ringRadius: 0.4, pipeRadius: 0.15)
var torusNode = SCNNode(geometry: torus)
scene.rootNode.addChildNode(torusNode)

// configure the geometry object
torus.firstMaterial?.diffuse.contents  = NSColor.red
torus.firstMaterial?.specular.contents = NSColor.white

// set a rotation axis (no angle) to be able to
// use a nicer keypath below and avoid needing
// to wrap it in an NSValue
torusNode.rotation = SCNVector4(x: 1.0, y: 2.0, z: 0.0, w: 1.0)

// animate the rotation of the torus
//var spin = CABasicAnimation(keyPath: "rotation.w") // only animate the angle
//spin.toValue = 2.0*M_PI
//spin.duration = 3
//spin.repeatCount = HUGE // for infinity
//torusNode.addAnimation(spin, forKey: "spin around")


//: [Next](@next)
