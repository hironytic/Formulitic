//
// FormulaParser.swift
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

// # Syntax
//
//      Expression ::= ConcatExpression ( ( '=' | '==' | '<>' | '!=' | '<' | '<=' | '>' | '>=' ) ConcatExpression )*
// 
//      ConcatExpression ::= AdditiveExpression ( '&' AdditiveExpression )*
//
//      AdditiveExpression ::= MultiplicativeExpression ( ( '+' | '-' ) MultiplicativeExpression )*
//
//      MultiplicativeExpression ::= PowerExpression ( ( '*' | '/' ) PowerExpression )*
//
//      PowerExpression ::= PrefixUnaryExpression ( '^' PrefixUnaryExpression )*
//
//      PrefixUnaryExpression ::= ( '+' | '-' )* PrimaryExpression
//
//      PrimaryExpression ::=   '(' Expression ')'
//                            | ValueExpression
//                            | ReferenceExpression
//                            | FunctionExpression
//
//      ValueExpression ::= <NUMBER> | <STRING>
//
//      ReferenceExpression ::= '{' <REFNAME> '}'
//
//      FunctionExpression ::= <IDENTIFIER> '(' FunctionParameterList ')'
//
//      FunctionParameterList ::= (Expression ( ',' Expression )*)?
//
// # Token
//
//      <NUMBER> ::= (['0'-'9'])+ ('.' (['0'-'9'])+)? (['e','E'](['+','-'])?(['0'-'9'])+)?
//
//      <STRING> ::= '"' ((~['"']) | ('"' '"'))* '"'
//
//      <IDENTIFIER> ::= (['A'-'Z','a'-'z','_']) (['A'-'Z','a'-'z','_','0'-'9'])*
//
//      <REFNAME> ::= (~['}'])+


class FormulaParser {
    private enum ParseError: Error {
        case syntax
    }
    
    private let formulitic: Formulitic
    private let formulaString: String
    private var currentPosition: String.Index
    private lazy var numberTokenRegularExpression = try! NSRegularExpression(pattern: "[0-9]+(\\.[0-9]+)?([eE][\\+\\-]?[0-9]+)?", options: [])
    private lazy var stringTokenRegularExpression = try! NSRegularExpression(pattern: "\"([^\"]|\"\")*\"", options: [])
    private lazy var identifierTokenRegularExpression = try! NSRegularExpression(pattern: "[A-Za-z_][A-Za-z_0-9]*", options: [])
    private lazy var refnameTokenRegularExpression = try! NSRegularExpression(pattern: "[^\\}]+", options: [])

    public init(formulitic: Formulitic, formulaString: String) {
        self.formulitic = formulitic
        self.formulaString = formulaString
        currentPosition = formulaString.startIndex
    }

    private func skipSpaces() {
        while true {
            guard currentPosition != formulaString.endIndex else { return }
            
            let ch = formulaString[currentPosition]
            if ch != " " {
                return
            }
            currentPosition = formulaString.index(after: currentPosition)
        }
    }
    
    private func consumeCharacter() -> Character? {
        guard currentPosition != formulaString.endIndex else { return nil }
        let pos = currentPosition
        currentPosition = formulaString.index(after: currentPosition)
        return formulaString[pos]
    }
    
    private func consumeToken(by re: NSRegularExpression) -> String? {
        guard currentPosition != formulaString.endIndex else { return nil }
        
        skipSpaces()
        let searchIndex = currentPosition.samePosition(in: formulaString.utf16)
        let searchLocation = formulaString.utf16.distance(from: formulaString.utf16.startIndex, to: searchIndex)
        let searchRange = NSRange(location: searchLocation, length: formulaString.utf16.count - searchLocation)
        let range = re.rangeOfFirstMatch(in: formulaString,
                                         options: .anchored,
                                         range: searchRange)
        
        guard range.location != NSNotFound else { return nil }
        let utf16FromIndex = formulaString.utf16.index(formulaString.utf16.startIndex, offsetBy: range.location)
        let utf16ToIndex = formulaString.utf16.index(utf16FromIndex, offsetBy: range.length)
        let fromIndex = utf16FromIndex.samePosition(in: formulaString)
        let toIndex = utf16ToIndex.samePosition(in: formulaString)
        
        guard let from = fromIndex, let to = toIndex else { return nil }
        currentPosition = to
        return formulaString[from ..< to]
    }
    
