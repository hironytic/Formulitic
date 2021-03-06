//
// OperatorFunction.swift
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

/// Names of operator functions.
///
/// These functions are internally used to evaluate operator values.
public struct OperatorFunctionName {
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

/// Operator functions.
///
/// These functions are internally used to evaluate operator values.
public let operatorFunctions: [String: Function] = [
    OperatorFunctionName.equalTo: equalTo,
    OperatorFunctionName.notEqualTo: notEqualTo,
    OperatorFunctionName.lessThan: lessThan,
    OperatorFunctionName.lessThanOrEqualTo: lessThanOrEqualTo,
    OperatorFunctionName.greaterThan: greaterThan,
    OperatorFunctionName.greaterThanOrEqualTo: greaterThanOrEqualTo,
    
    OperatorFunctionName.concatenate: concatenate,

    OperatorFunctionName.add: add,
    OperatorFunctionName.subtract: subtract,
    OperatorFunctionName.multiply: multiply,
    OperatorFunctionName.divide: divide,
    
    OperatorFunctionName.power: power,
    
    OperatorFunctionName.unaryPlus: unaryPlus,
    OperatorFunctionName.unaryNegate: unaryNegate,
]

internal typealias BinaryEvaluator = (_ operand1: Value, _ operand2: Value, _ context: EvaluateContext) -> Value
fileprivate typealias UnaryEvaluator = (_ operand: Value, _ context: EvaluateContext) -> Value

fileprivate func binaryOperator(dereferencing: Bool, evaluator: @escaping BinaryEvaluator) -> Function {
    return { (parameters, context) in
        if parameters.count != 2 {
            return ErrorValue.invalidArgumentCount
        }
        
        let toValue: (Expression) -> Value = (dereferencing)
            ? { $0.evaluate(with: context).dereference(with: context) }
            : { $0.evaluate(with: context) }
        
        let expression1 = parameters[0]
        let operand1 = toValue(expression1)
        if operand1 is ErrorableValue {
            return operand1
        }
        
        let expression2 = parameters[1]
        let operand2 = toValue(expression2)
        if operand2 is ErrorableValue {
            return operand2
        }
        
        return evaluator(operand1, operand2, context)
    }
}

fileprivate func unaryOperator(dereferencing: Bool, evaluator: @escaping UnaryEvaluator) -> Function {
    return { (parameters, context) in
        if parameters.count != 1 {
            return ErrorValue.invalidArgumentCount
        }
        
        let toValue: (Expression) -> Value = (dereferencing)
            ? { $0.evaluate(with: context).dereference(with: context) }
            : { $0.evaluate(with: context) }
        
        let expression1 = parameters[0]
        let operand1 = toValue(expression1)
        if operand1 is ErrorableValue {
            return operand1
        }
        
        return evaluator(operand1, context)
    }
}

fileprivate func castEmptyValue(_ emptyValue: EmptyValue, toTypeOf anotherValue: Value, context: EvaluateContext) -> Value {
    switch anotherValue {
    case is NumerableValue:
        return emptyValue.cast(to: .numerable, context: context)
    case is StringableValue:
        return emptyValue.cast(to: .stringable, context: context)
    case is BooleanableValue:
        return emptyValue.cast(to: .booleanable, context: context)
    default:
        return emptyValue
    }
}

fileprivate func typeOrder(of value: Value) -> Int {
    switch value {
    case is NumerableValue:
        return 1
    case is StringableValue:
        return 2
    case is BooleanableValue:
        return 3
    default:
        assertionFailure("unexpected value")
        return 0
    }
}

fileprivate func compareNumerable(_ value1: NumerableValue, _ value2: NumerableValue) -> Int {
    let comp = value1.number - value2.number
    if comp < 0 {
        return -1
    } else if comp > 0 {
        return 1
    } else {
        return 0
    }
}

fileprivate func compareStringable(_ value1: StringableValue, _ value2: StringableValue) -> Int {
    switch value1.string.compare(value2.string) {
    case .orderedAscending:
        return -1
    case .orderedSame:
        return 0
    case .orderedDescending:
        return 1
    }
}

fileprivate func compareBooleanable(_ value1: BooleanableValue, _ value2: BooleanableValue) -> Int {
    let order1 = value1.bool ? 1 : 0
    let order2 = value2.bool ? 1 : 0
    return order1 - order2
}

internal func compareTwoValues(matcher: @escaping (Int) -> Bool) -> BinaryEvaluator {
    return { (operand1, operand2, context) in
        var param1 = operand1
        var param2 = operand2
        
        // cast empty value as type of another value
        if let emptyParam1 = param1 as? EmptyValue {
            param1 = castEmptyValue(emptyParam1, toTypeOf: param2, context: context)
            if param1 is ErrorableValue {
                return param1
            }
        } else if let emptyParam2 = param2 as? EmptyValue {
            param2 = castEmptyValue(emptyParam2, toTypeOf: param1, context: context)
            if param2 is ErrorableValue {
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
                case let paramNum1 as NumerableValue:
                    result = compareNumerable(paramNum1, param2 as! NumerableValue)
                case let paramStr1 as StringableValue:
                    result = compareStringable(paramStr1, param2 as! StringableValue)
                case let paramBool1 as BooleanableValue:
                    result = compareBooleanable(paramBool1, param2 as! BooleanableValue)
                default:
                    assertionFailure("unexpected value")
                    break
                }
            }
        }
        
        return BoolValue(bool: matcher(result))
    }
}

