//
// FuncName.swift
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

public struct FuncName {
    private init() {}
    
    public struct Operator {
        private init() {}
        
        public static let equalTo = "=="
        public static let notEqualTo = "!="
        public static let lessThan = "<"
        public static let lessThanOrEqualTo = "<="
        public static let greaterThan = ">"
        public static let greaterThanOrEqualTo = ">="
        
        public static let add = "+"
        public static let subtract = "-"
        public static let multiply = "*"
        public static let divide = "/"
        
        public static let unaryPlus = "+()"
        public static let unaryNegate = "-()"
    }
    
    public struct String {
        private init() {}
        
        public static let concatenate = "concatenate"
    }
    
    public struct Math {
        private init() {}
        
        public static let power = "power"
    }
}
