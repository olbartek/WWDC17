import Foundation
import SceneKit

public struct CubeFlatRepresentation {
    
    var frontColors: [[NSColor]] = []
    var backColors: [[NSColor]] = []
    var rightColors: [[NSColor]] = []
    var leftColors: [[NSColor]] = []
    var upColors: [[NSColor]] = []
    var downColors: [[NSColor]] = []
    
    public init(cubelets: [SCNNode]) {
        _ = CubeMove.FaceType.allFaceTypes.map{ assignColors(fromCubelets: cubelets, withType: $0) }
    }
    
    fileprivate mutating func assignColors(fromCubelets cubelets: [SCNNode], withType type: CubeMove.FaceType) {
        let cubeletsWithGivenType = getCubelets(from: cubelets, ofType: type)
        print(cubeletsWithGivenType.count)
        assignColor(to: cubeletsWithGivenType, ofType: type)
    }
    
    fileprivate func getCubelets(from cubelets: [SCNNode], ofType type: CubeMove.FaceType) -> [SCNNode] {
        let comparisonClosure: (_ node: SCNNode) -> Bool = { node in
            let position: CGFloat
            let offset: CGFloat
            switch type {
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
        
        let filteredCubelets = cubelets.filter { node in
            return comparisonClosure(node)
        }
        return filteredCubelets
    }
    
    fileprivate mutating func assignColor(to cubelets: [SCNNode], ofType type: CubeMove.FaceType) {
        let colorIndex: Int
        let idxFcn: (SCNVector3) -> (i: Int, j: Int)
        switch type {
        case .front:
            colorIndex = 0
            idxFcn = { (i: Int($0.x+1), j: Int($0.y+1)) }
        case .right:
            colorIndex = 1
            idxFcn = { (i: Int($0.z+1), j: Int($0.y+1)) }
        case .back:
            colorIndex = 2
            idxFcn = { (i: Int($0.x+1), j: Int($0.y+1)) }
        case .left:
            colorIndex = 3
            idxFcn = { (i: Int($0.z+1), j: Int($0.y+1)) }
        case .up:
            colorIndex = 4
            idxFcn = { (i: Int($0.x+1), j: Int($0.z+1)) }
        case .down:
            colorIndex = 5
            idxFcn = { (i: Int($0.x+1), j: Int($0.z+1)) }
        }
        
        var array: [[NSColor]] = Array(repeating: Array(repeating: NSColor.brown, count: 3),
                                       count: 3)
        for cubelet in cubelets {
            guard let box = cubelet.geometry as? SCNBox else { return }
            let meterial = box.materials[colorIndex]
            guard let color = meterial.diffuse.contents as? NSColor else { return }
            let index = idxFcn(cubelet.position)
            print("array[\(index.i)][\(index.j)]")
            print(color)
            array[index.i][index.j] = color
        }
        
        switch type {
        case .up:
            upColors = array
        case .down:
            downColors = array
        case .back:
            backColors = array
        case .front:
            frontColors = array
        case .left:
            leftColors = array
        case .right:
            rightColors = array
        }
    }
    
}

extension CubeFlatRepresentation: CustomPlaygroundQuickLookable {
    
    fileprivate var squareSide: CGFloat {
        return 23.0
    }
    
    fileprivate func buildView() -> NSView {
        let frame = NSRect(x: 0,
                           y: 0,
                           width: CGFloat(14) * squareSide,
                           height: CGFloat(11) * squareSide)
        let mainView = NSView(frame: frame)
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = NSColor.darkGray.cgColor
        
        buildViews(from: upColors, withinView: mainView, xOffset: 4, yOffset: 1)
        buildViews(from: leftColors, withinView: mainView, xOffset: 1, yOffset: 4)
        buildViews(from: frontColors, withinView: mainView, xOffset: 4, yOffset: 4)
        buildViews(from: rightColors, withinView: mainView, xOffset: 7, yOffset: 4)
        buildViews(from: backColors, withinView: mainView, xOffset: 10, yOffset: 4)
        buildViews(from: downColors, withinView: mainView, xOffset: 4, yOffset: 7)
        
        return mainView
    }
    
    fileprivate func buildViews(from array: [[NSColor]], withinView mainView: NSView, xOffset: Int, yOffset: Int) {
        print(array)
        for i in 0...2 {
            for j in 0...2 {
                let frame = NSRect(x: CGFloat(xOffset + i) * squareSide,
                                   y: CGFloat(yOffset + j) * squareSide,
                                   width: squareSide,
                                   height: squareSide)
                let view = NSView(frame: frame)
                view.wantsLayer = true
                view.layer?.backgroundColor = array[i][j].cgColor
                view.layer?.borderWidth = 1.0
                view.layer?.borderColor = NSColor.black.cgColor
                view.layer?.cornerRadius = squareSide / 5.0
                view.layer?.masksToBounds = true
                mainView.addSubview(view)
            }
        }
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let view = buildView()
        print(view)
        print(view.subviews.count)
        return PlaygroundQuickLook(reflecting: view)
    }
}

