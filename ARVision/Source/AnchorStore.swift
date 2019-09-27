//
//  AnchorStore.swift
//  ARVision
//
//  Created by viwii on 2019/9/26.
//  Copyright © 2019 com.viwii. All rights reserved.
//

import Foundation
import ARKit
import Vision

struct AnchorAccess {
    
    static var shared = AnchorAccess()
    
    private var data = [UUID : RecognizedTextWrappers]()
    
    subscript(_ key: UUID) -> RecognizedTextWrappers? {
        get {
            return data[key]
        }
        set {
            data[key] = newValue
        }
    }
    
    @discardableResult
    mutating func removeAll() -> [UUID] {
        let keys = Array(data.keys)
        data.removeAll()
        return keys
    }
}

struct AnchorStore {
    
    static var shared = AnchorStore()
    
    private var data = [UUID : RecognizedTextWrapper]()
    
    subscript(_ key: UUID) -> RecognizedTextWrapper? {
        get {
            return data[key]
        }
        set {
            data[key] = newValue
        }
    }
    
    mutating func removeAll() -> [UUID] {
        let keys = Array(data.keys)
        data.removeAll()
        return keys
    }
}
