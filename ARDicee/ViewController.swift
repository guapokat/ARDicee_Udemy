//
//  ViewController.swift
//  ARDicee
//
//  Created by Virgil Martinez on 3/7/18.
//  Copyright © 2018 Virgil Alexander Martinez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        //units are meters
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
        //sphere
//        let sphere = SCNSphere(radius: 0.2)
//
//        let material = SCNMaterial()
//
//        //material.diffuse.contents = UIColor.red
//        material.diffuse.contents = UIImage(named: "art.scnassets/mars.jpg")
//
//        //cube.materials = [material]
//        sphere.materials = [material]
//
//        let node = SCNNode()
//
//        node.position = SCNVector3(0, 0.1, -0.5)
//
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        // Set the scene to the view
        //sceneView.scene = scene
        
        

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // Create a new scene
                // let scene = SCNScene(named: "art.scnassets/ship.scn")!
                // Dice
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x , hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, hitResult.worldTransform.columns.3.z)
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                  
                    roll(dice: diceNode)
                    
                }
                
            }
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            //is it detected? ok change type to arplaneanchor
            let planeAnchor = anchor as! ARPlaneAnchor
            //NOT Y it is supposed to be Z because it is 2D flat
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            //making a node to attach this to
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            //have to rotate so that it is flat in the correct direction...in radians
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
}
