//
//  LineNode.swift
//  ArMeasure
//
//  Created by Hermann Dorio on 05/04/2018.
//  Copyright © 2018 Hermann Dorio. All rights reserved.
//

import Foundation
import ARKit

class NodeComponent {
    
    static func drawLineNode(from position: SCNVector3, to currentPosition: SCNVector3) -> SCNNode{
        let indices : [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [position, currentPosition])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let lineGeometry = SCNGeometry(sources: [source], elements: [element])
        let node = SCNNode(geometry: lineGeometry)
        return node
    }
    
    static func drawTextNode(distance: Float) -> SCNNode {
        let textScn = SCNText(string: "", extrusionDepth: 0.1)
        textScn.font = .systemFont(ofSize: 5)
        textScn.firstMaterial?.diffuse.contents = UIColor.white
        textScn.alignmentMode  = kCAAlignmentCenter
        textScn.truncationMode = kCATruncationMiddle
        textScn.firstMaterial?.isDoubleSided = true
        textScn.string = String(format: "Distance: %.2f meters", distance)
        
        
        let textWrapperNode = SCNNode(geometry: textScn)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        return textWrapperNode
    }
    
    static func createNode(position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.003)
        
        sphere.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 83/255, blue: 43/255, alpha: 1)
        
        sphere.firstMaterial?.lightingModel = .constant
        sphere.firstMaterial?.isDoubleSided = true
        
        let node = SCNNode(geometry: sphere)
        node.position = position
        return node
    }
    
    static func constraintForTextNode(pointOfView: SCNNode?) -> SCNNode? {
        //make text visible and in front of our point of view
        guard let point = pointOfView else { return nil }
        let node = SCNNode()
        let constraint = SCNLookAtConstraint(target: point)
        constraint.isGimbalLockEnabled = true
        node.constraints = [constraint]
        return node
    }
}
