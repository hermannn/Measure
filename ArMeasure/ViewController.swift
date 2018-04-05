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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var startNode:SCNNode?
    var textNode:SCNNode?
    var lineNode:SCNNode?
    var endNode:SCNNode?
    var shouldDrawingLine = true
    var statehitBtn: StateHitBtn = .none
    
    @IBOutlet var sceneView: ARSCNView!
    
    lazy var popUpView: PoPUpLoadingView = {
        let view = PoPUpLoadingView()
        return view
    }()
    
    lazy var reinitButton: CustomButton = {
        let button = CustomButton()
        button.setTitle("Reinitialise", for: .normal)
        return button
    }()
    
    lazy var hitButton: CustomButton = {
        let button = CustomButton()
        button.setTitle(statehitBtn.label(), for: .normal)
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
        addSubviews()
        layoutViews()
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
    
    func getPositionCenterPlane() -> SCNVector3? {
        //detect plane at the center of the view
        let results = sceneView.hitTest(sceneView.center, types: [.featurePoint])
        if let result = results.first {
            let positionToTheWorld = result.worldTransform
            return positionToTheWorld.position()
        }
        return nil
    }
    
    private func removeNodes() {
        self.textNode?.removeFromParentNode()
        self.endNode?.removeFromParentNode()
        self.lineNode?.removeFromParentNode()
    }
    
    private func cleanReferenceToNode() {
        startNode = nil
        lineNode = nil
        endNode = nil
        textNode = nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if shouldDrawingLine {
            DispatchQueue.main.async {
                guard let currentPos = self.getPositionCenterPlane(), let start = self.startNode else {
                    return
                }
                self.removeNodes()
                self.lineNode = NodeComponent.drawLineNode(from: start.position, to: currentPos)
                if self.lineNode != nil {
                    self.sceneView.scene.rootNode.addChildNode(self.lineNode!)
                }
                self.endNode = NodeComponent.createNode(position: currentPos)
                if self.endNode != nil {
                    self.sceneView.scene.rootNode.addChildNode(self.endNode!)
                }
                let distance = self.distancebetweenTwoPointsInCM(startVector: start.position, toFinalVector: currentPos)
                self.textNode = NodeComponent.constraintForTextNode(pointOfView: self.sceneView.pointOfView)
                self.textNode?.addChildNode(NodeComponent.drawTextNode(distance: distance))
        
                if self.textNode != nil {
                    self.sceneView.scene.rootNode.addChildNode(self.textNode!)
                }
                self.textNode?.position = SCNVector3((start.position.x+currentPos.x)/2.0, (start.position.y+currentPos.y)/2.0, (start.position.z+currentPos.z)/2.0)
            }
        }
    }

    func updatePoPUpInfo(type: StateCamera, hitAndReinitBtnIsEnabled: Bool, focusBtnshouldBeHidden: Bool) {
        hitButton.isEnabled = hitAndReinitBtnIsEnabled
        reinitButton.isEnabled = hitAndReinitBtnIsEnabled
        popUpView.textInfo = type.label()
        focusButton.isHidden = focusBtnshouldBeHidden
        switch type {
        case .normal, .notAvailable:
            popUpView.stopLoader()
        case .insufficientfeatures, .excessiveMotion, .initializing, .loading:
            popUpView.startLoader()
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updatePoPUpInfo(type: .loading, hitAndReinitBtnIsEnabled: false, focusBtnshouldBeHidden: true)
        switch camera.trackingState {
        case .notAvailable:
            updatePoPUpInfo(type: .notAvailable, hitAndReinitBtnIsEnabled: false, focusBtnshouldBeHidden: true)
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                updatePoPUpInfo(type: .excessiveMotion, hitAndReinitBtnIsEnabled: false, focusBtnshouldBeHidden: true)
            case .insufficientFeatures:
                updatePoPUpInfo(type: .insufficientfeatures, hitAndReinitBtnIsEnabled: false, focusBtnshouldBeHidden: true)
            case .initializing:
                updatePoPUpInfo(type: .initializing, hitAndReinitBtnIsEnabled: false, focusBtnshouldBeHidden: true)
            }
        case .normal:
            updatePoPUpInfo(type: .normal, hitAndReinitBtnIsEnabled: true, focusBtnshouldBeHidden: false)
        }
    }
}

