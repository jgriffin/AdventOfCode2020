//
//  File.swift
//
//
//  Created by Griff on 12/24/20.
//

import AdventOfCode
import ParserCombinator
import XCTest

final class Day16Tests: XCTestCase {
    let input = resourceURL(filename: "Day16Input.txt")!.readContents()!

    let example = """
    class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50

    your ticket:
    7,1,14

    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12
    """

    let exampleTwo = """
    class: 0-1 or 4-19
    row: 0-5 or 8-19
    seat: 0-13 or 16-19

    your ticket:
    11,12,13

    nearby tickets:
    3,9,18
    15,1,5
    5,14,9
    """

    typealias IntRange = ClosedRange<Int>

    struct Rule {
        let name: String
        let range1: IntRange
        let range2: IntRange
    }

    typealias Ticket = [Int]

    struct RulesAndTickets {
        let rules: [Rule]
        let ticket: Ticket
        let nearbyTickets: [Ticket]

        let allRanges: [IntRange]

        internal init(rules: [Rule],
                      ticket: Ticket,
                      nearbyTickets: [Ticket])
        {
            self.rules = rules
            self.ticket = ticket
            self.nearbyTickets = nearbyTickets
            allRanges = rules.flatMap { rule in [rule.range1, rule.range2] }
        }

        // MARK: validRulesFotTicket

        func validRulesForTickets(_ tickets: [Ticket]) -> [Set<String>] {
            tickets
                .map(validRulesForTicket)
                .reduceFirst { result, next in
                    zip(result, next)
                        .map { l, r in
                            l.intersection(r)
                        }
                }
        }

        func validRulesForTicket(_ ticket: Ticket) -> [Set<String>] {
            ticket
                .map { value in
                    rules
                        .filter { rule in
                            rule.range1.contains(value) ||
                                rule.range2.contains(value)
                        }
                        .map(\.name)
                        .asSet
                }
        }

        // MARK: validitiy helpers

        func validTickets() -> [Ticket] {
            nearbyTickets
                .filter { !isInvalidTicket($0) }
        }

        func isInvalidTicket(_ ticket: Ticket) -> Bool {
            ticket.first(where: isInvalidValue) != nil
        }

        func invalidTicketValues(_ ticket: Ticket) -> [Int] {
            ticket
                .filter(isInvalidValue)
        }

        func isInvalidValue(_ int: Int) -> Bool {
            allRanges.first(where: { $0.contains(int) }) == nil
        }
    }
}

extension Day16Tests {
    func testValidTicketsExample() {
        let rulesAndTickets = Self.rulesAndTickets.match(example, completely: true)!
        let validTickets = rulesAndTickets.validTickets()
        XCTAssertEqual(validTickets.count, 1)
    }

    func testValidRulesForTicketExample() {
        let rulesAndTickets = Self.rulesAndTickets.match(example, completely: true)!
        let validTickets = rulesAndTickets.validTickets()
        let validRulesByTicket = validTickets.map(rulesAndTickets.validRulesForTicket)
        print(validRulesByTicket.interpolated)
    }

    func testValidRulesForInput() {
        let rulesAndTickets = Self.rulesAndTickets.match(input, completely: true)!
        let validTickets = rulesAndTickets.validTickets()
        let validRules = rulesAndTickets.validRulesForTicket(validTickets.first!)
        print(validRules.interpolated)
    }

    func testValidRulesForTicketsExample() {
        let rulesAndTickets = Self.rulesAndTickets.match(exampleTwo, completely: true)!
        let validRules = rulesAndTickets.validRulesForTickets(rulesAndTickets.validTickets())
        print(validRules.interpolated)

        let simplified = SetSimplifier.uniqueify(validRules)
        print(simplified.interpolated)
    }

    func testValidRulesForTicketsInput() {
        let rulesAndTickets = Self.rulesAndTickets.match(input, completely: true)!

        let validRules = rulesAndTickets.validRulesForTickets(rulesAndTickets.validTickets())

        let simplified = SetSimplifier.uniqueify(validRules)
        print(simplified.interpolated)

        let fieldNames = simplified.map { $0.first! }
        let ticketValues: [Int] = rulesAndTickets.ticket

        let ticketDepartureFields =
            zip(ticketValues, fieldNames)
                .compactMap { t, s -> Int? in
                    guard s.hasPrefix("departure") else { return nil }
                    return t
                }
        print(ticketDepartureFields)
        let multipled = ticketDepartureFields.reduce(1, *)
        XCTAssertEqual(multipled, 10_458_887_314_153)
    }
}

extension Day16Tests {
    func testParseComponents() {
        let rule = Self.rule.match("class: 1-3 or 5-7")
        XCTAssertNotNil(rule)

        let rules = Self.rules.match(example, completely: false)
        XCTAssertNotNil(rules)
    }

    func testParseRulesExample() {
        let rulesAndTickets = Self.rulesAndTickets.match(example, completely: true)
        XCTAssertNotNil(rulesAndTickets)
    }

    func testParseRulesInput() {
        let rulesAndTickets = Self.rulesAndTickets.match(input, completely: true)
        XCTAssertNotNil(rulesAndTickets)
    }

    func testInvalidTicketValuesExample() {
        let rulesAndTickets = Self.rulesAndTickets.match(example, completely: true)!
        let invalidValues = rulesAndTickets.nearbyTickets
            .flatMap(rulesAndTickets.invalidTicketValues)
        XCTAssertEqual(invalidValues, [4, 55, 12])
        let invalidSum = invalidValues.reduce(0, +)
        XCTAssertEqual(invalidSum, 71)
    }

    func testInvalidTicketValuesinput() {
        let rulesAndTickets = Self.rulesAndTickets.match(input, completely: true)!
        let invalidValues = rulesAndTickets.nearbyTickets
            .flatMap(rulesAndTickets.invalidTicketValues)
        XCTAssertEqual(invalidValues.count, 53)
        let invalidSum = invalidValues.reduce(0, +)
        XCTAssertEqual(invalidSum, 23009)
    }
}

extension Day16Tests {
    typealias P = Parser
    static let range = P.integer.takeCount(2, separatedBy: "-")
        .map { $0.first! ... $0.last! }

    static let rule = zip(P.prefix(while: { $0 != ":" }).asString,
                          ": ",
                          range,
                          " or ",
                          range)
        .map { name, _, r1, _, r2 in Rule(name: name, range1: r1, range2: r2) }

    static let rules = rule.oneOrMore(separatedBy: "\n")

    static let ticket = P.integer.oneOrMore(separatedBy: ",")
    static let tickets = ticket.oneOrMore(separatedBy: "\n")

    static let rulesAndTickets = zip(rules,
                                     P.newlines,
                                     "your ticket:\n",
                                     ticket,
                                     "\n\nnearby tickets:\n",
                                     tickets,
                                     P.whitespaceAndNewline.zeroOrMore())
        .map { rules, _, _, ticket, _, tickets, _ in RulesAndTickets(rules: rules,
                                                                     ticket: ticket,
                                                                     nearbyTickets: tickets) }
}
