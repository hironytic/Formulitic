//
// Value.swift
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

/// A value which appears in evaluating a formula.
public protocol Value {
    func cast(to capability: ValueCapability, context: EvaluateContext) -> Value
}

public extension Value {
    func cast(to capability: ValueCapability, context: EvaluateContext) -> Value {
        return ErrorValue.invalidValue
    }
}

/// A type of some value's capability.
public enum ValueCapability {
    case errorable
    case numerable
    case stringable
    case booleanable
}

/// A capability of error values.
public protocol Errorable {
    
}

/// A capability of numeric values.
public protocol Numerable {
    /// Returns a holding number as a Double.
    var number: Double { get }
}

/// A capability of string values.
public protocol Stringable {
    /// Returns a holding string.
    var string: String { get }
}

/// A capability of boolean values.
public protocol Booleanable {
    /// Returns a holding boolean value.
    var isTrue: Bool { get }
}

/// A capability of reference values.
public protocol Referable {    
    /// Retrieves an actual value.
    /// - Parameter context: An EvaluateContext object
    /// - Returns: Actual value
    func dereference(with context: EvaluateContext) -> Value

    /// Calls the closure on each reference that this object refers to.
    ///
    /// If this object refers to multiple value, the closure is called multiple times.
    /// If this object refers to only one value, the closure is called only once and the `refValue` parameter passed to it can be this object.
    ///
    /// - Parameter body: A closure called on each reference
    /// - Parameter refValue: Each reference
    func forEachReference(_ body: (_ refValue: Value & Referable) -> Void)
}
