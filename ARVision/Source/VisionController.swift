//
//  VisionController.swift
//  ARVision
//
//  Created by viwii on 2019/9/26.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import Foundation
import CoreMedia
import Vision
import UIKit

// Convert UIImageOrientation to CGImageOrientation for use in Vision analysis.
extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
    
    init(_ deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portraitUpsideDown: // Device oriented vertically, Home button on the top
            self = .left
        case .landscapeLeft: // Device oriented horizontally, Home button on the right
            self = .upMirrored
        case .landscapeRight: // Device oriented horizontally, Home button on the left
            self = .down
        case .portrait:            // Device oriented vertically, Home button on the bottom
            self = .up
        default:
            self = .up
        }
    }
    
    var uiimageOrientation: UIImage.Orientation {
        switch self {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        }
    }
}

public protocol VisionControllerDelegate {
    func onResult(_ text: [VNRecognizedText])
}

public extension VisionController {
    
    typealias Completion = ([RecognizedTextWrapper]) -> Void
}

open class VisionController {

    private let serialQueue = DispatchQueue(label: "vision.controller.queue")
    
    private var currentPixelBuffer: CVPixelBuffer?
    
    open var isEnabledOnce = false
    
    open func receive(_ pixelBuffer: CVPixelBuffer, completion: @escaping Completion) {
        guard isEnabledOnce, currentPixelBuffer == nil else {
            return
        }
                
        currentPixelBuffer = pixelBuffer

        recognizedCurrentImage(completion)
    }
    
    private func recognizedCurrentImage(_ completion: @escaping Completion) {
        guard let buffer = currentPixelBuffer else {
            completion([])
            return
        }
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            if let error = error {
                print("recognization error: ", error.localizedDescription)
                return
            }
            guard let obs = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let texts = obs
                .compactMap { $0.topCandidates(1).first }
                .filter { $0.confidence > 0.8 }
            
            DispatchQueue.main.async {
                self?.translate(texts, completion: completion)
            }
        }
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = true
        
        serialQueue.async {
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right, options: [:])
            do {
                defer {
                    self.isEnabledOnce = false
                    self.currentPixelBuffer = nil
                }
                try handler.perform([request])
            } catch {
                print("recognization error: ", error.localizedDescription)
            }
        }
    }
    
    private func translate(_ texts: [VNRecognizedText], completion: @escaping ([RecognizedTextWrapper]) -> Void) {
        let results = texts.map { (t) -> RecognizedTextWrapper in
            let r = RecognizedTextWrapper(t)
            r.translated = RecognizedTextWrapper.Translation(text: "随便写的, 表示一下译文")
            return r
        }
        completion(results)
    }
}
