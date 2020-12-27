//
//  Day18Tests.swift
//
//
//  Created by Griff on 12/26/20.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day18Tests: XCTestCase {
    let input = resourceURL(filename: "Day18Input.txt")!.readContents()!

    let example = """
    1 + 2 * 3 + 4 * 5 + 6
    2 * 3 + (4 * 5)
    5 + (8 * 3 + 9 + 3 * 4 * 3)
    5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
    ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
    """
}

extension Day18Tests {
    func testParseComponents() {
        let result = Self.expression.run("1 + 2 * 3 + 4 * 5 + 6")
        XCTAssertEqual(result.match.interpolated, "1 + 2 * 3 + 4 * 5 + 6")
        XCTAssert(result.rest.isEmpty)

        let result2 = Self.expression.run("2 * 3 + (4 * 5)")
        XCTAssertEqual(result2.match.interpolated, "2 * 3 + (4 * 5)")
        XCTAssert(result2.rest.isEmpty)
    }

    // MARK: parser

    func testParseExamples() {
        let examples = Self.expression.oneOrMore(separatedBy: "\n").match(example)!
        XCTAssertEqual(examples.count, 5)
    }

    func testParseInput() {
        let expressions = Self.expression.oneOrMore(separatedBy: "\n")
            .ignoring(P.whitespacesAndNewlines)
            .match(input)!
        XCTAssertEqual(expressions.count, 374)
        XCTAssertTrue(expressions.last.interpolated.hasSuffix("+ (9 * 6 * 4 + 9)) + 4 + 6"))
    }

    // MARK: - evaluate 1

    func testEvaluateExamples() {
        let examples = Self.expression.oneOrMore(separatedBy: "\n").match(example)!
        let results = examples.map(Evaluator.evaluate)
        XCTAssertEqual(results, [71, 26, 437, 12240, 13632])
    }

    func testEvaluateInput() {
        let expressions = Self.expression.oneOrMore(separatedBy: "\n")
            .ignoring(P.whitespacesAndNewlines)
            .match(input)!
        let results = expressions.map(Evaluator.evaluate)
        let sumOfResults = results.reduce(0,+)

        XCTAssertEqual(sumOfResults, 13_976_444_272_545)
    }

    // MARK: evaluate 2

    func testEvaluate2Examples() {
        let examples = Self.expression.oneOrMore(separatedBy: "\n").match(example)!
        let results = examples.map(Evaluator2.evaluate)
        XCTAssertEqual(results, [231, 46, 1445, 669_060, 23340])
    }

    func testEvaluate2Input() {
        let expressions = Self.expression.oneOrMore(separatedBy: "\n")
            .ignoring(P.whitespacesAndNewlines)
            .match(input)!
        let results = expressions.map(Evaluator2.evaluate)
        let sumOfResults = results.reduce(0,+)

        XCTAssertEqual(sumOfResults, 88_500_956_630_893)
    }
}

extension Day18Tests {
    enum Evaluator {
        static func evaluate(_ expression: Expression) -> Int {
            switch expression {
            case let .opExpression(factor, opExpression):
                return evaluate(acc: evaluate(factor),
                                opExpression)
            case let .factor(factor):
                return evaluate(factor)
            }
        }

        static func evaluate(acc: Int,
                             _ opExpression: OpExpression) -> Int
        {
            switch opExpression {
            case let .last(op, f):
                return evaluate(op, acc, evaluate(f))
            case let .continued(op, f, continuation):
                let acc = evaluate(op, acc, evaluate(f))
                return evaluate(acc: acc, continuation)
            }
        }

        static func evaluate(_ factor: Factor) -> Int {
            switch factor {
            case let .number(number):
                return number
            case let .parenthesized(expression):
                return evaluate(expression)
            }
        }

        static func evaluate(_ op: Operator,
                             _ lhs: Int,
                             _ rhs: Int) -> Int
        {
            switch op {
            case .add: return lhs + rhs
            case .multiply: return lhs * rhs
            }
        }
    }

    enum Evaluator2 {
        static func evaluate(_ expression: Expression) -> Int {
            switch expression {
            case let .opExpression(factor, opExpression):
                return evaluate(acc: evaluate(factor),
                                opExpression)
            case let .factor(factor):
                return evaluate(factor)
            }
        }

        static func evaluate(acc: Int,
                             _ opExpression: OpExpression) -> Int
        {
            switch opExpression {
            case let .last(op, f):
                return evaluate(op, acc, evaluate(f))

            case let .continued(.add, f, continuation):
                let acc = evaluate(.add, acc, evaluate(f))
                return evaluate(acc: acc, continuation)

            case let .continued(.multiply, f, continuation):
                // addition first
                let associateRight = evaluate(acc: evaluate(f),
                                              continuation)
                return evaluate(.multiply, acc, associateRight)
            }
        }

        static func evaluate(_ factor: Factor) -> Int {
            switch factor {
            case let .number(number):
                return number
            case let .parenthesized(expression):
                return evaluate(expression)
            }
        }

        static func evaluate(_ op: Operator,
                             _ lhs: Int,
                             _ rhs: Int) -> Int
        {
            switch op {
            case .add: return lhs + rhs
            case .multiply: return lhs * rhs
            }
        }
    }
}

extension Day18Tests {
    indirect enum Expression: CustomStringConvertible {
        case opExpression(Factor, OpExpression)
        case factor(Factor)

        var description: String {
            switch self {
            case let .opExpression(f, oe): return "\(f)\(oe)"
            case let .factor(f): return "\(f)"
            }
        }
    }

    indirect enum OpExpression: CustomStringConvertible {
        case last(Operator, Factor)
        case continued(Operator, Factor, OpExpression)

        var description: String {
            switch self {
            case let .last(op, factor):
                return " \(op) \(factor)"
            case let .continued(op, f, oe):
                return " \(op) \(f)\(oe)"
            }
        }
    }

    enum Factor: CustomStringConvertible {
        case number(Int)
        case parenthesized(Expression)

        var description: String {
            switch self {
            case let .number(n): return "\(n)"
            case let .parenthesized(e): return "(\(e))"
            }
        }
    }

    enum Operator: CustomStringConvertible {
        case add, multiply

        var description: String {
            switch self {
            case .add: return "+"
            case .multiply: return "*"
            }
        }
    }
}

extension Day18Tests {
    typealias P = Parser

    static var expression: P<Expression> {
        P.lazy(
            oneOf(
                zip(factor, opExpression)
                    .map { f, oe in Expression.opExpression(f, oe) },
                factor.map { Expression.factor($0) }
            )
        )
    }

    static var opExpression: Parser<OpExpression> {
        P.lazy(
            oneOf(
                zip(P.space, anOperator, P.space, factor, Self.opExpression)
                    .map { _, op, _, f, continued in OpExpression.continued(op, f, continued) },
                zip(P.space, anOperator, P.space, factor)
                    .map { _, op, _, f in OpExpression.last(op, f) }
            )
        )
    }

    static var factor: P<Factor> {
        oneOf(number.map { Factor.number($0) },
              parenthesizedExpression)
    }

    static var parenthesizedExpression: P<Factor> {
        zip("(", expression, ")")
            .map { _, e, _ in Factor.parenthesized(e) }
    }

    static let anOperator = oneOf(P.literal("+").map { _ in Operator.add },
                                  P.literal("*").map { _ in Operator.multiply })

    static let number = P.integer
}
