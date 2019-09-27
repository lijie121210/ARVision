//
//  AnchorNodeProvider.swift
//  ARVision
//
//  Created by viwii on 2019/9/27.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import Foundation
import SpriteKit
import ARKit

extension AnchorNodeProvider {
    
    enum Style: Int, CaseIterable {
        case onlySource
        case onlyTarget
        case splice
        case combine
        case mirror
    }
    
}

struct AnchorNodeProvider {
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor, style: Style = .splice) -> SKNode? {
        guard let text = AnchorAccess.shared[anchor.identifier] else {
            return nil
        }
        
        switch style {
        case .onlySource:
            return nodeWith(text.sourceText, imageNamed: "en-marker")
        case .onlyTarget:
            return nodeWith(text.targetText, imageNamed: "zh-marker")
        case .splice:
            return nodeWith(text.splicedText, imageNamed: "language-marker")
        case .combine:
            return combineNode(text: text)
        case .mirror:
            return mirrorNode(text: text)
        }
    }
    
    private func combineNode(text: RecognizedTextWrappers) -> SKNode? {
        let sourceLabelNode = labelNodeBuilder(text.sourceText)
        let targetLabelNode = labelNodeBuilder(text.targetText.isEmpty ? " - - " : text.targetText)

        let labelSize = CGSize(
            width: sourceLabelNode.frame.width + 20 + targetLabelNode.frame.width,
            height: max(sourceLabelNode.frame.height, targetLabelNode.frame.height)
        )
        
        let backSize = CGSize(width: labelSize.width + 20, height: labelSize.height + 20)
        let back = SKShapeNode(rectOf: backSize, cornerRadius: 4)
        back.fillColor = UIColor.white
        back.strokeColor = UIColor(named: "boxBorder")!
        
        let marker = markerNodeBuilder("language-marker", attachTo: backSize)
        
        back.addChild(marker)
        back.addChild(sourceLabelNode)
        back.addChild(targetLabelNode)
        
        sourceLabelNode.position = CGPoint(
            x: sourceLabelNode.position.x - sourceLabelNode.frame.width * 0.5 - 10,
            y: sourceLabelNode.position.y
        )
        
        targetLabelNode.position = CGPoint(
            x: -(targetLabelNode.position.x - targetLabelNode.frame.width * 0.5 - 10),
            y: targetLabelNode.position.y
        )
        
        return back;
    }
    
    private func mirrorNode(text: RecognizedTextWrappers) -> SKNode {
        let sourceNode = nodeWith(text.sourceText, imageNamed: "en-marker")
        let targetNode = nodeWith(text.targetText, imageNamed: "zh-marker")

        let labelSize = CGSize(
            width: sourceNode.frame.width + 20 + targetNode.frame.width,
            height: max(sourceNode.frame.height, targetNode.frame.height)
        )
        
        let backSize = CGSize(width: labelSize.width + 20, height: labelSize.height + 20)
        let back = SKShapeNode(rectOf: backSize, cornerRadius: 0)
        back.fillColor = .clear
        back.strokeColor = .clear
        
        back.addChild(sourceNode)
        back.addChild(targetNode)
        
        sourceNode.position = CGPoint(
            x: sourceNode.position.x - sourceNode.frame.width * 0.5 - 10,
            y: sourceNode.position.y
        )
        
        targetNode.position = CGPoint(
            x: -(targetNode.position.x - targetNode.frame.width * 0.5 - 10),
            y: targetNode.position.y
        )
        
        return back;
    }
    
    private func labelNodeBuilder(_ text: String) -> SKLabelNode {
        let labelNode = SKLabelNode(text: text)
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        labelNode.fontSize = 20
        labelNode.fontColor = UIColor.black
        labelNode.preferredMaxLayoutWidth = 150
        labelNode.numberOfLines = 50
        return labelNode
    }
    
    private func markerNodeBuilder(_ imageName: String, attachTo size: CGSize) -> SKSpriteNode {
        let markerSize = CGSize(width: 70, height: 40)
        let marker = SKSpriteNode(imageNamed: imageName)
        marker.position = CGPoint(x: (markerSize.width - size.width) * 0.5, y: size.height * 0.5 + markerSize.height * 0.6)
        marker.size = markerSize
        return marker
    }
    
    private func nodeWith(_ text: String, imageNamed imageName: String) -> SKNode {
        let sourceLabelNode = labelNodeBuilder(text)
        let labelSize = sourceLabelNode.frame.size
        
        let backSize = CGSize(width: labelSize.width + 20, height: labelSize.height + 20)
        let back = SKShapeNode(rectOf: backSize, cornerRadius: 4)
        back.fillColor = UIColor.white
        back.strokeColor = UIColor(named: "boxBorder")!
                
        let marker = markerNodeBuilder(imageName, attachTo: backSize)
        
        back.addChild(marker)
        back.addChild(sourceLabelNode)
        
        return back;
    }
}

/*
guard let data = AnchorStore.shared[anchor.identifier] else {
    let labelNode = SKLabelNode(text: "👾")
    labelNode.horizontalAlignmentMode = .center
    labelNode.verticalAlignmentMode = .center
    return labelNode;
}

let labelNode = SKLabelNode(text: data.text.string)
labelNode.horizontalAlignmentMode = .center
labelNode.verticalAlignmentMode = .center
labelNode.fontSize = 8
labelNode.fontColor = UIColor.black
labelNode.preferredMaxLayoutWidth = 400
labelNode.numberOfLines = 50

let background = SKSpriteNode(color: .white, size: labelNode.frame.size)
background.addChild(labelNode)

return background;
 */
