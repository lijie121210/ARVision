//
//  ViewController.swift
//  ARVision
//
//  Created by viwii on 2019/9/26.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Vision
import Combine

class ViewController: UIViewController, ARSKViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var sessionAlert: UIAlertController?
    
    private var visionController = VisionController()
    
    private var anchorNodeStyle: AnchorNodeProvider.Style = .splice
    
    private var shouldJoinAllSentences = true

    private var cancellableBag = [Combine.Cancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        var cancellable = NotificationCenter.default
            .publisher(for: Setting.styleValueDidChange)
            .compactMap { (notification) -> AnchorNodeProvider.Style? in
                guard let newValue = notification.userInfo?[Setting.newValueKey] as? Int else { return nil }
                return AnchorNodeProvider.Style(rawValue: newValue)
            }
            .assign(to: \.anchorNodeStyle, on: self)
        
        cancellableBag.append(cancellable)
        
        cancellable = NotificationCenter.default
            .publisher(for: Setting.joinedValueDidChange)
            .compactMap { (notification) -> Bool? in
                guard let newValue = notification.userInfo?[Setting.newValueKey] as? Bool else { return nil }
                return newValue
            }
            .assign(to: \.shouldJoinAllSentences, on: self)
        
        cancellableBag.append(cancellable)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Action
    
    @IBAction func onTapAction(_ sender: UITapGestureRecognizer) {
        indicator.isHidden = false
        visionController.isEnabledOnce = true
    }
    
    @IBAction func onDoubleTapAction(_ sender: UITapGestureRecognizer) {
        AnchorAccess.shared.removeAll()
        
        sceneView.scene?.removeAllChildren()
        
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @IBAction func onLongPressAction(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        performSegue(withIdentifier: "showStylePicker", sender: nil)
    }
    
    @IBSegueAction func onShowPickerSegueAction(_ coder: NSCoder) -> UINavigationController? {
        let navigation = UINavigationController(coder: coder)
        let picker = navigation?.viewControllers.first as? Setting
        picker?.defaultValue = anchorNodeStyle.rawValue
        return navigation
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        visionController.receive(frame.capturedImage) { [weak self] texts in
            guard let self = self else { return }
            
            self.indicator.isHidden = true
            
            let provider = AnchorProvider(sceneView: self.sceneView, shouldJoinAllSentences: self.shouldJoinAllSentences)
            guard let anchor = provider.anchor(for: texts) else {
                return
            }
            session.add(anchor: anchor)
        }
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        
        let provider = AnchorNodeProvider()
        
        return provider.view(view, nodeFor: anchor, style: anchorNodeStyle)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
        sessionAlert = UIAlertController(
            title: "⚠️",
            message: "发生错误：\(error.localizedDescription); 请重启!",
            preferredStyle: .alert
        )
        present(sessionAlert!, animated: true, completion: nil)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
        sessionAlert = UIAlertController(
            title: "",
            message: "已中断...",
            preferredStyle: .actionSheet
        )
        present(sessionAlert!, animated: true, completion: nil)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
        if let alert = sessionAlert {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
}

