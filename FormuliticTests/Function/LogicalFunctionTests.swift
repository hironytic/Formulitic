//
// LogicalFunctionTests.swift
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

class LogicalFunctionTests: XCTestCase {
    var formulitic = Formulitic()
    
    override func setUp() {
        super.setUp()
        
        let refProducer = BasicReferenceProducer()
        refProducer.dereferencer = { (name, context) -> Value in
            switch name {
            case "T":
                return BoolValue(bool: true)
            case "F":
                return BoolValue(bool: false)
            case "N":
                return ErrorValue.na
            default:
                return ErrorValue.invalidReference
            }
        }
        formulitic = Formulitic(referenceProducer: refProducer)
        formulitic.installFunctions(Functions.logical)
    }
    
    func testAnd1() {
        let formulaString = "AND({T},{F},{T},{F})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testAnd2() {
        let formulaString = "AND({T},{T})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }
    
    func testFalse() {
        let formulaString = "FALSE()"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testIfThen() {
        let formulaString = "IF({T},\"a\",\"b\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "a")
    }

    func testIfElse() {
        let formulaString = "IF({F},\"a\",\"b\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "b")
    }

    func testIfError1() {
        let formulaString = "IFERROR(\"aaa\",\"bbb\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "aaa")
    }

    func testIfError2() {
        let formulaString = "IFERROR({UNKNOWN},\"bbb\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "bbb")
    }
    
    func testIfNa1() {
        let formulaString = "IFNA(\"aaa\",\"bbb\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "aaa")
    }

    func testIfNa2() {
        let formulaString = "IFNA({UNKNOWN},\"bbb\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? ErrorValue), ErrorValue.invalidReference)
    }

    func testIfNa3() {
        let formulaString = "IFNA({N},\"bbb\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "bbb")
    }

    func testNot1() {
        let formulaString = "NOT({T})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testNot2() {
        let formulaString = "NOT({F})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testOr1() {
        let formulaString = "OR({T},{F},{T},{F})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }
    
    func testOr2() {
        let formulaString = "OR({F},{F})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }
    
    func testTrue() {
        let formulaString = "TRUE()"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testXor1() {
        let formulaString = "XOR({T},{F},{T},{F})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testXor2() {
        let formulaString = "XOR({T},{F},{T},{T})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testXor3() {
        let formulaString = "XOR({T})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testXor4() {
        let formulaString = "XOR({F})"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }
}
