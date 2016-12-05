//
// BasicFunctionProvider.swift
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

/// A function provider to which functions can be installed as dictionary.
///
/// This class treats function names as case-insensitive.
public class BasicFunctionProvider: FunctionProvider {
    private var functions: [String: Function]

    public init(functions: [String: Function] = [:]) {
        self.functions = [:]
        installFunctions(functions)
    }
    
    /// Installs custom functions.
    ///
    /// When you install functions that have the same function names of already installed functions,
    /// it replaces them by newly installed ones.
    /// - Parameters:
    ///     - functions: A dictionary which has pairs of the function name and its function.
    public func installFunctions(_ functions: [String: Function]) {
        for (key, value) in functions {
            self.functions[key.uppercased()] = value
        }
    }

    public func function(for name: String) -> Function? {
        return functions[name.uppercased()]
    }
}
