//
//  Day19Tests.swift
//
//
//  Created by Griff on 1/1/21.
//

import ParserCombinator
import XCTest

final class Day19Tests: XCTestCase {
    let input = resourceURL(filename: "Day19Input.txt")!.readContents()!

    let example = """
    0: 4 1 5
    1: 2 3 | 3 2
    2: 4 4 | 5 5
    3: 4 5 | 5 4
    4: "a"
    5: "b"

    ababbb
    bababa
    abbbab
    aaabbb
    aaaabbb
    """

    let day2Rules = [
        NumberedRule(number: 8,
                     rule: .oneOrMore(.ruleNumber(42))),
        NumberedRule(number: 11,
                     rule: .subRules([
                         .oneOrMore(.ruleNumber(42)),
                         .ruleNumber(31),
                     ])),
    ]

//    let day2Rules = """
//    8: 42 | 42 8
//    11: 42 31 | 42 11 31
//    """
}

extension Day19Tests {
    func testMessagePassingExample() {
        let rulesAndMessages = Self.rulesAndMessages.match(example)!

        let result = rulesAndMessages.messagesPassingRule(no: 0)
        XCTAssertEqual(result, ["ababbb", "abbbab"])
    }

    func testMessagePassingInput() {
        let rulesAndMessages = Self.rulesAndMessages.match(input)!

        let result = rulesAndMessages.messagesPassingRule(no: 0)
        XCTAssertEqual(result.count, 248)
    }

    func testMessagePassingDay2RulesInput() {
//        let ruleUpdates = Self.numberedRules.match(day2Rules)!
        let rulesAndMessages = Self.rulesAndMessages.match(input)!
            .withChangedRules(day2Rules)

        let result = rulesAndMessages.messagesPassingRule(no: 0)
        XCTAssertEqual(result, ["ababbb", "abbbab"])
    }
}

extension Day19Tests {
    struct RulesAndMessages {
        var rulesByNo: [Int: NumberedRule]
        let messages: [String]

        func ruleNumber(_ no: Int) -> Rule {
            guard let ruleNo = rulesByNo[no] else { fatalError() }
            return ruleNo.rule
        }

        func messagesPassingRule(no: Int) -> [String] {
            let parser = parserFor(ruleNumber(no))

            return messages
                .filter { message in parser.match(message) != nil }
        }

        func parserFor(_ rule: Rule) -> Parser<Void> {
            switch rule {
            case let .character(ch):
                return P.character(ch).map { _ in () }

            case let .ruleNumber(no):
                return parserFor(ruleNumber(no))

            case let .subRules(subRules):
                let subParsers = subRules
                    .map(parserFor)
                return sequence(subParsers)
                    .map { _ in () }

            case let .oneOf(oneOfRules):
                let oneOfRuleParsers = oneOfRules
                    .map(parserFor)
                    .map(\.lazy)

                return oneOf(oneOfRuleParsers)
                    .map { _ in () }
                    .lazy

            case let .oneOrMore(subRule):
                return parserFor(subRule).oneOrMore()
                    .map { _ in () }
            }
        }

        func withChangedRules(_ updates: [NumberedRule]) -> RulesAndMessages {
            let updatesToMerge = updates.reduce(into: [Int: NumberedRule]()) { result, next in
                result[next.number] = next
            }

            let updatedRules = rulesByNo.merging(updatesToMerge) { _, rhs in rhs }

            return RulesAndMessages(rulesByNo: updatedRules,
                                    messages: messages)
        }
    }

    struct NumberedRule {
        let number: Int
        let rule: Rule
    }

    indirect enum Rule {
        case character(Character)
        case ruleNumber(Int)
        case subRules([Rule])
        case oneOf([Rule])
        case oneOrMore(Rule)
    }
}

extension Day19Tests {
    func testParseComponents() {
        let characterRule = Self.characterRule.match("\"a\"")
        XCTAssertNotNil(characterRule)

        let subrule = Self.subRules.match("4 1 5")
        XCTAssertNotNil(subrule)

        let oneOfSubrule = Self.oneOfSubRules.match("2 3 | 3 2")
        XCTAssertNotNil(oneOfSubrule)

        let numberedRule = Self.numberedRule.match("3: 4 5 | 5 4")
        XCTAssertNotNil(numberedRule)

        let numberedRules = Self.numberedRules.match("""
        3: 4 5 | 5 4
        4: "a"
        """)
        XCTAssertEqual(numberedRules?.count, 2)

        let messages = Self.messages.match("""
        ababbb
        bababa
        """)
        XCTAssertEqual(messages?.count, 2)
    }

    func testParseExample() {
        let rulesAndMessages = Self.rulesAndMessages.match(example)
        XCTAssertEqual(rulesAndMessages?.rulesByNo.count, 6)
        XCTAssertEqual(rulesAndMessages?.messages.count, 5)
    }

//    func testParseDay2() {
//        let day2 = Self.numberedRules.match(day2RulesInput)
//        XCTAssertNotNil(day2)
//    }
}

extension Day19Tests {
    typealias P = Parser

    static let characterRule = zip("\"", P.letter, "\"")
        .map { _, ch, _ in Rule.character(ch) }
    static let subRules = P.integer.oneOrMore(separatedBy: " ")
        .map { numbers -> Rule in
            let rules = numbers.map { Rule.ruleNumber($0) }
            return Rule.subRules(rules)
        }

    static let oneOfSubRules = subRules.oneOrMore(separatedBy: " | ")
        .map { subrules in Rule.oneOf(subrules) }
    static let numberedRule = zip(P.integer, ": ", oneOf(oneOfSubRules,
                                                         subRules,
                                                         characterRule))
        .map { no, _, rule in NumberedRule(number: no, rule: rule) }
    static let numberedRules = numberedRule.oneOrMore(separatedBy: "\n")

    static let messages = P.letters.asString.zeroOrMore(separatedBy: "\n")

    static let rulesAndMessages =
        zip(numberedRules,
            "\n\n",
            messages)
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
        .map { rules, _, messages -> RulesAndMessages in
            let rulesById = rules.reduce(into: [Int: NumberedRule]()) { result, next in
                result[next.number] = next
            }

            return RulesAndMessages(rulesByNo: rulesById,
                                    messages: messages)
        }
}
