//
//  ViewController.swift
//  AR Example
//
//  Created by Alex Ray on 10/24/17.
//  Copyright © 2017 Jar Development Studios. All rights reserved.
//  You can find an up-to-date version of this file on github.com/jalexray/AR-Example
// *** BE SURE TO SET YOUR Info.plist PERMISSIONS! ***

import UIKit
import ARKit // 1: We import ARKit to use Apple's framework

class ViewController: UIViewController, ARSCNViewDelegate { // Drawing, Initialization: We need to add an ARSCNViewDelegate to use the renderer

    @IBOutlet weak var drawButton: UIButton! // Drawing, Step 1 (DS1:): Here we've linked our button from the story button as an outlet (not an action, although that's counterintuitive).
    
    @IBOutlet weak var sceneView: ARSCNView! // 2: Here, we connect the ARSCNView from the Story Board to the ViewController.swift file
    let configuration = ARWorldTrackingConfiguration() // 3: Here, we set up a configuration variable to use later
    
    override func viewDidLoad() { // In viewDidLoad(), a function that gets called when the view loads, we're going to initialize the ARSCNView.
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin] // 4: Here we set out debug options. In production, you won't have these, but for now, they're useful. We get to see feature points (little yellow dots on unique points in our world) and the World Origin (where ARKit decides is our (0,0,0) (x,y,z)).
        self.sceneView.showsStatistics = true // 5: This shows you statistics about the running program, such as FPS. It's useful for debugging too. For now, we set it to true. In production, we'll want it off.
        self.sceneView.session.run(configuration) // 6: Ok! Time to run it! Everything we want is set up.
        self.sceneView.autoenablesDefaultLighting = true // 7: Now that it's running, let's add one more thing: lighting. This sets up a light that AR objects reflect. Default makes the light come from somewhere near origin.
        self.sceneView.delegate = self // DS28: Finally, let's make the sceneview able to interact with itself.
    }
    
    // From here on, the contents of this page are extra content. This specific contents lets us draw on the real world!
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) { // DS2: This is a renderer function that runs every time the scene is rendered. Remember when we saw it as 60fps? Yeah, this gets called 60 times per second.
        guard let pointOfView = sceneView.pointOfView else {return} // DS4: Let's make sure we have a point of view (orientation and location)
        let transform = pointOfView.transform // DS5: That point of view is saved as a matrix. This transform lets us access it.
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33) // DS6: The orientation is saved in cells M31, M32, and M33 in that matrix we just grabbed in DS5.
        let location = SCNVector3(transform.m41,transform.m42,transform.m43) // DS7: The location is saved in cells M41, M42, and M43 in that matrix we grabbed in DS5.
        let currentPositionOfCamera = orientation + location // DS8: To put something in front of the camera, we need to combine where we are (location) with where we're looking (orientation). Note that at the end of this file, we've added an extension that allows us to add these two variables using the + command.
        print("render")
        DispatchQueue.main.async { // DS9: This is a function that runs separately from the main thread. It's executed every time the scene is rendered using the variables that it got from when the scene was rendered, but it doesn't require the renderer to stop.
            if self.drawButton.isHighlighted { // DS10: Let's check if that drawButton outlet we have is being presseed. If so, we'll draw. If not, we'll just have a pointer.
                let sphereNode = SCNNode() // DS11: Ok, in this loop we know the button is highlighted. So let's make a sphere "pixel" where the camera is pointing.
                sphereNode.geometry = SCNSphere(radius: 0.01) // DS12: We'll give the sphere a radius of .01
                sphereNode.position = currentPositionOfCamera // DS13: We'll place the sphere in front of the camera. We could use the "location" variable instead if we wanted the sphere on top of us.
                self.sceneView.scene.rootNode.addChildNode(sphereNode) // DS14: Now let's add this sphere to the scene as a child of the scene.
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red:0.94, green:0.28, blue:0.29, alpha:1.0) // DS15: We'll make this sphere #F04849, my favorite color (diffuse = color)
                sphereNode.geometry?.firstMaterial?.specular.contents = UIColor.white // DS16: And we'll make this sphere have a white shine (specular = shine)
                print("drawing") // DS17: And, just for confirmation it's working, let's print drawing to the console.
            }else{ // DS18: This is what happens if the button is not highlighted - we want to have a pointer where it would draw.
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in // DS19: First, let's remove any already rendered pointers. If we didn't do this, there would be a trail of pointers wherever you weren't drawing.
                    if node.name == "pointer" { // DS20: We name the pointer "pointer" later, so we can call it here.
                        node.removeFromParentNode() // DS21: Get rid of that pointer!
                    }
                })
                let pointer = SCNNode() // DS22: Now, let's make a new pointer node.
                pointer.geometry = SCNPyramid(width: 0.01, height: 0.01, length: 0.01) // DS23: We'll make it a pyramid. There are a lot of SCN Shapes you can play with!
                pointer.position = currentPositionOfCamera // DS24: We'll put it at the current position of the camera.
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray // DS25: We'll make it dark gray (and not shiny - no specular here).
                pointer.name = "pointer" // DS26: We'll name it pointer (so we can call it in DS20).
                self.sceneView.scene.rootNode.addChildNode(pointer) // DS27: And let's add it as a child to the scene.
                //This will be called 60 times per second - it removes the previous pointer and adds a new one straight in front of the camera.
            }
        }
    }
}

//Extra Extensions for ARKit
extension Int { // This extension lets us convert integer degrees to radians
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 { // This extension lets us combine SCNVector3s using the + (standard addition syntax)
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
