//
//  File.swift
//
//
//  Created by Griff on 12/21/20.
//

import Foundation
import ParserCombinator

struct ColoredBags {
    typealias P = Parser

    struct Bag: Hashable, CustomStringConvertible {
        let pattern: String
        let color: String
        var description: String { "\(pattern) \(color)" }
    }

    struct BagCount: CustomStringConvertible {
        let count: Int
        let bag: Bag
        var description: String { "\(count) \(bag)" }
    }

    enum Contents: CustomStringConvertible {
        case containsBagCounts([BagCount])
        case noOtherBags

        var bags: Set<Bag>? {
            switch self {
            case let .containsBagCounts(containsBagCounts):
                return containsBagCounts.map(\.bag).asSet
            case .noOtherBags:
                return nil
            }
        }

        var description: String {
            switch self {
            case let .containsBagCounts(contents):
                let cstring = contents.map(\.description).joined(separator: ", ")
                return "contains: \(cstring)"
            case .noOtherBags:
                return "no other bags"
            }
        }
    }

    struct Constraint: CustomStringConvertible {
        let bag: Bag
        let contents: Contents
        var description: String { "\(bag) contains \(contents)" }
    }

    // MARK: - methods

    static func constraintsFrom(_ constraints: [Constraint],
                                containing bag: Bag) -> [Constraint]
    {
        constraints
            .filter { $0.contents.bags?.contains(bag) ?? false }
    }
}

extension ColoredBags {
    class BagChecker {
        let constraints: [Constraint]
        let directlyContains: [Bag: Set<Bag>]
        let containedBy: [Bag: Set<Bag>]

        init(constraints: [Constraint]) {
            self.constraints = constraints

            let directlyContains = constraints
                .reduce(into: [Bag: Set<Bag>]()) { result, c in
                    result[c.bag] = (c.contents.bags ?? []).asSet
                }
            self.directlyContains = directlyContains

            containedBy = directlyContains
                .reduce(into: [Bag: Set<Bag>]()) { result, c_bags in
                    c_bags.value.forEach { b in
                        result[b, default: Set()].insert(c_bags.key)
                    }
                }
        }

        func constraintFor(_ bag: Bag) -> Constraint? {
            constraints.first(where: { $0.bag == bag })
        }

        func canContainsFor(_ bag: Bag) -> Set<Bag> {
            guard let directs = containedBy[bag] else {
                return Set()
            }

            let recurse = directs.flatMap(canContainsFor)
            return directs.union(recurse)
        }

        func mustContain(_ bag: Bag) -> Int {
            guard let constraint = constraintFor(bag) else {
                fatalError()
            }

            guard case let .containsBagCounts(bagCounts) = constraint.contents else {
                return 0
            }

            return bagCounts
                .map { bagCount in bagCount.count * (1 + mustContain(bagCount.bag)) }
                .reduce(0, +)
        }
    }
}

extension ColoredBags {
    // Parsers

    static let bag = P.letters.asString.takeCount(3, separatedBy: " ")
        .map { strings -> Bag in
            Bag(pattern: strings[0], color: strings[1])
        }

    static let numberOfBags = zip(P.digit.oneOrMore().asInt, " ", bag)
        .map { count, _, bag in BagCount(count: count, bag: bag) }

    static let noOtherBags = P.literal("no other bags")
        .map { _ in Contents.noOtherBags }

    static let contains = oneOf(
        numberOfBags.oneOrMore(separatedBy: ", ").map { Contents.containsBagCounts($0) },
        noOtherBags
    )

    static let constraint = zip(bag, " contain ", contains, ".")
        .map { bag, _, contents, _ in Constraint(bag: bag, contents: contents) }

    static let constraints = constraint.oneOrMore(separatedBy: "\n")
}
