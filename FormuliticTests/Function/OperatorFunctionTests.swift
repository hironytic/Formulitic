//
// OperatorFunctionTests.swift
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

class OperatorFunctionTests: XCTestCase {
    func testEqualTo1() {
        let formulaString = "1 = 1"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testEqualTo2() {
        let formulaString = "1 == 2"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testEqualTo3() {
        let formulaString = "\"foo\" == \"foo\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testEqualTo4() {
        let formulaString = "\"10\" == 10"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testNotEqualTo1() {
        let formulaString = "1 <> 2"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }
    
    func testNotEqualTo2() {
        let formulaString = "1 != 1"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testNotEqualTo3() {
        let formulaString = "\"1\" != 1"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testNotEqualTo4() {
        let formulaString = "\"a\" != \"a\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testLessThan1() {
        let formulaString = "\"aaa\" < \"abb\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }
    
    func testLessThan2() {
        let formulaString = "\"aaa\" < \"aaa\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testLessThan3() {
        let formulaString = "10 < -30"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testLessThanOrEqualTo1() {
        let formulaString = "\"aaa\" <= \"abb\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testLessThanOrEqualTo2() {
        let formulaString = "\"aaa\" <= \"aaa\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }
    
    func testLessThanOrEqualTo3() {
        let formulaString = "10 <= 0"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }
    
    func testGreaterThan1() {
        let formulaString = "10 > 0"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testGreaterThan2() {
        let formulaString = "\"aaa\" > \"bbb\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }

    func testGreaterThan3() {
        let formulaString = "\"aaa\" > \"bbb\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, false)
    }
    
    func testGreaterThenOrEqualTo1() {
        let formulaString = "1 >= 1"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testGreaterThenOrEqualTo2() {
        let formulaString = "\"xxx\" >= \"a\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Booleanable)?.bool, true)
    }

    func testConcatenate() {
        let formulaString = "\"xxx\" & \"yyy\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "xxxyyy")
    }
    
    func testAdd1() {
        let formulaString = "1+10"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? Numerable)?.number ?? 0.0, 11.0, accuracy: 0.001)
    }

    func testAdd2() {
        let formulaString = "\"aa\"+\"bb\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual(result as? ErrorValue, ErrorValue.invalidValue)
    }
    
    func testSubtract1() {
        let formulaString = "1-10"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? Numerable)?.number ?? 0.0, -9.0, accuracy: 0.001)
    }
    
    func testMultiply1() {
        let formulaString = "2*3"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? Numerable)?.number ?? 0.0, 6.0, accuracy: 0.001)
    }
    
    func testDivide1() {
        let formulaString = "25/10"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? Numerable)?.number ?? 0.0, 2.5, accuracy: 0.001)
    }
    
    func testPower1() {
        let formulaString = "2^10"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? Numerable)?.number ?? 0.0, 1024, accuracy: 0.001)
    }
    
    func testUnaryPlus1() {
        let formulaString = "+100"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? Numerable)?.number ?? 0.0, 100, accuracy: 0.001)
    }
    
    func testUnaryPlus2() {
        let formulaString = "+\"aaa\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? Stringable)?.string, "aaa")
    }

    func testUnaryNegate1() {
        let formulaString = "-200"
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? Numerable)?.number ?? 0.0, -200, accuracy: 0.001)
    }

    func testUnaryNegate2() {
        let formulaString = "-\"bbb\""
        let formulitic = Formulitic()
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual(result as? ErrorValue, ErrorValue.invalidValue)
    }
}
