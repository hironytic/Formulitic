//
// OperatorFunctions.swift
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
    /// Names of operator functions.
    ///
    /// These functions are internally used to evaluate operator values.
    public struct Operator {
        private init() {}
        
        /// `=` or `==` operator.
        public static let equalTo = "=="
        
        /// `!=` or `<>` opeator.
        public static let notEqualTo = "!="
        
        /// `<` operator.
        public static let lessThan = "<"
        
        /// `<=` operator.
        public static let lessThanOrEqualTo = "<="
        
        /// `>` operator.
        public static let greaterThan = ">"
        
        /// `>=` operator.
        public static let greaterThanOrEqualTo = ">="
        
        
        /// `&` operator.
        public static let concatenate = "&"
        

        /// `+` (binary) operator.
        public static let add = "+"
        
        /// `-` (binary) operator
        public static let subtract = "-"
        
        /// `*` operator
        public static let multiply = "*"
        
        /// `/` operator
        public static let divide = "/"
        
        
        /// `^` operator.
        public static let power = "^"

        
        /// `+` (unary) operator.
        public static let unaryPlus = "+()"
        
        /// `-` (unary) operator.
        public static let unaryNegate = "-()"
    }
}

public extension Functions {
    /// Operator functions.
    ///
    /// These functions are internally used to evaluate operator values.
    public static let operator_: [String: Function] = [
        FuncName.Operator.equalTo: equalTo,
        FuncName.Operator.notEqualTo: notEqualTo,
        FuncName.Operator.lessThan: lessThan,
        FuncName.Operator.lessThanOrEqualTo: lessThanOrEqualTo,
        FuncName.Operator.greaterThan: greaterThan,
        FuncName.Operator.greaterThanOrEqualTo: greaterThanOrEqualTo,
        
        FuncName.Operator.concatenate: concatenate,

        FuncName.Operator.add: add,
        FuncName.Operator.subtract: subtract,
        FuncName.Operator.multiply: multiply,
        FuncName.Operator.divide: divide,
        
        FuncName.Operator.power: power,
        
        FuncName.Operator.unaryPlus: unaryPlus,
        FuncName.Operator.unaryNegate: unaryNegate,
    ]
}

fileprivate typealias BinaryEvaluator = (_ operand1: Value, _ operand2: Value, _ context: EvaluateContext) -> Value
fileprivate typealias UnaryEvaluator = (_ operand: Value, _ context: EvaluateContext) -> Value

fileprivate func binaryOperator(_ evaluator: @escaping BinaryEvaluator) -> Function {
    return { (parameters, context) in
        if parameters.count != 2 {
            return ErrorValue.invalidArgumentCount
        }
        
        let expression1 = parameters[0]
        let operand1 = expression1.evaluate(with: context)
        if operand1 is Errorable {
            return operand1
        }
        
        let expression2 = parameters[1]
        let operand2 = expression2.evaluate(with: context)
        if operand2 is Errorable {
            return operand2
        }
        
        return evaluator(operand1, operand2, context)
    }
}

fileprivate func unaryOperator(_ evaluator: @escaping UnaryEvaluator) -> Function {
    return { (parameters, context) in
        if parameters.count != 1 {
            return ErrorValue.invalidArgumentCount
        }
        
        let expression1 = parameters[0]
        let operand1 = expression1.evaluate(with: context)
        if operand1 is Errorable {
            return operand1
        }
        
        return evaluator(operand1, context)
    }
}

fileprivate func dereferencing(_ evaluator: @escaping BinaryEvaluator) -> BinaryEvaluator {
    return { (operand1, operand2, context) in
        let dereferenced1 = (operand1 as? Referable)?.dereference(with: context) ?? operand1
        if dereferenced1 is Errorable {
            return dereferenced1
        }
        
        let dereferenced2 = (operand2 as? Referable)?.dereference(with: context) ?? operand2
        if dereferenced2 is Errorable {
            return dereferenced2
        }
        
        return evaluator(dereferenced1, dereferenced2, context)
    }
}

fileprivate func dereferencing(_ evaluator: @escaping UnaryEvaluator) -> UnaryEvaluator {
    return { (operand, context) in
        let dereferenced = (operand as? Referable)?.dereference(with: context) ?? operand
        if dereferenced is Errorable {
            return dereferenced
        }
        
        return evaluator(dereferenced, context)
    }
}

fileprivate func castEmptyValue(_ emptyValue: EmptyValue, toTypeOf anotherValue: Value, context: EvaluateContext) -> Value {
    switch anotherValue {
    case is Numerable:
        return emptyValue.cast(to: .numerable, context: context)
    case is Stringable:
        return emptyValue.cast(to: .stringable, context: context)
    case is Booleanable:
        return emptyValue.cast(to: .booleanable, context: context)
    default:
        return emptyValue
    }
}

fileprivate func typeOrder(of value: Value) -> Int {
    switch value {
    case is Numerable:
        return 1
    case is Stringable:
        return 2
    case is Booleanable:
        return 3
    default:
        assertionFailure("unexpected value")
        return 0
    }
}