    public func parseFormula() -> Formula {
        do {
            let expression = try parseExpression()
            skipSpaces()
            if consumeCharacter() != nil {
                throw ParseError.syntax
            }
            return Formula(formulitic: formulitic, expression: expression)
        } catch {
            return Formula(formulitic: formulitic, expression: ValueExpression(formulitic: formulitic, value: ErrorValue.syntax))
        }
    }
    
    private func parseExpression() throws -> Expression {
        var result = try parseConcatExpression()
        
        loop: while true {
            var funcName: String
            skipSpaces()
            let pos1 = currentPosition
            let ch1 = consumeCharacter()
            switch ch1 {
            case "="?:
                let pos2 = currentPosition
                let ch2 = consumeCharacter()
                switch ch2 {
                case "="?:
                    break
                default:
                    currentPosition = pos2
                }
                funcName = FuncName.Operator.equalTo
                
            case "<"?:
                let pos2 = currentPosition
                let ch2 = consumeCharacter()
                switch ch2 {
                case ">"?:
                    funcName = FuncName.Operator.notEqualTo
                case "="?:
                    funcName = FuncName.Operator.lessThanOrEqualTo
                default:
                    currentPosition = pos2
                    funcName = FuncName.Operator.lessThan
                }
            
            case ">"?:
                let pos2 = currentPosition
                let ch2 = consumeCharacter()
                switch ch2 {
                case "="?:
                    funcName = FuncName.Operator.greaterThanOrEqualTo
                default:
                    currentPosition = pos2
                    funcName = FuncName.Operator.greaterThan
                }
                
            case "!"?:
                let ch2 = consumeCharacter()
                switch ch2 {
                case "="?:
                    funcName = FuncName.Operator.notEqualTo
                default:
                    currentPosition = pos1
                    break loop
                }
                
            default:
                currentPosition = pos1
                break loop
            }
            
            let exp1 = result
            let exp2 = try parseConcatExpression()
            result = FunctionExpression(formulitic: formulitic, name: funcName, parameters: [exp1, exp2])
        }
        
        return result
    }
    
    private func parseConcatExpression() throws -> Expression {
        var result = try parseAdditiveExpression()
        
        loop: while true {
            skipSpaces();
            let pos = currentPosition
            let ch = consumeCharacter()
            switch ch {
            case "&"?:
                break
            default:
                currentPosition = pos
                break loop
            }
            
            let exp1 = result
            let exp2 = try parseAdditiveExpression()
            result = FunctionExpression(formulitic: formulitic, name: FuncName.Operator.concatenate, parameters: [exp1, exp2])
        }
        
        return result
    }
    
    private func parseAdditiveExpression() throws -> Expression {
        var result = try parseMultiplicativeExpression()
        
        loop: while true {
            var funcName: String
            skipSpaces()
            let pos = currentPosition
            let ch = consumeCharacter()
            switch ch {
            case "+"?:
                funcName = FuncName.Operator.add
            case "-"?:
                funcName = FuncName.Operator.subtract
            default:
                currentPosition = pos
                break loop
            }
            
            let exp1 = result
            let exp2 = try parseMultiplicativeExpression()
            result = FunctionExpression(formulitic: formulitic, name: funcName, parameters: [exp1, exp2])
        }
        
        return result
    }
    
    private func parseMultiplicativeExpression() throws -> Expression {
        var result = try parsePowerExpression()
        
        loop: while true {
            var funcName: String
            skipSpaces()
            let pos = currentPosition
            let ch = consumeCharacter()
            switch ch {
            case "*"?:
                funcName = FuncName.Operator.multiply
            case "/"?:
                funcName = FuncName.Operator.divide
            default:
                currentPosition = pos
                break loop
            }
            
            let exp1 = result
            let exp2 = try parsePowerExpression()
            result = FunctionExpression(formulitic: formulitic, name: funcName, parameters: [exp1, exp2])
        }
        
        return result
    }
    
    private func parsePowerExpression() throws -> Expression {
        var result = try parsePrefixUnaryExpression()
        
        loop: while true {
            skipSpaces()
            let pos = currentPosition
            let ch = consumeCharacter()
            switch ch {
            case "^"?:
                break
            default:
                currentPosition = pos
                break loop
            }
            
            let exp1 = result
            let exp2 = try parsePrefixUnaryExpression()
            result = FunctionExpression(formulitic: formulitic, name: FuncName.Operator.power, parameters: [exp1, exp2])
        }
        
        return result
    }
    
