//
// StringValue.swift
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

/// A computed value which represents a string.
public struct StringValue: StringableValue, Hashable {
    /// A raw string.
    public let string: String
    
    /// Initialized the object.
    /// - Parameters:
    ///     - string: A raw string.
    public init(string: String) {
        self.string = string
    }
    
    public func cast(to capability: ValueCapability, context: EvaluateContext) -> Value {
        switch capability {
        case .stringable:
            return self
        case .numerable:
            let scanner = Scanner(string: string)
            var number: Double = 0.0
            if scanner.scanDouble(&number) && scanner.isAtEnd {
                return DoubleValue(number: number)
            } else {
                return ErrorValue.invalidValue
            }
        case .booleanable:
            return BoolValue(bool: false)
        }
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: StringValue, rhs: StringValue) -> Bool {
        return lhs.string == rhs.string
    }
    
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        get {
            return string.hashValue
        }
    }
}

extension StringValue: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "StringValue(\"\(string)\")"
    }
}
