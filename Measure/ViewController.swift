//
//  ViewController.swift
//  Measure
//
//  Created by Harsh Londhekar on 09/10/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
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
    //MARK: - Function for detecting touches in the plane
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        message.isHidden = true
        if dotNodes.count >= 2{
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            
            let hitTestResults = sceneView.hitTest(touchLocation, types : .featurePoint)
            
            if let hitResult = hitTestResults.first{
                addDot(at : hitResult)
            }
        }
        
    }
    //MARK: - Function to add a dot node in the plane
    func addDot (at hitResult : ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    //MARK: - Function to calculate the distance between two dot nodes
    
    func calculate(){
        
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        updateText(text: "\(round((100*abs(distance)*100)/100)) cm", atPosition: end.position)
        
    }
    
    func updateText (text: String, atPosition position: SCNVector3){
        
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.cyan
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.001, 0.001, 0.001)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    
}
