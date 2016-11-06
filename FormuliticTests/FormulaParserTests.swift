//
// FormulaParserTests.swift
// FormuliticTests
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

import XCTest
@testable import Formulitic

class FormulaParserTests: XCTestCase {
    func testOperator1() {
        let formulaString = "1+2*3+4"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let numberableResult = result as? Numerable {
            XCTAssertEqualWithAccuracy(numberableResult.number, 11.0, accuracy: 0.001)
        } else {
            XCTFail("the result should be a number")
        }
    }
    
    func testParentheses() {
        let formulaString = "1+2*(3+4)"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let numberableResult = result as? Numerable {
            XCTAssertEqualWithAccuracy(numberableResult.number, 15.0, accuracy: 0.001)
        } else {
            XCTFail("the result should be a number")
        }
    }
    
    func testString() {
        let formulaString = "\"abcde\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let stringableResult = result as? Stringable {
            XCTAssertEqual(stringableResult.string, "abcde")
        } else {
            XCTFail("the result should be a string")
        }
    }
    
    func testStringWithQuote() {
        let formulaString = "\"This is \"\"cool\"\".\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let stringableResult = result as? Stringable {
            XCTAssertEqual(stringableResult.string, "This is \"cool\".")
        } else {
            XCTFail("the result should be a string")
        }
    }
    
    func testUnaryOperaor() {
        let formulaString = "-23.5"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let numberableResult = result as? Numerable {
            XCTAssertEqualWithAccuracy(numberableResult.number, -23.5, accuracy: 0.001)
        } else {
            XCTFail("the result should be a number")
        }
    }
    
    func testInvalidSyntax() {
        let formulaString = "12+3ab"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let errorResult = result as? ErrorValue {
            XCTAssertEqual(errorResult, ErrorValue.syntax)
        } else {
            XCTFail("the result should be an error")
        }
    }
    
    func testFunctionWithTwoParam() {
        let formulaString = "MAX(1,2)"
        let formulitic = Formulitic()
        formulitic.installFunctions([
            "MAX": { (parameters, context) -> Value in
                guard parameters.count == 2 else { return ErrorValue.invalidArgumentCount }
                let value1OrNil = (parameters[0].evaluate(with: context).cast(to: .numerable, context: context) as? Numerable)?.number
                let value2OrNil = (parameters[1].evaluate(with: context).cast(to: .numerable, context: context) as? Numerable)?.number
                guard let value1 = value1OrNil, let value2 = value2OrNil else { return ErrorValue.invalidValue }
                return DoubleValue(number: max(value1, value2))
            }
        ])
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let numberableResult = result as? Numerable {
            XCTAssertEqualWithAccuracy(numberableResult.number, 2.0, accuracy: 0.001)
        } else {
            XCTFail("the result should be a number")
        }
    }
    
    func testFunctionWithNoParam() {
        let formulaString = "TRUE()"
        let formulitic = Formulitic()
        formulitic.installFunctions([
            "TRUE": { (parameters, context) -> Value in
                guard parameters.count == 0 else { return ErrorValue.invalidArgumentCount }
                return BoolValue(bool: true)
            }
            ])
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let booleanableResult = result as? Booleanable {
            XCTAssertEqual(booleanableResult.bool, true)
        } else {
            XCTFail("the result should be a boolean")
        }
    }
    
    func testReference() {
        let formulaString = "{v1} + {v2}"
        let refProducer = BasicReferenceProducer()
        refProducer.dereferencer = { (name, _) -> Value in
            switch name {
            case "v1":
                return DoubleValue(number: 30)
            case "v2":
                return DoubleValue(number: 20)
            default:
                return ErrorValue.invalidReference
            }
        }
        let formulitic = Formulitic(referenceProducer: refProducer)
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        if let numberableResult = result as? Numerable {
            XCTAssertEqualWithAccuracy(numberableResult.number, 50.0, accuracy: 0.001)
        } else {
            XCTFail("the result should be a number")
        }
    }
}
