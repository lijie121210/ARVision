//
//  VisionStabilityMonitor.swift
//  ARVision
//
//  Created by viwii on 2019/9/26.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import Foundation
import AVFoundation
import Vision

open class VisionStabilityMonitor {
        
    open var maximumHistoryLength = 20
    
    private var previousPixelBuffer: CVPixelBuffer?
    
    private var transpositionHistoryPoints: [CGPoint] = [ ]

    private func resetTranspositionHistory() {
        transpositionHistoryPoints.removeAll()
    }
    
    private func record(transposition transform: CGAffineTransform) {
        return record(transposition: transform.tx, ty: transform.ty)
    }
    
    private func record(transposition tx: CGFloat, ty: CGFloat) {
        record(transposition:
            CGPoint(x: tx, y: ty)
        )
    }
    
    private func record(transposition point: CGPoint) {
        transpositionHistoryPoints.append(point)
        
        if transpositionHistoryPoints.count > maximumHistoryLength {
            transpositionHistoryPoints.removeFirst()
        }
    }

    open var stabilityLimit = Float(50)
    
    private var isStable: Bool {
        // Determine if we have enough evidence of stability.
        guard transpositionHistoryPoints.count == maximumHistoryLength else {
            return false
        }
        // Calculate the moving average.
        var movingAverage = CGPoint.zero
        for currentPoint in transpositionHistoryPoints {
            movingAverage.x += currentPoint.x
            movingAverage.y += currentPoint.y
        }
        let distance = abs(movingAverage.x) + abs(movingAverage.y)
        return Float(distance) < stabilityLimit
    }

    private let sequenceRequestHandler = VNSequenceRequestHandler()
    
    private func requestTranslation(pixelBuffer: CVPixelBuffer, previousPixelBuffer: CVPixelBuffer) throws -> CGAffineTransform? {
        let registrationRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: pixelBuffer)
        try sequenceRequestHandler.perform([registrationRequest], on: previousPixelBuffer)
        let alignmentObservation = registrationRequest.results?.first as? VNImageTranslationAlignmentObservation
        return alignmentObservation?.alignmentTransform
    }
}

/**
 guard let prePixelBuffer = previousPixelBuffer else {
     previousPixelBuffer = pixelBuffer
     resetTranspositionHistory()
     return
 }
 
 do {
     if let transform = try requestTranslation(pixelBuffer: pixelBuffer, previousPixelBuffer: prePixelBuffer) {
         record(transposition: transform)
     }
     
     previousPixelBuffer = pixelBuffer
     
 } catch {
     print("Failed to process request: \(error.localizedDescription).")
     return
 }
 */
