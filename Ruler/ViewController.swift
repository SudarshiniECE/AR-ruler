//
//  ViewController.swift
//  Ruler
//
//  Created by Sudharshini on 06/06/19.
//  Copyright © 2019 Sudharshini. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var lineNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2
        {
            for dot in dotNodes
            {
                dot.removeFromParentNode()
            }
            dotNodes.removeAll()
            textNode.removeFromParentNode()
            lineNode.removeFromParentNode()
        }
        if let touchLocation = touches.first?.location(in: sceneView)
        {
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResult.first
            {
                addDot(at:hitResult)
            }
        }
    }
    func addDot(at hitResult : ARHitTestResult)
    {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        if dotNodes.count >= 2
        {
            calculate()
        }
    }
    func calculate ()
    {
        let start = dotNodes[0]
        let end = dotNodes[1]
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        let distance = sqrt(pow(a,2) + pow(b,2) + pow(c,2))
        updateText(text : "\(abs(distance))" , atPosition : end.position)
        
        //draw a line
        let line = SCNGeometry.line(from: start.position, to: end.position)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        line.materials = [material]
        lineNode = SCNNode(geometry: line)
        lineNode.position = SCNVector3Zero
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    func updateText(text : String, atPosition position : SCNVector3)
    {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
