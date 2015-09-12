//#!/usr/bin/env xcrun swift

//
//  calc.swift
//  Expression Calculator
//
//  Created by Андрей Рычков on 16.02.15.
//

// Use ./calc.swift "expression" to calculate it

import Foundation
import Darwin

enum Op {
    case Operand(Double)
    case Parenthesis(Bool)
    case BinaryOperation(String, (Double, Double) -> Double)
    case Constant(Double)
    case UnaryOperation(Double -> Double)
    case Ending
    
    static let knownOps = [
        "PI" : Op.Operand(M_PI),
        "E" : Op.Operand(exp(1.0)),
        "sin" : Op.UnaryOperation(sin),
        "cos" : Op.UnaryOperation(cos),
        "exp" : Op.UnaryOperation(exp),
        "+" : Op.BinaryOperation("+", +),
        "-" : Op.BinaryOperation("-", -),
        "*" : Op.BinaryOperation("*", *),
        "/" : Op.BinaryOperation("/", /),
        "(" : Op.Parenthesis(true),
        ")" : Op.Parenthesis(false)
    ]
}

let actionsTable = [
//   |  +  -  *  /  (  )  F
    [4, 1, 1, 1, 1, 1, 5, 1], // |
    [2, 2, 2, 1, 1, 1 ,2, 1], // +
    [2, 2, 2, 1, 1, 1, 2, 1], // -
    [2, 2, 2, 2, 2, 1, 2, 1], // *
    [2, 2, 2, 2, 2, 1, 2, 1], // /
    [5, 1, 1, 1, 1, 1, 3, 1], // (
    [2, 2, 2, 2, 2, 1, 2, 5]  // F
]

func col(op: Op) -> Int {
    switch op {
    case .Ending: return 0
    case .BinaryOperation(let symbol, _):
        switch (symbol) {
        case "+": return 1
        case "-": return 2
        case "*": return 3
        case "/": return 4
        default: return 7
        }
    case .Parenthesis(let open):
        if open { return 5 } else { return 6 }
    default: return 7
    }
}

func row(op: Op) -> Int {
    switch op {
    case .Ending: return 0
    case .BinaryOperation(let symbol, _):
        switch (symbol) {
        case "+": return 1
        case "-": return 2
        case "*": return 3
        case "/": return 4
        default: return 6
        }
    case .Parenthesis(let open) where open:
        return 5
    default: return 6
    }
}

//MARK: Computations

func parseExpression(inStr: String) -> [Op] {
    var result = [Op]()
    var prevChar: Character!
    var buffer: String = ""
    
    for ch in inStr {
        if ch == " " { continue }
        if ( ch >= "0" && ch <= "9" ) || ( ch >= "a" && ch <= "z" ) ||
        ( ch >= "A" && ch <= "Z" ) || ch == "." {
            buffer.append(ch)
        } else if count(buffer) > 0 {
            if let op = checkBuffer(buffer) {
                result.append(op)
                buffer = ""
            } else { showError("Wrong input") }
        }
        if count(buffer) == 0 {
            if ( ch == "-" && ( prevChar == nil || prevChar == "(" ) ) {
                result.append(Op.Operand(0.0))
            }
            if let op = Op.knownOps["\(ch)"] {
                result.append(op)
            } else { showError("Unknown operator") }
        }
        prevChar = ch
    }
    if count(buffer) > 0 {
        if let op = checkBuffer(buffer) {
            result.append(op)
        } else { showError("Wrong input") }
    }
    result.append(Op.Ending)
    return result
}


func infixToPostfix(ops: [Op]) -> [Op] {
    var action = 0
    var stack = [Op]()
    var i = 0
    var result = [Op]()
    
    do {
        action = actionsTable[stack.isEmpty ? 0 : row(stack.last!)][col(ops[i])]
        switch action {
        case 1: stack.append(ops[i++])
        case 2: result.append(stack.removeLast())
        case 3: stack.removeLast(); ++i
        case 4: break
        case 5: showError("Brackets error")
        default: showError("Unknown error")
        }
    } while action != 4
    
    return result
}

func evaluate(expr: [Op]) -> Double {
    var remainingOps = expr
    let curOp = remainingOps.removeLast()
    switch curOp {
    case .Operand(let value):
        return value
    case .UnaryOperation(let operation):
        return operation(evaluate(remainingOps))
    case .BinaryOperation(_, let operation):
        let right = evaluate(remainingOps)
        remainingOps.removeLast()
        let left = evaluate(remainingOps)
        return operation(left, right)
    case .Constant(let value):
        return value
    default:
        showError("Unknown error")
        return 0.0
    }
}

func calculate(inStr: String) -> Double {
    var expr = parseExpression(inStr)
    expr = infixToPostfix(expr)
    return evaluate(expr)
}

//MARK: Additionals

func checkBuffer(buffer: String) -> Op? {
    if let op = Op.knownOps[buffer] {
        return op
    } else if let value = buffer.toDouble() {
        return Op.Operand(value)
    }
    return nil
}

//Error handling

func showError(error: String) {
    println("Error: \(error)")
    abort()
}

extension String {
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

//MARK: inputHandle

let result = calculate("cos(3)-exp(2)+5/(3+2)")
println("\(result)")

//if count(Process.arguments) == 2 {
//    println(NSString(format: "Result: %.5f", calculate(Process.arguments[1])))
//} else {
//    showError("Invalid argument")
//}