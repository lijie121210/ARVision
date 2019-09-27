//
//  Scene.swift
//  ARVision
//
//  Created by viwii on 2019/9/26.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import SpriteKit
import ARKit

extension SKScene {
    
    struct Corners {
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
        
        private var _center: CGPoint?
        var center: CGPoint {
            mutating get {
                if _center == nil {
                    _center = CGPoint(
                        x: topLeft.x + (topRight.x - topLeft.x) * 0.5,
                        y: topLeft.y + (bottomLeft.y - topLeft.y) * 0.5
                    )
                }
                return _center!
            }
        }
        
        init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
        }
    }
    
    func convertRect(fromView rect: CGRect) -> Corners {
        return Corners(
            topLeft: convertPoint(fromView: CGPoint(x: rect.minX, y: rect.minY)),
            topRight: convertPoint(fromView: CGPoint(x: rect.maxX, y: rect.minY)),
            bottomLeft: convertPoint(fromView: CGPoint(x: rect.minX, y: rect.maxY)),
            bottomRight: convertPoint(fromView: CGPoint(x: rect.maxX, y: rect.maxY))
        )
    }
}

class Scene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
        guard let sceneView = self.view as? ARSKView,
            let currentFrame = sceneView.session.currentFrame else {
                return
        }
        
        // Create anchor using the camera's current position
        // Create a transform with a translation of 0.2 meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        let transform = simd_mul(currentFrame.camera.transform, translation)
        
        // Add a new anchor to the session
        let anchor = ARAnchor(name: "Name", transform: transform)
        sceneView.session.add(anchor: anchor)
         */
//    }
}
