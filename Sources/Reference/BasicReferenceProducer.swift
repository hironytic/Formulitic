//
// BasicReferenceProducer.swift
// Formulitic
//
// Copyright (c) 2016 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public class BasicReferenceProducer: ReferenceProducer {
    public var dereferencer: (_ name: String, _ context: EvaluateContext) -> Value
    
    public init() {
        dereferencer = { (name, context) in
            return ErrorValue.invalidReference
        }
    }
    
    public func reference(for name: String) -> Referable & Value {
        return BasicReferenceValue(producer: self, name: name)
    }
    
    public func dereference(_ reference: BasicReferenceValue, with context: EvaluateContext) -> Value {
        return dereferencer(reference.name, context)
    }
}

public class BasicReferenceValue: Value, Referable {
    private let producer: BasicReferenceProducer
    let name: String
    
    public init(producer: BasicReferenceProducer, name: String) {
        self.producer = producer
        self.name = name
    }
    
    public func dereference(with context: EvaluateContext) -> Value {
        return producer.dereference(self, with: context)
    }
    
    public func forEachReference(_ body: (_ refValue: Value & Referable) -> Void) {
        body(self)
    }
}
