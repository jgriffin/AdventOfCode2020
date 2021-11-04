//
//  ModuloUtilsTests.swift
//
//
//  Created by Griff on 1/2/21.
//

import AdventOfCode
import XCTest

final class ModuloUtilsTests: XCTestCase {
    typealias M = ModuloUtils

    func testNumberAtLeast() {
        let tests: [(atLeast: Int, mod: Int, d: Int, check: Int)] = [
            (0, 1, 0, 0),
            (0, 1, 1, 1),
            (0, 3, 2, 2),
            (100, 3, 2, 101),
            (101, 27, 7, 115),
        ]

        tests.forEach { test in
            let result = M.numberAtLeast(test.atLeast,
                                         whereModulo: test.mod,
                                         equals: test.d)
            XCTAssertEqual(result, test.check)
        }
    }
}