    private func parsePrefixUnaryExpression() throws -> Expression {
        var funcNames: [String] = []
        loop: while true {
            skipSpaces()
            let pos = currentPosition
            let ch = consumeCharacter()
            switch ch {
            case "+"?:
                funcNames.append(FuncName.Operator.unaryPlus)
            case "-"?:
                funcNames.append(FuncName.Operator.unaryNegate)
            default:
                currentPosition = pos
                break loop
            }
        }

        var result = try parsePrimaryExpression()
        for funcName in funcNames.reversed() {
            result = FunctionExpression(formulitic: formulitic, name: funcName, parameters: [result])
        }
        
        return result
    }
    
    private func parsePrimaryExpression() throws -> Expression {
        skipSpaces()
        let pos = currentPosition
        let ch = consumeCharacter()
        switch ch {
        case "("?:
            let expression = try parseExpression()
            skipSpaces()
            if consumeCharacter() == ")" {
                return expression
            } else {
                throw ParseError.syntax
            }

        case ("0" ... "9")?, "\""?:
            currentPosition = pos
            return try parseValueExpression()
        
        case "{"?:
            currentPosition = pos
            return try parseReferenceExpression()
            
        case ("A" ... "Z")?, ("a" ... "z")?, "_"?:
            currentPosition = pos
            return try parseFunctionExpression()
            
        default:
            throw ParseError.syntax
        }
    }
    
    private func parseValueExpression() throws -> Expression {
        skipSpaces()
        let pos = currentPosition
        let ch = consumeCharacter()
        switch ch {
        case ("0" ... "9")?:
            currentPosition = pos
            guard let numberToken = consumeToken(by: numberTokenRegularExpression) else { throw ParseError.syntax }
            let scanner = Scanner(string: numberToken)
            var number: Double = 0.0
            if !scanner.scanDouble(&number) {
                throw ParseError.syntax
            }
            return ValueExpression(formulitic: formulitic, value: DoubleValue(number: number))
        
        case "\""?:
            currentPosition = pos
            guard let stringToken = consumeToken(by: stringTokenRegularExpression) else { throw ParseError.syntax }
            let string = stringToken
                // trim first and last quotes
                .substring(with: stringToken.index(after: stringToken.startIndex) ..< stringToken.index(before: stringToken.endIndex))
                // replace doubled quotes into one quote
                .replacingOccurrences(of: "\"\"", with: "\"")
            return ValueExpression(formulitic: formulitic, value: StringValue(string: string))
            
        default:
            throw ParseError.syntax
        }
    }
    
    private func parseReferenceExpression() throws -> Expression {
        skipSpaces()
        let ch = consumeCharacter()
        guard ch == "{" else { throw ParseError.syntax }
        guard let name = consumeToken(by: refnameTokenRegularExpression) else { throw ParseError.syntax }
        
        skipSpaces()
        if consumeCharacter() != "}" {
            throw ParseError.syntax
        }

        return ValueExpression(formulitic: formulitic, value: formulitic.referenceProducer.reference(for: name))
    }
    
    private func parseFunctionExpression() throws -> Expression {
        guard let name = consumeToken(by: identifierTokenRegularExpression) else { throw ParseError.syntax }
        
        skipSpaces()
        if consumeCharacter() != "(" {
            throw ParseError.syntax
        }
        
        let parameters = try parseFunctionParameterList()
        
        skipSpaces()
        if consumeCharacter() != ")" {
            throw ParseError.syntax
        }

        return FunctionExpression(formulitic: formulitic, name: name, parameters: parameters)
    }
    
    private func parseFunctionParameterList() throws -> [Expression] {
        var parameters: [Expression] = []
        
        skipSpaces()
        let pos1 = currentPosition
        let ch1 = consumeCharacter()
        switch ch1 {
        case ")"?:
            currentPosition = pos1
        
        default:
            currentPosition = pos1
            let expression1 = try parseExpression()
            parameters.append(expression1)
            
            loop: while true {
                skipSpaces()
                let pos2 = currentPosition
                let ch2 = consumeCharacter()
                switch ch2 {
                case ","?:
                    let expression2 = try parseExpression()
                    parameters.append(expression2)
                default:
                    currentPosition = pos2
                    break loop
                }
            }
        }

        return parameters
    }
}
