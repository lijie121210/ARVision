//
//  AnchorProvider.swift
//  ARVision
//
//  Created by viwii on 2019/9/27.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import Foundation
import Vision
import ARKit

struct AnchorProvider {
    
    static let name = "RecognizedAnchor"
    
    var sceneView: ARSKView
    
    var shouldJoinAllSentences = true
    
    init(sceneView: ARSKView, shouldJoinAllSentences: Bool = true) {
        self.sceneView = sceneView
        self.shouldJoinAllSentences = shouldJoinAllSentences
    }
    
    func anchor(for recognizedText: RecognizedTextWrapper) -> ARAnchor? {
        guard let ot = recognizedText.text,
            let otbox = try! ot.boundingBox(for: ot.string.startIndex..<ot.string.endIndex) else {
                return nil
        }
        
        let viewFrame = sceneView.frame
        let otrect = convert(vision: otbox, toView: viewFrame)
        let center = CGPoint(
            x: otrect.minX + otrect.width * 0.5,
            y: otrect.minY + otrect.height * 0.5
        )

        let hittestResult = sceneView.hitTest(center, types: [.featurePoint, .estimatedVerticalPlane])
        guard let hitResult = hittestResult.first else {
            return nil
        }
        
        recognizedText.rectInView = otrect
        
        let anchor = ARAnchor(name: AnchorProvider.name, transform: hitResult.worldTransform)
        AnchorStore.shared[anchor.identifier] = recognizedText
        return anchor
    }
    
    func anchor(for recognizedTexts: [RecognizedTextWrapper]) -> ARAnchor? {
        guard let ot = recognizedTexts.first?.text else {
            return nil
        }
        guard let otbox = try? ot.boundingBox(for: ot.string.startIndex..<ot.string.endIndex) else {
            return nil
        }
        let viewFrame = self.sceneView.frame
        let otrect = self.convert(vision: otbox, toView: viewFrame)
        let center = CGPoint(
            x: otrect.minX + otrect.width * 0.5,
            y: otrect.minY + otrect.height * 0.5
        )
        
        let hittestResult = self.sceneView.hitTest(center, types: [.featurePoint, .estimatedVerticalPlane, .estimatedHorizontalPlane])
        guard let hitResult = hittestResult.first else {
            return nil
        }
        
        let wrappers = RecognizedTextWrappers(recognizedTexts)
        wrappers.shouldJoinAllSentences = shouldJoinAllSentences
        
        let anchor = ARAnchor(transform: hitResult.worldTransform)
        AnchorAccess.shared[anchor.identifier] = wrappers
        return anchor
    }
    
    private func convert(vision box: VNRectangleObservation, toView rect: CGRect) -> CGRect {
        let b = box.boundingBox
        return CGRect(
            x: b.origin.x * rect.width,
            y: (1 - b.origin.y - b.height) * rect.height,
            width: b.width * rect.width,
            height: b.height * rect.height
        )
    }
    
}