fileprivate func comparisonOperator(matcher: @escaping (Int) -> Bool) -> Function {
    return binaryOperator(dereferencing: true, evaluator: compareTwoValues(matcher: matcher))
}

fileprivate let equalTo = comparisonOperator { $0 == 0 }
fileprivate let notEqualTo = comparisonOperator { $0 != 0 }
fileprivate let lessThan = comparisonOperator { $0 < 0 }
fileprivate let lessThanOrEqualTo = comparisonOperator { $0 <= 0 }
fileprivate let greaterThan = comparisonOperator { $0 > 0 }
fileprivate let greaterThanOrEqualTo = comparisonOperator { $0 >= 0 }

fileprivate let add = binaryOperator(dereferencing: true) { (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is ErrorableValue {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is ErrorableValue {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? NumerableValue,
          let numerable2 = numerableValue2 as? NumerableValue else { return ErrorValue.generic }
    let result = numerable1.number + numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}

fileprivate func subtractValues(_ operand1: Value, _ operand2: Value, _ context: EvaluateContext) -> Value {
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is ErrorableValue {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is ErrorableValue {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? NumerableValue,
        let numerable2 = numerableValue2 as? NumerableValue else { return ErrorValue.generic }
    let result = numerable1.number - numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}

fileprivate let subtract = binaryOperator(dereferencing: true, evaluator: subtractValues)

fileprivate let multiply = binaryOperator(dereferencing: true) { (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is ErrorableValue {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is ErrorableValue {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? NumerableValue,
          let numerable2 = numerableValue2 as? NumerableValue else { return ErrorValue.generic }
    let result = numerable1.number * numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}

fileprivate let divide = binaryOperator(dereferencing: true) { (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is ErrorableValue {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is ErrorableValue {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? NumerableValue,
          let numerable2 = numerableValue2 as? NumerableValue else { return ErrorValue.generic }
    let result = numerable1.number / numerable2.number
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}

fileprivate let unaryPlus = unaryOperator(dereferencing: true) { o, c in o }

fileprivate func unaryNegate(_ parameters: [Expression], _ context: EvaluateContext) -> Value {
    if parameters.count != 1 {
        return ErrorValue.invalidArgumentCount
    }
    let value = parameters[0].evaluate(with: context)
    if value is ErrorableValue {
        return value
    }
    return subtractValues(DoubleValue(number: 0), value, context)
}

fileprivate let concatenate = binaryOperator(dereferencing: true) { (operand1, operand2, context) in
    let stringableValue1 = operand1.cast(to: .stringable, context: context)
    if stringableValue1 is ErrorableValue {
        return stringableValue1
    }
    
    let stringableValue2 = operand2.cast(to: .stringable, context: context)
    if stringableValue2 is ErrorableValue {
        return stringableValue2
    }
    
    guard let stringable1 = stringableValue1 as? StringableValue,
          let stringable2 = stringableValue2 as? StringableValue else { return ErrorValue.generic }
    let result = stringable1.string + stringable2.string
    return StringValue(string: result)
}

fileprivate let power = binaryOperator(dereferencing: true) { (operand1, operand2, context) in
    let numerableValue1 = operand1.cast(to: .numerable, context: context)
    if numerableValue1 is ErrorableValue {
        return numerableValue1
    }
    
    let numerableValue2 = operand2.cast(to: .numerable, context: context)
    if numerableValue2 is ErrorableValue {
        return numerableValue2
    }
    
    guard let numerable1 = numerableValue1 as? NumerableValue,
          let numerable2 = numerableValue2 as? NumerableValue else { return ErrorValue.generic }
    let result = pow(numerable1.number, numerable2.number)
    if result.isNaN || result.isInfinite {
        return ErrorValue.nan
    }
    return DoubleValue(number: result)
}
