//
//  RecognizedText.swift
//  ARVision
//
//  Created by viwii on 2019/9/27.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import Foundation
import Vision

final public class RecognizedTextWrapper {
    
    public struct Translation {
        public var text: String? = nil
        public var sourceLanguage: String = "en"
        public var targetLanguage: String = "zh"
    }
    
    public var text: VNRecognizedText?
    
    public var translated: Translation?
    
    public var rectInView: CGRect = .zero
    
    public init(_ text: VNRecognizedText) {
        self.text = text
    }
}

final public class RecognizedTextWrappers {

    let wrappers: [RecognizedTextWrapper]
    
    var shouldJoinAllSentences = true
    
    init(_ wrappers: [RecognizedTextWrapper]) {
        self.wrappers = wrappers
    }
    
    var sourceText: String {
        wrappers.compactMap { $0.text?.string }.joined(separator: shouldJoinAllSentences ? " " : "\n")
    }
    
    var targetText: String {
        wrappers.compactMap { $0.translated?.text }.joined(separator: shouldJoinAllSentences ? " " : "\n")
    }
    
    var splicedText: String {
        if shouldJoinAllSentences {
            return sourceText + "\n" + targetText
        }
        
        return wrappers
            .compactMap { (w) -> String? in
                guard let s = w.text?.string else { return nil }
                if let t = w.translated?.text {
                    return s + "\n" + t
                } else {
                    return s
                }
            }
            .joined(separator: "\n")
    }
}
