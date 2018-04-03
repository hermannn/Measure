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
    var startNode:SCNNode?
    var textNode: SCNNode?
    var lineNode:SCNNode?
    var endNode:SCNNode?
    var shouldDrawingLine = true
    
    @IBOutlet var sceneView: ARSCNView!
    
    lazy var popUpView: PoPUpLoadingView = {
        let view = PoPUpLoadingView()
        return view
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    lazy var finishMeasureButton: UIButton = {
        let button = UIButton()
        button.setTitle("Finish", for: .normal)
        return button
    }()
    
    lazy var reinitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reinit", for: .normal)
        return button
    }()
    
    lazy var hitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add"), for: .normal)
        return button
    }()
    
    lazy var focusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "focus"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        sceneView.addSubview(popUpView)
        sceneView.addSubview(reinitButton)
        sceneView.addSubview(finishMeasureButton)
        sceneView.addSubview(infoLabel)
        sceneView.addSubview(focusButton)
        sceneView.addSubview(hitButton)
        layoutPopUpView()
        layoutFinishMeasureButton()
        layoutHitButton()
        layoutFocusButton()
        layoutReinitButton()
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
    
    private func layoutPopUpView(){
        popUpView.isHidden = false
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        popUpView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        popUpView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        popUpView.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    private func layoutFinishMeasureButton(){
        finishMeasureButton.isHidden = true
        finishMeasureButton.translatesAutoresizingMaskIntoConstraints = false
        finishMeasureButton.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -15).isActive = true
        finishMeasureButton.trailingAnchor.constraint(equalTo: reinitButton.leadingAnchor, constant: -40).isActive = true
        finishMeasureButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        finishMeasureButton.addTarget(self, action: #selector(finishMeasureButtonPressed(sender:)), for: .touchUpInside)
    }
    
    private func layoutReinitButton() {
        reinitButton.isHidden = true
        reinitButton.translatesAutoresizingMaskIntoConstraints = false
        reinitButton.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -15).isActive = true
        reinitButton.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        reinitButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        reinitButton.addTarget(self, action: #selector(reinitButtonPressed(sender:)), for: .touchUpInside)
    }
    
    private func layoutHitButton() {
        hitButton.translatesAutoresizingMaskIntoConstraints = false
        hitButton.trailingAnchor.constraint(equalTo: self.sceneView.trailingAnchor, constant: -15).isActive = true
        hitButton.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -15).isActive = true
        hitButton.addTarget(self, action: #selector(hitButtonPressed(sender:)), for: .touchUpInside)
    }
    
    private func layoutFocusButton() {
        focusButton.translatesAutoresizingMaskIntoConstraints = false
        focusButton.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        focusButton.centerYAnchor.constraint(equalTo: self.sceneView.centerYAnchor).isActive = true
        focusButton.addTarget(self, action: #selector(focusButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc private func finishMeasureButtonPressed(sender: UIButton) {
//        guard let currentPos = self.getPositionCenterPlane() else {
//            return
//        }
//        finalNode = createNode(position: currentPos)
//        sceneView.scene.rootNode.addChildNode(finalNode!)
        shouldDrawingLine = false
        finishMeasureButton.isHidden = true
        focusButton.isHidden = true
    }
    
    @objc private func reinitButtonPressed(sender: UIButton) {
        startNode = nil
        lineNode = nil
        textNode = nil
        finalNode = nil
        shouldDrawingLine = true
        focusButton.isHidden = false
        hitButton.isEnabled = true
        finishMeasureButton.isHidden = true
        infoLabel.text = "Distance: 0.00 meters"
        reinitButton.isHidden = true
    }
    
    @objc private func hitButtonPressed(sender: UIButton) {
        print("hit Button")
        if let vector = getPositionCenterPlane() {
            let node = createNode(position: vector)
            sceneView.scene.rootNode.addChildNode(node)
            startNode = node
            hitButton.isEnabled = false
            finishMeasureButton.isHidden = false
            reinitButton.isHidden = false
        }
    }
    
    @objc private func focusButtonPressed(sender: UIButton) {
        print("Focus Button")
    }
    
    func getPositionCenterPlane() -> SCNVector3? {
        //detect plane at the center of the view
        let results = sceneView.hitTest(sceneView.center, types: [.existingPlaneUsingExtent, .existingPlane, .featurePoint])
        if let result = results.first {
            let w = result.worldTransform
            return w.position()
        }
        return nil
    }
    
    func createNode(position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.003)
        
        sphere.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 83/255, blue: 43/255, alpha: 1)
        
        sphere.firstMaterial?.lightingModel = .constant
        sphere.firstMaterial?.isDoubleSided = true
        
        let node = SCNNode(geometry: sphere)
        node.position = position
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if shouldDrawingLine {
            DispatchQueue.main.async {
                guard let currentPos = self.getPositionCenterPlane(), let start = self.startNode else {
                    return
                }
                self.textNode?.removeFromParentNode()
                self.endNode?.removeFromParentNode()
                self.lineNode?.removeFromParentNode()
                
                let lineGeometry = self.drawLineNode(from: start.position, to: currentPos)
                self.lineNode = SCNNode(geometry: lineGeometry)
                self.sceneView.scene.rootNode.addChildNode(self.lineNode!)
                
                
                
                self.endNode = self.createNode(position: currentPos)
                self.sceneView.scene.rootNode.addChildNode(self.endNode!)
                
                let distance = self.distancebetweenTwoPoints(startVector: start.position, toFinalVector: currentPos)
                self.infoLabel.text = String(format: "Distance: %.2f meters", distance)
                
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
                
                self.textNode = SCNNode()
                self.textNode?.addChildNode(textWrapperNode)
                
                //make text visible and in front of our point of view
                let constraint = SCNLookAtConstraint(target: self.sceneView.pointOfView)
                constraint.isGimbalLockEnabled = true
                self.textNode!.constraints = [constraint]
                
                self.sceneView.scene.rootNode.addChildNode(self.textNode!)
                self.textNode?.position = SCNVector3((start.position.x+currentPos.x)/2.0, (start.position.y+currentPos.y)/2.0, (start.position.z+currentPos.z)/2.0)
            }
        }
    }
    
    func drawLineNode(from position: SCNVector3, to currentPosition: SCNVector3) -> SCNGeometry{
        let indices : [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [position, currentPosition])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        popUpView.startLoader()
        var stateString = "Loading ..."
        popUpView.textInfo = stateString
        switch camera.trackingState {
        case .notAvailable:
            stateString = "Not Available"
            popUpView.textInfo = stateString
            focusButton.isHidden = true
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                stateString = "TRACKING LIMITED\n Too much camera movement"
                popUpView.textInfo = stateString
                focusButton.isHidden = true
            case .insufficientFeatures:
                stateString = "TRACKING LIMITED\n Not enough surface detail"
                popUpView.textInfo = stateString
                focusButton.isHidden = true
            default:
                stateString = "Limited..."
                popUpView.textInfo = stateString
                focusButton.isHidden = true
            }
        case .normal:
            focusButton.isHidden = false
            popUpView.stopLoader()
        }
        //infoLabel.text = stateString
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

extension ViewController {
    
    func distancebetweenTwoPoints(startVector: SCNVector3, toFinalVector: SCNVector3) -> Float {
        let distance = SCNVector3(startVector.x - toFinalVector.x, startVector.y - toFinalVector.y, startVector.z - toFinalVector.z)
        return sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
    }
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}
