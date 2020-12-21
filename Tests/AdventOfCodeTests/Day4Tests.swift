//
//  File.swift
//
//
//  Created by Griff on 12/19/20.
//

import ParserCombinator
import XCTest

// https://adventofcode.com/2020/day/4
//
// byr (Birth Year)
// iyr (Issue Year)
// eyr (Expiration Year)
// hgt (Height)
// hcl (Hair Color)
// ecl (Eye Color)
// pid (Passport ID)
// cid (Country ID)

private typealias P = Parser

final class Day4Tests: XCTestCase {
    let input = resourceURL(filename: "Day4Input.txt").flatMap(stringFromURL)!

    let example = """
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in
    """

    let onePassport = """
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm
    """

    func testParsePassportField() {
        let tests: [String] = [
            "ecl:gry",
            "pid:860033327",
            "eyr:2020",
            "hcl:#fffffd",
            "byr:1937",
            "iyr:2017",
            "cid:147",
            "hgt:183cm",
        ]

        tests.forEach { test in
            let result = Self.passportField.match(test)
            XCTAssertNotNil(result, test)
        }
    }

    func testParseOnePassport() {
        let result = Self.passport.match(onePassport)
        XCTAssertNotNil(result)
    }

    func testParseExample() {
        let passports = Self.passports.match(example)
        XCTAssertEqual(passports?.count, 4)
    }

    func testIsValidExample() {
        let passports = Self.passports
            .map { $0.filter(\.isValid) }
            .match(example)
        XCTAssertEqual(passports?.count, 2)
    }

    func testIsValidInput() {
        let passports = Self.passports
            .map { $0.filter(\.isValid) }
            .match(input)
        XCTAssertEqual(passports?.count, 228)
    }

    // MARK: - part 2

    let invalid2Examples = """
    eyr:1972 cid:100
    hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

    iyr:2019
    hcl:#602927 eyr:1967 hgt:170cm
    ecl:grn pid:012533040 byr:1946

    hcl:dab227 iyr:2012
    ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

    hgt:59cm ecl:zzz
    eyr:2038 hcl:74454a iyr:2023
    pid:3556412378 byr:2007
    """

    let valid2Examples = """
    pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
    hcl:#623a2f

    eyr:2029 ecl:blu cid:129 byr:1989
    iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

    hcl:#888785
    hgt:164cm byr:2001 iyr:2015 cid:88
    pid:545766238 ecl:hzl
    eyr:2022

    iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    """

    func testIsInvalid2FieldExample() {
        let passports = Self.passports
            .match(invalid2Examples)
        XCTAssertEqual(passports?.count, 4)

        let validPassports = passports!.filter(\.isValid2)
        XCTAssertEqual(validPassports.count, 0)
    }

    func testIsValid2FieldExample() {
        let passports = Self.passports
            .match(valid2Examples)
        XCTAssertEqual(passports?.count, 4)

        let validPassports = passports!.filter(\.isValid2)
        XCTAssertEqual(validPassports.count, 4)
    }

    func testIsValid2Input() {
        let passports = Self.passports
            .map { $0.filter(\.isValid2) }
            .match(input)

        XCTAssertEqual(passports?.count, 175)
    }
}

private extension Day4Tests {
    struct Passport {
        let fields: [Field]

        struct Field: CustomStringConvertible {
            let name: FieldName
            let value: String

            var description: String { "\(name):\(value)" }
        }

        var isValid: Bool {
            let fieldSet = Set(fields.map(\.name))
            return fieldSet.count == 8 ||
                (fieldSet.count == 7 && !fieldSet.contains(.cid))
        }

        var isValid2: Bool {
            let validFields = fields.filter { field in
                Day4Tests.isValueValid2(field.value,
                                        for: field.name)
            }

            let fieldSet = Set(validFields.map(\.name))
            return fieldSet.count == 8 ||
                (fieldSet.count == 7 && !fieldSet.contains(.cid))
        }
    }

    enum FieldName: String, CustomStringConvertible {
        case byr // (Birth Year)
        case iyr // (Issue Year)
        case eyr // (Expiration Year)
        case hgt // (Height)
        case hcl // (Hair Color)
        case ecl // (Eye Color)
        case pid // (Passport ID)
        case cid // (Country ID)

        var description: String { rawValue }
    }
}

private extension Day4Tests {
    static let passportField = zip(
        P.letters.asString.compactMap { FieldName(rawValue: $0) },
        P.character(":"),
        P.oneOf(.character("#"), .alphanum)
            .oneOrMore()
            .asString
    )
    .map { name, _, value in Passport.Field(name: name,
                                            value: value) }

    static let passportFields = passportField
        .oneOrMore(separatedBy: .oneOf(.space, .newline))

    static let passport = passportFields
        .map { fields in Passport(fields: fields) }

    static let passports = passport.oneOrMore(separatedBy: .newline)
}

private extension Day4Tests {
    // byr (Birth Year) - four digits; at least 1920 and at most 2002.
    // iyr (Issue Year) - four digits; at least 2010 and at most 2020.
    // eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
    // hgt (Height) - a number followed by either cm or in:
    // If cm, the number must be at least 150 and at most 193.
    // If in, the number must be at least 59 and at most 76.
    // hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
    // ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
    // pid (Passport ID) - a nine-digit number, including leading zeroes.
    // cid (Country ID) - ignored, missing or not.

    static func year(atLeast: Int, atMost: Int)
        -> Parser<[Character]>
    {
        P.digit.takeCount(4)
            .filter { yearChars in
                guard let year = yearChars.asInt else { return false }
                return atLeast <= year && year <= atMost
            }
    }

    static let heightCM = zip(.digits, "cm").filter { height, _ in
        guard let height = height.asInt else { return false }
        return height >= 150 && height <= 193
    }

    static let heightIN = zip(.digits, "in").filter { height, _ in
        guard let height = height.asInt else { return false }
        return height >= 59 && height <= 76
    }

    static let height = P.oneOf(heightCM, heightIN)
        .map { $0 + $1 }

    static let hairColor = zip("#",
                               P.character(in: "0123456789abcdef").takeCount(6))
        .map { $0 + $1 }

    static let eyeColor = P.oneOf("amb", "blu", "brn", "gry", "grn", "hzl", "oth")

    static func isValueValid2(_ value: String,
                              for fieldName: FieldName) -> Bool
    {
        switch fieldName {
        case .byr:
            return year(atLeast: 1920, atMost: 2002).matches(value)
        case .iyr:
            return year(atLeast: 2010, atMost: 2020).matches(value)
        case .eyr:
            return year(atLeast: 2020, atMost: 2030).matches(value)
        case .hgt:
            return height.matches(value)
        case .hcl:
            return hairColor.matches(value)
        case .ecl:
            return eyeColor.matches(value)
        case .pid:
            return P.digit.takeCount(9).matches(value)
        case .cid:
            return P.alphanum.matches(value)
        }
    }
}
