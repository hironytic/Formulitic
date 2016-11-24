//
// StringFunctionTests.swift
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

class StringFunctionTests: XCTestCase {
    var formulitic = Formulitic()
    
    override func setUp() {
        super.setUp()
        
        let refProducer = BasicReferenceProducer()
        refProducer.dereferencer = { (name, context) -> Value in
            switch name {
            case "eAcute1":
                return StringValue(string: "\u{E9}")
            case "eAcute2":
                return StringValue(string: "\u{65}\u{301}")
            default:
                return ErrorValue.invalidReference
            }
        }
        formulitic = Formulitic(referenceProducer: refProducer)
        formulitic.installFunctions(Functions.string)
    }
    
    func testFind1() {
        let formulaString = "FIND(\"apple\", \"Pen Pineapple Apple Pen\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? NumerableValue)?.number ?? 0.0, 9.0, accuracy: 0.001)
    }

    func testFind2() {
        let formulaString = "FIND(\"Apple\", \"Pen Pineapple Apple Pen\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? NumerableValue)?.number ?? 0.0, 15.0, accuracy: 0.001)
    }
    
    func testFind3() {
        let formulaString = "FIND(\"Pen\", \"Pen Pineapple Apple Pen\", 10)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? NumerableValue)?.number ?? 0.0, 21.0, accuracy: 0.001)
    }
    
    func testFind4() {
        let formulaString = "FIND(\"pen\", \"Pen Pineapple Apple Pen\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual(result as? ErrorValue, ErrorValue.invalidValue)
    }
    
    func testLeft1() {
        let formulaString = "LEFT(\"abcde\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "a")
    }

    func testLeft2() {
        let formulaString = "LEFT(\"abcde\", 4)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "abcd")
    }

    func testLeft3() {
        let formulaString = "LEFT(\"abcde\", 8)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "abcde")
    }
    
    func testLeft4() {
        let formulaString1 = "LEFT({eAcute1} & \"abcde\", 4)"
        let formula1 = formulitic.parse(formulaString1)
        let result1 = formula1.evaluate()
        XCTAssertEqual((result1 as? StringableValue)?.string, "éabc")

        let formulaString2 = "LEFT({eAcute2} & \"abcde\", 4)"
        let formula2 = formulitic.parse(formulaString2)
        let result2 = formula2.evaluate()
        XCTAssertEqual((result2 as? StringableValue)?.string, "éab")
    }
    
    func testLen1() {
        let formulaString = "LEN(\"Fire the lasor!\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqualWithAccuracy((result as? NumerableValue)?.number ?? 0.0, 15.0, accuracy: 0.001)
    }

    func testLen2() {
        let formulaString1 = "LEN({eAcute1})"
        let formula1 = formulitic.parse(formulaString1)
        let result1 = formula1.evaluate()
        XCTAssertEqualWithAccuracy((result1 as? NumerableValue)?.number ?? 0.0, 1.0, accuracy: 0.001)
        
        let formulaString2 = "LEN({eAcute2})"
        let formula2 = formulitic.parse(formulaString2)
        let result2 = formula2.evaluate()
        XCTAssertEqualWithAccuracy((result2 as? NumerableValue)?.number ?? 0.0, 2.0, accuracy: 0.001)
    }
    
    func testLower() {
        let formulaString = "LOWER(\"CAUTION\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "caution")
    }
    
    func testMid1() {
        let formulaString = "MID(\"I'll never be hungry again.\", 6, 5)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "never")
    }

    func testMid2() {
        let formulaString = "MID(\"I'll never be hungry again.\", 100, 5)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "")
    }

    func testMid3() {
        let formulaString = "MID(\"I'll never be hungry again.\", 6, 100)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "never be hungry again.")
    }
    
    func testReplace1() {
        let formulaString = "REPLACE(\"three apples on the table\", 7, 6, \"bananas\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "three bananas on the table")
    }

    func testReplace2() {
        let formulaString = "REPLACE(\"three apples on the table\", 100, 6, \"bananas\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "three apples on the tablebananas")
    }

    func testReplace3() {
        let formulaString = "REPLACE(\"three apples on the table\", 7, 100, \"bananas\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "three bananas")
    }

    func testRept1() {
        let formulaString = "REPT(\"--*\", 3)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "--*--*--*")
    }

    func testRept2() {
        let formulaString = "REPT(\"--*\", 0)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "")
    }
    
    func testRight1() {
        let formulaString = "RIGHT(\"abcde\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "e")
    }
    
    func testRight2() {
        let formulaString = "RIGHT(\"abcde\", 4)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "bcde")
    }
    
    func testRight3() {
        let formulaString = "RIGHT(\"abcde\", 8)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "abcde")
    }

    func testSubstitute1() {
        let formulaString = "SUBSTITUTE(\"aaabcaadeaaa\", \"aa\", \"XXX\")"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "XXXabcXXXdeXXXa")
    }
    
    func testSubstitute2() {
        let formulaString = "SUBSTITUTE(\"aaabcaadeaaa\", \"aa\", \"XXX\", 1)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "XXXabcaadeaaa")
    }

    func testSubstitute3() {
        let formulaString = "SUBSTITUTE(\"aaabcaadeaaa\", \"aa\", \"XXX\", 3)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "aaabcaadeXXXa")
    }

    func testSubstitute4() {
        let formulaString = "SUBSTITUTE(\"aaabcaadeaaa\", \"aa\", \"XXX\", 10)"
        let formula = formulitic.parse(formulaString)
        let result = formula.evaluate()
        XCTAssertEqual((result as? StringableValue)?.string, "aaabcaadeaaa")
    }
}
