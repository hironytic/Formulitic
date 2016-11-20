//
// StringFunctions.swift
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
    public struct String {
        private init() {}
        
        /// FIND function
        public static let find = "FIND"
        
        /// LEFT function
        public static let left = "LEFT"

        /// LEN function
        public static let len = "LEN"
        
        /// LOWER function
        public static let lower = "LOWER"
        
        /// MID function
        public static let mid = "MID"
        
        /// REPLACE function
        public static let replace = "REPLACE"
        
        /// REPT function
        public static let rept = "REPT"
        
        /// RIGHT function
        public static let right = "RIGHT"
        
        /// SEARCH function
        public static let search = "SEARCH"
        
        /// SUBSTITUTE function
        public static let substitute = "SUBSTITUTE"
        
        /// T function
        public static let t = "T"
        
        /// TRIM function
        public static let trim = "TRIM"
        
        /// UNICHAR function
        public static let unichar = "UNICHAR"
        
        /// UNICODE function
        public static let unicode = "UNICODE"
        
        /// UPPER function
        public static let upper = "UPPER"
    }
}

public extension Functions {
    /// String functions.
    public static let string: [String: Function] = [
        FuncName.String.find: find,
        FuncName.String.left: left,
        FuncName.String.len: len,
        FuncName.String.lower: lower,
        FuncName.String.mid: mid,
        FuncName.String.replace: replace,
        FuncName.String.rept: rept,
    ]
}

fileprivate func find(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard 2...3 ~= parameters.count else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let findTextParam = param0 as? StringableValue else { return ErrorValue.generic }
    let findText = findTextParam.string
    
    let param1 = parameters[1]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param1 is ErrorableValue {
        return param1
    }
    guard let withinTextParam = param1 as? StringableValue else { return ErrorValue.generic }
    let withinText = withinTextParam.string

    let param2 = parameters.count < 3 ? DoubleValue(number: 1.0) : parameters[2]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param2 is ErrorableValue {
        return param2
    }
    guard let startParam = param2 as? NumerableValue else { return ErrorValue.generic }
    let start = Int(startParam.number) - 1
    
    guard 0 ..< withinText.unicodeScalars.count ~= start else { return ErrorValue.invalidValue }
    guard let startPos = withinText.unicodeScalars
        .index(withinText.unicodeScalars.startIndex, offsetBy: start)
        .samePosition(in: withinText)
        else {
            return ErrorValue.invalidValue
    }
    if let foundRange = withinText.range(of: findText, range: startPos ..< withinText.endIndex) {
        let foundPosInUnicodeScalar = foundRange.lowerBound.samePosition(in: withinText.unicodeScalars)
        let result = withinText.unicodeScalars.distance(from: withinText.unicodeScalars.startIndex, to: foundPosInUnicodeScalar) + 1
        return DoubleValue(number: Double(result))
    } else {
        return ErrorValue.invalidValue
    }
}

fileprivate func left(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard 1...2 ~= parameters.count else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let textParam = param0 as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string
    
    let param1 = parameters.count < 2 ? DoubleValue(number: 1.0) : parameters[1]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param1 is ErrorableValue {
        return param1
    }
    guard let countParam = param1 as? NumerableValue else { return ErrorValue.generic }
    let count = Int(countParam.number)
    if count > text.unicodeScalars.count {
        return StringValue(string: text)
    }

    let result = String(text.unicodeScalars[text.unicodeScalars.startIndex ..< text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: count)])
    return StringValue(string: result)
}

fileprivate func len(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 1 else { return ErrorValue.invalidArgumentCount }
    
    let param = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param is ErrorableValue {
        return param
    }
    guard let textParam = param as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string
    
    let result = text.unicodeScalars.count
    return DoubleValue(number: Double(result))
}

fileprivate func lower(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 1 else { return ErrorValue.invalidArgumentCount }
    
    let param = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param is ErrorableValue {
        return param
    }
    guard let textParam = param as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string

    let result = text.lowercased()
    return StringValue(string: result)
}

fileprivate func mid(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 3 else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let textParam = param0 as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string
    
    let param1 = parameters[1]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param1 is ErrorableValue {
        return param1
    }
    guard let startParam = param1 as? NumerableValue else { return ErrorValue.generic }
    let start = Int(startParam.number) - 1
    guard start >= 0 else { return ErrorValue.invalidValue }
    
    let param2 = parameters[2]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param2 is ErrorableValue {
        return param2
    }
    guard let countParam = param2 as? NumerableValue else { return ErrorValue.generic }
    var count = Int(countParam.number)
    guard count >= 0 else { return ErrorValue.invalidValue }
    
    if start >= text.unicodeScalars.count {
        return StringValue(string: "")
    } else if start + count >= text.unicodeScalars.count {
        count = text.unicodeScalars.count - start
    }
    
    let lowerBound = text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: start)
    let upperBound = text.unicodeScalars.index(lowerBound, offsetBy: count)
    let result = String(text.unicodeScalars[lowerBound ..< upperBound])
    return StringValue(string: result)
}

fileprivate func replace(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 4 else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let textParam = param0 as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string
    
    let param1 = parameters[1]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param1 is ErrorableValue {
        return param1
    }
    guard let startParam = param1 as? NumerableValue else { return ErrorValue.generic }
    let start = Int(startParam.number) - 1
    guard start >= 0 else { return ErrorValue.invalidValue }
    
    let param2 = parameters[2]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param2 is ErrorableValue {
        return param2
    }
    guard let countParam = param2 as? NumerableValue else { return ErrorValue.generic }
    var count = Int(countParam.number)
    guard count >= 0 else { return ErrorValue.invalidValue }

    let param3 = parameters[3]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param3 is ErrorableValue {
        return param3
    }
    guard let newTextParam = param3 as? StringableValue else { return ErrorValue.generic }
    let newText = newTextParam.string

    if start >= text.unicodeScalars.count {
        return StringValue(string: text + newText)
    } else if start + count >= text.unicodeScalars.count {
        count = text.unicodeScalars.count - start
    }
    
    let lowerBound = text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: start)
    let upperBound = text.unicodeScalars.index(lowerBound, offsetBy: count)
    var resultUnicodeScalars = text.unicodeScalars
    resultUnicodeScalars.replaceSubrange(lowerBound ..< upperBound, with: newText.unicodeScalars)
    let result = String(resultUnicodeScalars)
    return StringValue(string: result)
}

fileprivate func rept(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard parameters.count == 2 else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let textParam = param0 as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string
    
    let param1 = parameters[1]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param1 is ErrorableValue {
        return param1
    }
    guard let countParam = param1 as? NumerableValue else { return ErrorValue.generic }
    let count = Int(countParam.number)
    guard count >= 0 else { return ErrorValue.invalidValue }
    
    let result = String(repeating: text, count: count)
    return StringValue(string: result)
}
