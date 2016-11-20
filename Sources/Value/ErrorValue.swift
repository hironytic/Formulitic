//
// ErrorValue.swift
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

/// A built-in calculated values which represent errors.
public enum ErrorValue: ErrorableValue, Hashable {
    /// Generic error.
    case generic
    
    /// Syntax error.
    case syntax
    
    /// The value is invalid.
    case invalidValue
    
    /// Unknown function name.
    case unknownFunction
    
    /// The number of arguments passed to the function is wrong.
    case invalidArgumentCount
    
    /// A circular reference is detected.
    ///
    /// Because Formulitic library doesn't provide any dereferencing feature,
    /// this error value is not created by it.
    /// But you can return this value in your custom `BasicDereferencer`
    /// or in `dereference(with:)` method of the reference values which managed
    /// by your custom `ReferenceProducer`.
    case circularReference

    /// The reference is invalid.
    case invalidReference
    
    /// Calculated value is NaN (Not a Number).
    case nan
    
    /// The value is N/A.
    case na
    
    public func cast(to capability: ValueCapability, context: EvaluateContext) -> Value {
        return self
    }
}
