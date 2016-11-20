//
// LogicalFunctions.swift
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

public extension FuncName {
    /// Names of logical functions.
    public struct Logical {
        private init() {}
        
        /// AND function
        public static let and = "AND"
        
        /// FALSE function
        public static let false_ = "FALSE"
        
        /// IF function
        public static let if_ = "IF"
        
        /// IFS function
        public static let ifs = "IFS"
        
        /// IFERROR function
        public static let iferror = "IFERROR"
        
        /// IFNA function
        public static let ifna = "IFNA"
        
        /// NOT function
        public static let not = "NOT"
        
        /// OR function
        public static let or = "OR"

        /// SWITCH function
        public static let switch_ = "SWITCH"
        
        /// TRUE function
        public static let true_ = "TRUE"
        
        /// XOR function
        public static let xor = "XOR"
    }
}

public extension Functions {
    /// Logical functions.
    public static let logical: [String: Function] = [
        FuncName.Logical.and: and,
        FuncName.Logical.false_: false_,
        FuncName.Logical.if_: if_,
        FuncName.Logical.ifs: ifs,
        FuncName.Logical.iferror: iferror,
        FuncName.Logical.ifna: ifna,
        FuncName.Logical.not: not,
        FuncName.Logical.or: or,
        FuncName.Logical.switch_: switch_,
        FuncName.Logical.true_: true_,
        FuncName.Logical.xor: xor,
    ]
}

fileprivate func false_(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 0 else { return ErrorValue.invalidArgumentCount }
    return BoolValue(bool: false)
}

fileprivate func true_(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 0 else { return ErrorValue.invalidArgumentCount }
    return BoolValue(bool: true)
}

fileprivate func and(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count > 0 else { return ErrorValue.invalidArgumentCount }
    
    for param in parameters {
        let value = param
            .evaluate(with: context)
            .dereference(with: context)
            .cast(to: .booleanable, context: context)
        if value is Errorable {
            return value
        }
        
        guard let booleanableValue = value as? Booleanable else {
            return ErrorValue.generic
        }
        
        if !booleanableValue.bool {
            return BoolValue(bool: false)
        }
    }
    return BoolValue(bool: true)
}

fileprivate func or(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count > 0 else { return ErrorValue.invalidArgumentCount }
    
    for param in parameters {
        let value = param
            .evaluate(with: context)
            .dereference(with: context)
            .cast(to: .booleanable, context: context)
        if value is Errorable {
            return value
        }
        
        guard let booleanableValue = value as? Booleanable else {
            return ErrorValue.generic
        }
        
        if booleanableValue.bool {
            return BoolValue(bool: true)
        }
    }
    return BoolValue(bool: false)
}

fileprivate func xor(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count > 0 else { return ErrorValue.invalidArgumentCount }

    var result = false
    for param in parameters {
        let value = param
            .evaluate(with: context)
            .dereference(with: context)
            .cast(to: .booleanable, context: context)
        if value is Errorable {
            return value
        }
        
        guard let booleanableValue = value as? Booleanable else {
            return ErrorValue.generic
        }
        
        if booleanableValue.bool {
            result = !result
        }
    }
    return BoolValue(bool: result)
}

fileprivate func not(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 1 else { return ErrorValue.invalidArgumentCount }

    let value = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .booleanable, context: context)
    if value is Errorable {
        return value
    }

    guard let booleanableValue = value as? Booleanable else {
        return ErrorValue.generic
    }

    return BoolValue(bool: !booleanableValue.bool)
}

fileprivate func if_(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count >= 1 && parameters.count <= 3 else { return ErrorValue.invalidArgumentCount }
    
    let value = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .booleanable, context: context)
    if value is Errorable {
        return value
    }
    
    guard let booleanableValue = value as? Booleanable else {
        return ErrorValue.generic
    }
    
    var expression: Expression
    if (booleanableValue.bool) {
        if parameters.count < 2 {
            return BoolValue(bool: true)
        } else {
            expression = parameters[1]
        }
    } else {
        if parameters.count < 3 {
            return BoolValue(bool: false)
        } else {
            expression = parameters[2]
        }
    }

    return expression.evaluate(with: context)
}

fileprivate func ifs(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count % 2 == 0 else { return ErrorValue.invalidArgumentCount }

    for ix in stride(from: 0, to: parameters.count, by: 2) {
        let value = parameters[ix]
            .evaluate(with: context)
            .dereference(with: context)
            .cast(to: .booleanable, context: context)
        if value is Errorable {
            return value
        }
        
        guard let booleanableValue = value as? Booleanable else {
            return ErrorValue.generic
        }
        
        if (booleanableValue.bool) {
            return parameters[ix + 1].evaluate(with: context)
        }
    }
    return ErrorValue.na
}

fileprivate func iferror(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 2 else { return ErrorValue.invalidArgumentCount }
    
    var value = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
    
    if value is Errorable {
        value = parameters[1].evaluate(with: context)
    }
    
    return value
}

fileprivate func ifna(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 2 else { return ErrorValue.invalidArgumentCount }
    
    var value = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
    
    if let errorValue = value as? ErrorValue {
        if errorValue == ErrorValue.na {
            value = parameters[1].evaluate(with: context)
        }
    }
    
    return value
}

fileprivate func switch_(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count > 0 else { return ErrorValue.invalidArgumentCount }

    let value = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
    
    let equalEvaluator = compareTwoValues { $0 == 0 }
    
    for ix in stride(from: 1, to: parameters.count, by: 2) {
        let caseValue = parameters[ix]
            .evaluate(with: context)
            .dereference(with: context)
        if caseValue is Errorable {
            return caseValue
        }
        
        let matchResult = equalEvaluator(value, caseValue, context)
        if matchResult is Errorable {
            return matchResult
        }
        
        guard let booleanableValue = matchResult as? Booleanable else {
            return ErrorValue.generic
        }
        
        if (booleanableValue.bool) {
            return parameters[ix + 1].evaluate(with: context)
        }
    }
    
    // did not match any case
    if parameters.count % 2 == 0 {
        // the last parameter is default value
        return parameters[parameters.count - 1].evaluate(with: context)
    } else {
        return ErrorValue.na
    }
    
    
}
