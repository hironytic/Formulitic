//
// BuiltInFunctions.swift
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
    public struct BuiltIn {
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
        
        public static let concatenate = "concatenate"
        public static let power = "power"
    }
}

public extension Functions {
    public static let BuiltIn: [String: Function] = [
        FuncName.BuiltIn.equalTo: equalTo,
        FuncName.BuiltIn.notEqualTo: notEqualTo,
        FuncName.BuiltIn.lessThan: lessThan,
        FuncName.BuiltIn.lessThanOrEqualTo: lessThanOrEqualTo,
        FuncName.BuiltIn.greaterThan: greaterThan,
        FuncName.BuiltIn.greaterThanOrEqualTo: greaterThanOrEqualTo,
        
        
    ]
}

fileprivate typealias BinaryEvaluator = (_ formulitic: Formulitic, _ operand1: Value, _ operand2: Value, _ context: EvaluateContext) -> Value

private func binaryOperator(_ evaluator: @escaping BinaryEvaluator) -> Function {
    return { (formulitic, parameters, context) in
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
        
        return evaluator(formulitic, operand1, operand2, context)
    }
}

private func dereferencing(_ evaluator: @escaping BinaryEvaluator) -> BinaryEvaluator {
    return { (formulitic, operand1, operand2, context) in
        let dereferenced1 = (operand1 as? Referencable)?.dereference(by: formulitic, with: context) ?? operand1
        if dereferenced1 is Errorable {
            return dereferenced1
        }
        
        let dereferenced2 = (operand2 as? Referencable)?.dereference(by: formulitic, with: context) ?? operand2
        if dereferenced2 is Errorable {
            return dereferenced2
        }
        
        return evaluator(formulitic, dereferenced1, dereferenced2, context)
    }
}

private func castEmptyValue(_ emptyValue: EmptyValue, toTypeOf anotherValue: Value, context: EvaluateContext) -> Value {
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

private func typeOrder(of value: Value) -> Int {
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

private func compareNumerable(_ value1: Numerable, _ value2: Numerable) -> Int {
    let comp = value1.number - value2.number
    if comp < 0 {
        return -1
    } else if comp > 0 {
        return 1
    } else {
        return 0
    }
}

private func compareStringable(_ value1: Stringable, _ value2: Stringable) -> Int {
    switch value1.string.compare(value2.string) {
    case .orderedAscending:
        return -1
    case .orderedSame:
        return 0
    case .orderedDescending:
        return 1
    }
}

private func compareBooleanable(_ value1: Booleanable, _ value2: Booleanable) -> Int {
    let order1 = value1.isTrue ? 1 : 0
    let order2 = value2.isTrue ? 1 : 0
    return order1 - order2
}

private func comparisonOperator(matcher: @escaping (Int) -> Bool) -> Function {
    return binaryOperator(dereferencing({ (formulitic, operand1, operand2, context) in
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
                case is Numerable:
                    result = compareNumerable(param1 as! Numerable, param2 as! Numerable)
                case is Stringable:
                    result = compareStringable(param1 as! Stringable, param2 as! Stringable)
                case is Booleanable:
                    result = compareBooleanable(param1 as! Booleanable, param2 as! Booleanable)
                default:
                    assertionFailure("unexpected value")
                    break
                }
            }
        }

        return BoolValue(isTrue: matcher(result))
    }))
}

private let equalTo = comparisonOperator { $0 == 0 }
private let notEqualTo = comparisonOperator { $0 != 0 }
private let lessThan = comparisonOperator { $0 < 0 }
private let lessThanOrEqualTo = comparisonOperator { $0 <= 0 }
private let greaterThan = comparisonOperator { $0 > 0 }
private let greaterThanOrEqualTo = comparisonOperator { $0 >= 0 }

private let add = binaryOperator(dereferencing({ (formulitic, operand1, operand2, context) in
    fatalError()
}))