//MARK: AutoLayout and View Configuration Function
extension ViewController {
    
    private func addSubviews() {
        sceneView.addSubview(popUpView)
        sceneView.addSubview(reinitButton)
        sceneView.addSubview(focusButton)
        sceneView.addSubview(hitButton)
    }
    
    private func layoutViews() {
        layoutPopUpView()
        layoutHitButton()
        layoutFocusButton()
        layoutReinitButton()
    }
    
    private func layoutPopUpView() {
        popUpView.isHidden = false
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        popUpView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        popUpView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    private func layoutReinitButton() {
        reinitButton.isHidden = true
        reinitButton.translatesAutoresizingMaskIntoConstraints = false
        reinitButton.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -15).isActive = true
        reinitButton.leftAnchor.constraint(equalTo: self.sceneView.leftAnchor, constant: 15).isActive = true
        reinitButton.trailingAnchor.constraint(equalTo: self.sceneView.centerXAnchor, constant: -5).isActive = true
        reinitButton.addTarget(self, action: #selector(reinitButtonPressed(sender:)), for: .touchUpInside)
    }
    
    private func layoutHitButton() {
        hitButton.translatesAutoresizingMaskIntoConstraints = false
        hitButton.trailingAnchor.constraint(equalTo: self.sceneView.trailingAnchor, constant: -15).isActive = true
        hitButton.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -15).isActive = true
        hitButton.leftAnchor.constraint(equalTo: self.sceneView.centerXAnchor, constant: 5).isActive = true
        hitButton.addTarget(self, action: #selector(hitButtonPressed(sender:)), for: .touchUpInside)
    }
    
    private func layoutFocusButton() {
        focusButton.translatesAutoresizingMaskIntoConstraints = false
        focusButton.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        focusButton.centerYAnchor.constraint(equalTo: self.sceneView.centerYAnchor).isActive = true
    }
}

//MARK: Action Button
extension ViewController {
    
    @objc private func reinitButtonPressed(sender: UIButton) {
        cleanReferenceToNode()
        statehitBtn = .none
        focusButton.isHidden = false
        reinitButton.isHidden = true
        hitButton.setTitle(statehitBtn.label(), for: .normal)
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    @objc private func hitButtonPressed(sender: UIButton) {
        statehitBtn = statehitBtn == .none ? .draw : .none
        hitButton.setTitle(statehitBtn.label(), for: .normal)
        switch statehitBtn {
        case .none:
            shouldDrawingLine = false
            cleanReferenceToNode()
        case .draw:
            shouldDrawingLine = true
            if let vector = getPositionCenterPlane() {
                let node = NodeComponent.createNode(position: vector)
                sceneView.scene.rootNode.addChildNode(node)
                startNode = node
                reinitButton.isHidden = false
            }
        }
    }
}

// MARK: Helper Function to make calcul
extension ViewController {
    func distancebetweenTwoPointsInCM(startVector: SCNVector3, toFinalVector: SCNVector3) -> Float {
        let distance = SCNVector3(startVector.x - toFinalVector.x, startVector.y - toFinalVector.y, startVector.z - toFinalVector.z)
        return sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z) * 100
    }
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}

// MARK: Useful Enum
extension ViewController {
    
    enum StateHitBtn {
        case draw
        case none
        
        func label() -> String{
            switch  self {
            case .draw:
                return "Stop"
            case .none:
                return "Measure"
            }
        }
    }

    enum StateCamera {
        case normal
        case loading
        case notAvailable
        case excessiveMotion
        case insufficientfeatures
        case initializing
        
        func label() -> String {
            switch self {
            case .loading:
                return "Loading ..."
            case .notAvailable:
                return "Not Available"
            case .excessiveMotion:
                return "TRACKING LIMITED\n Too much camera movement"
            case .initializing:
                return "TRACKING LIMITED\n Not enough surface detail"
            case .insufficientfeatures:
                return "Intialization in progress ..."
            case .normal:
                return ""
            }
        }
    }
}
