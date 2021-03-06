//
// Value.swift
// Formulitic
//
// Copyright (c) 2016-2018 Hironori Ichimiya <hiron@hironytic.com>
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

/// A calculated value which appears in evaluating a formula.
public protocol Value {
    /// Retrieves an actual value.
    /// - Parameters:
    ///     - context: An `EvaluateContext` object
    /// - Returns: Actual value
    func dereference(with context: EvaluateContext) -> Value
    
    /// Converts this value to another value which has specified capability.
    /// - Parameters:
    ///     - capability: A capability of the value that you want.
    ///     - context: An `EvaluateContext` object.
    /// - Returns: A converted value, or an error value.
    func cast(to capability: ValueCapability, context: EvaluateContext) -> Value
}

public extension Value {
    func dereference(with context: EvaluateContext) -> Value {
        return self
    }
    
    func cast(to capability: ValueCapability, context: EvaluateContext) -> Value {
        return ErrorValue.invalidValue
    }
}

/// A type of a capability of value.
public enum ValueCapability {
    /// A type of capability that the value conforms to `NumerableValue`.
    case numerable
    
    /// A type of capability that the value conforms to `StringableValue`.
    case stringable
    
    /// A type of capability that the value conforms to `BooleanableValue`.
    case booleanable
}

/// An error values.
public protocol ErrorableValue: Value {
    
}

/// A numeric value.
public protocol NumerableValue: Value {
    /// Returns a holding number as a Double.
    var number: Double { get }
}

/// A string value.
public protocol StringableValue: Value {
    /// Returns a holding string.
    var string: String { get }
}

/// A boolean value.
public protocol BooleanableValue: Value {
    /// Returns a holding boolean value.
    var bool: Bool { get }
}

/// A reference value.
public protocol ReferableValue: Value {
    /// Calls the closure on each reference that this object refers to.
    ///
    /// If this object refers to multiple value, the closure is called multiple times.
    /// If this object refers to only one value, the closure is called only once and the `refValue` parameter passed to it can be this object.
    ///
    /// - Parameters:
    ///     - body: A closure called on each reference
    ///     - refValue: Each reference
    func forEachReference(_ body: (_ refValue: ReferableValue) -> Void)
}
