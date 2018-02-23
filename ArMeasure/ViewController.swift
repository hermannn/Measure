//
//  ViewController.swift
//  ArMeasure
//
//  Created by Hermann Dorio on 23/02/2018.
//  Copyright © 2018 Hermann Dorio. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Sphere: SCNNode {
    
    init(position: SCNVector3) {
        super.init()
        
        let sphereGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.lightingModel = .physicallyBased
        sphereGeometry.materials = [material]
        self.geometry = sphereGeometry
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

func -(l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var finalNode:SCNNode?
    @IBOutlet var sceneView: ARSCNView!
    
    lazy var infoLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.addSubview(infoLabel)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewDidLayoutSubviews() {
        infoLabel.frame = CGRect(x: 0, y: 16, width: view.bounds.width, height: 64)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
         configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var stateString = "Loading ..."
        switch camera.trackingState {
        case .notAvailable:
            stateString = "Not Available"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                stateString = "TRACKING LIMITED\nToo much camera movement"
            case .insufficientFeatures:
                stateString = "TRACKING LIMITED\nNot enough surface detail"
            default:
                stateString = "Limited..."
            }
        case  .normal:
            stateString = "Ready ;)"
        }
        infoLabel.text = stateString
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

//MARK: Gesture
extension ViewController {
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let result = hitTestResults.first {
            let matrix4x4 = result.worldTransform
            let position = matrix4x4.position()
            //5
            
            let sphere = Sphere(position: position)
            //6
            sceneView.scene.rootNode.addChildNode(sphere)
            var nodes = sceneView.scene.rootNode.childNodes
            nodes.append(sphere)
            let lastNode = nodes.last
            guard let last =  lastNode , let final = finalNode else {
                finalNode = lastNode
                return
            }
            let distance = final.distanceNodesInVector3With(rightOperandsVector: last)
            infoLabel.text = String(format: "Distance: %.2f meters", distance)
            finalNode = lastNode
        }
    }
}

extension SCNNode {
    
    func distanceNodesInVector3With(rightOperandsVector: SCNNode) -> Float {
        let node1Pos = rightOperandsVector.position
        let node2Pos = self.position
        print("node2Pos x : \(node2Pos.x) \n node2Pos y : \(node2Pos.y) \n node2Pos z : \(node2Pos.z) \n")
        print("node1Pos x : \(node1Pos.x) \n node1Pos y : \(node1Pos.y) \n node1Pos z : \(node1Pos.z) \n")
        let distance = SCNVector3(
            node2Pos.x - node1Pos.x,
            node2Pos.y - node1Pos.y,
            node2Pos.z - node1Pos.z
        )
        print("distance : \(distance)")
        let length: Float = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
        return length
    }
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}
