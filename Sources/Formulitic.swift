//
// Formulitic.swift
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

/// A central object of formula parsing and evaluating it.
public class Formulitic {
    /// A reference producer.
    public let referenceProducer: ReferenceProducer
    private var functions: [String: Function]

    /// Initializes the object.
    /// - Parameters:
    ///     - referenceProducer: A reference producer to manage references.
    public init(referenceProducer: ReferenceProducer = NullReferenceProducer()) {
        functions = [:]
        self.referenceProducer = referenceProducer
        
        installFunctions(Functions.Operator)
    }

    /// Installs custom functions.
    ///
    /// When you install functions that have the same function names of already installed functions,
    /// it replaces them by newly installed ones.
    /// - Parameters:
    ///     - functions: A dictionary which has pairs of the function name and its function.
    public func installFunctions(_ functions: [String: Function]) {
        for (key, value) in functions {
            self.functions[key] = value
        }
    }
    
    /// Parses a formula string.
    /// - Parameters:
    ///     - formulaString A formula string.
    /// - Returns: A `Formula` object.
    public func parse(_ formulaString: String) -> Formula {
        return FormulaParser(formulitic: self, formulaString: formulaString)
            .parseFormula()
    }
    
    func evaluateFunction(name: String, parameters: [Expression], context: EvaluateContext) -> Value {
        guard let function = functions[name] else { return ErrorValue.unknownFunction }
        return function(parameters, context)
    }
}
