//
// StringFunction.swift
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

public extension BuiltInFunctionName {
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

public extension BuiltInFunction {
    /// String functions.
    public static let string: [String: Function] = [
        BuiltInFunctionName.String.find: find,
        BuiltInFunctionName.String.left: left,
        BuiltInFunctionName.String.len: len,
        BuiltInFunctionName.String.lower: lower,
        BuiltInFunctionName.String.mid: mid,
        BuiltInFunctionName.String.replace: replace,
        BuiltInFunctionName.String.rept: rept,
        BuiltInFunctionName.String.right: right,
        BuiltInFunctionName.String.substitute: substitute,
        BuiltInFunctionName.String.t: t,
        BuiltInFunctionName.String.trim: trim,
        BuiltInFunctionName.String.unichar: unichar,
        BuiltInFunctionName.String.unicode: unicode,
        BuiltInFunctionName.String.upper: upper,
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

fileprivate func right(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
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
    
    let upperBound = text.unicodeScalars.endIndex
    let lowerBound = text.unicodeScalars.index(upperBound, offsetBy: -count)
    let result = String(text.unicodeScalars[lowerBound ..< upperBound])
    return StringValue(string: result)
}

fileprivate func substitute(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard 3...4 ~= parameters.count else { return ErrorValue.invalidArgumentCount }
    
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
        .cast(to: .stringable, context: context)
    if param1 is ErrorableValue {
        return param1
    }
    guard let oldTextParam = param1 as? StringableValue else { return ErrorValue.generic }
    let oldText = oldTextParam.string

    let param2 = parameters[2]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param2 is ErrorableValue {
        return param2
    }
    guard let newTextParam = param2 as? StringableValue else { return ErrorValue.generic }
    let newText = newTextParam.string
    
    if parameters.count > 3 {
        let param3 = parameters[3]
            .evaluate(with: context)
            .dereference(with: context)
            .cast(to: .numerable, context: context)
        if param3 is ErrorableValue {
            return param3
        }
        guard let instanceNumParam = param3 as? NumerableValue else { return ErrorValue.generic }
        let instanceNum = Int(instanceNumParam.number)
        guard instanceNum >= 1 else { return ErrorValue.invalidValue }

        var replaceRange: Range<String.Index>? = nil
        var beginIndex = text.startIndex
        var foundCount = 0
        while beginIndex < text.endIndex {
            let range = beginIndex ..< text.endIndex
            if let foundRange = text.range(of: oldText, range: range) {
                foundCount += 1
                if foundCount == instanceNum {
                    replaceRange = foundRange
                    break
                } else {
                    beginIndex = foundRange.upperBound
                }
            } else {
                break
            }
        }
        if let replaceRange = replaceRange {
            var result = text
            result.replaceSubrange(replaceRange, with: newText)
            return StringValue(string: result)
        } else {
            return StringValue(string: text)
        }
    } else {
        let result = text.replacingOccurrences(of: oldText, with: newText)
        return StringValue(string: result)
    }
}

fileprivate func t(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard 1 == parameters.count else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
    if param0 is ErrorableValue {
        return param0
    }

    if param0 is StringableValue {
        return param0
    } else {
        return StringValue(string: "")
    }
}

fileprivate func trim(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard 1 == parameters.count else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let textParam = param0 as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string

    let result = text
        .trimmingCharacters(in: [" "])
        .replacingOccurrences(of: "[\\u0020]+", with: " ", options: .regularExpression)
    return StringValue(string: result)
}

fileprivate func unichar(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard 1 == parameters.count else { return ErrorValue.invalidArgumentCount }

    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .numerable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let numberParam = param0 as? NumerableValue else { return ErrorValue.generic }
    let number = Int(numberParam.number)

    guard number > 0 else { return ErrorValue.invalidValue }
    
    switch number {
    case 0xd800 ... 0xdfff, 0xfffe, 0xffff:
        return ErrorValue.na
    default:
        if let us = UnicodeScalar(number) {
            return StringValue(string: String(Character(us)))
        } else {
            return ErrorValue.invalidValue
        }
    }
}

fileprivate func unicode(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    guard 1 == parameters.count else { return ErrorValue.invalidArgumentCount }
    
    let param0 = parameters[0]
        .evaluate(with: context)
        .dereference(with: context)
        .cast(to: .stringable, context: context)
    if param0 is ErrorableValue {
        return param0
    }
    guard let textParam = param0 as? StringableValue else { return ErrorValue.generic }
    let text = textParam.string

    if text.unicodeScalars.count == 0 {
        return ErrorValue.invalidValue
    } else {
        let first = text.unicodeScalars[text.unicodeScalars.startIndex]
        return DoubleValue(number: Double(first.value))
    }
}

fileprivate func upper(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
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
    
    let result = text.uppercased()
    return StringValue(string: result)
}