fileprivate func compareNumerable(_ value1: Numerable, _ value2: Numerable) -> Int {
    let comp = value1.number - value2.number
    if comp < 0 {
        return -1
    } else if comp > 0 {
        return 1
    } else {
        return 0
    }
}

fileprivate func compareStringable(_ value1: Stringable, _ value2: Stringable) -> Int {
    switch value1.string.compare(value2.string) {
    case .orderedAscending:
        return -1
    case .orderedSame:
        return 0
    case .orderedDescending:
        return 1
    }
}

fileprivate func compareBooleanable(_ value1: Booleanable, _ value2: Booleanable) -> Int {
    let order1 = value1.bool ? 1 : 0
    let order2 = value2.bool ? 1 : 0
    return order1 - order2
}

fileprivate func comparisonOperator(matcher: @escaping (Int) -> Bool) -> Function {
    return binaryOperator(dereferencing({ (operand1, operand2, context) in
        var param1 = operand1
        var param2 = operand2
        
        // cast empty value as type of another value
        if let emptyParam1 = param1 as? EmptyValue {
            param1 = castEmptyValue(emptyParam1, toTypeOf: param2, context: context)
            if param1 is Errorable {
                return param1
            }
        } else if let emptyParam2 = param2 as? EmptyValue {
            param2 = castEmptyValue(emptyParam2, toTypeOf: param1, context: context)
            if param2 is Errorable {
                return param2
            }
        }
        
        var result: Int
        
        // compare each types
        if param1 is EmptyValue {
            // both types are EmptyValue
            result = 0
        } else {
            result = typeOrder(of: param1) - typeOrder(of: param2)
            if result == 0 {
                // both types are same, compare values
                switch param1 {
                case let paramNum1 as Numerable:
                    result = compareNumerable(paramNum1, param2 as! Numerable)
                case let paramStr1 as Stringable:
                    result = compareStringable(paramStr1, param2 as! Stringable)
                case let paramBool1 as Booleanable:
                    result = compareBooleanable(paramBool1, param2 as! Booleanable)
                default:
                    assertionFailure("unexpected value")
                    break
                }
            }
        }

        return BoolValue(bool: matcher(result))
    }))
}

fileprivate let equalTo = comparisonOperator { $0 == 0 }
fileprivate let notEqualTo = comparisonOperator { $0 != 0 }
fileprivate let lessThan = comparisonOperator { $0 < 0 }
fileprivate let lessThanOrEqualTo = comparisonOperator { $0 <= 0 }
fileprivate let greaterThan = comparisonOperator { $0 > 0 }
fileprivate let greaterThanOrEqualTo = comparisonOperator { $0 >= 0 }

fileprivate let add = binaryOperator(dereferencing({ (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is Errorable {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is Errorable {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? Numerable,
          let numerable2 = numerableValue2 as? Numerable else { return ErrorValue.generic }
    let result = numerable1.number + numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}))

fileprivate func subtractValues(_ operand1: Value, _ operand2: Value, _ context: EvaluateContext) -> Value {
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is Errorable {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is Errorable {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? Numerable,
        let numerable2 = numerableValue2 as? Numerable else { return ErrorValue.generic }
    let result = numerable1.number - numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}

fileprivate let subtract = binaryOperator(dereferencing(subtractValues))

fileprivate let multiply = binaryOperator(dereferencing({ (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is Errorable {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is Errorable {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? Numerable,
          let numerable2 = numerableValue2 as? Numerable else { return ErrorValue.generic }
    let result = numerable1.number * numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}))

fileprivate let divide = binaryOperator(dereferencing({ (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is Errorable {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is Errorable {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? Numerable,
          let numerable2 = numerableValue2 as? Numerable else { return ErrorValue.generic }
    let result = numerable1.number / numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}))

fileprivate let unaryPlus = unaryOperator(dereferencing({ (operand, context) in
    return operand
}))

fileprivate func unaryNegate(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    if parameters.count != 1 {
        return ErrorValue.invalidArgumentCount
    }
    let value = parameters[0].evaluate(with: context)
    if value is Errorable {
        return value
    }
    return subtractValues(DoubleValue(number: 0), value, context)
}

fileprivate let concatenate = binaryOperator(dereferencing({ (operand1, operand2, context) in
    let stringableValue1 = operand1.cast(to: .stringable, context: context)
    if stringableValue1 is Errorable {
        return stringableValue1
    }
    
    let stringableValue2 = operand2.cast(to: .stringable, context: context)
    if stringableValue2 is Errorable {
        return stringableValue2
    }
    
    guard let stringable1 = stringableValue1 as? Stringable,
          let stringable2 = stringableValue2 as? Stringable else { return ErrorValue.generic }
    let result = stringable1.string + stringable2.string
    return StringValue(string: result)
}))

fileprivate let power = binaryOperator(dereferencing({ (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is Errorable {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is Errorable {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? Numerable,
          let numerable2 = numerableValue2 as? Numerable else { return ErrorValue.generic }
    let result = pow(numerable1.number, numerable2.number)
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}))
