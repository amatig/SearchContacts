//
//  Globals.swift
//  TestSwift
//
//  Created by Giovanni Amati on 24/11/2017.
//  Copyright © 2017 Messagenet. All rights reserved.
//

import UIKit

let appDelegate = UIApplication.shared

public class AtomicBoolean {
    private var val: UInt8 = 0
    
    public init(initialValue: Bool) {
        self.val = (initialValue == false ? 0 : 1)
    }
    
    public func getAndSet(value: Bool) -> Bool {
        if value {
            return OSAtomicTestAndSet(7, &val)
        } else {
            return OSAtomicTestAndClear(7, &val)
        }
    }
    
    public func get() -> Bool {
        return val != 0
    }
}

extension String {
    
    func characterAtIndex(index: Int) -> Character? {
        var cur = 0
        for char in self {
            if cur == index {
                return char
            }
            cur += 1
        }
        return nil
    }
    
}

extension Range where Bound == String.Index {
    
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
    
}

