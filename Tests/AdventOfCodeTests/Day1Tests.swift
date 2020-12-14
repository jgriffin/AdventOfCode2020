import AdventOfCode
import Algorithms
import XCTest

final class Day1TestsTests: XCTestCase {
    let input = resourceURL(filename: "Day1Input.txt")
        .flatMap(stringFromURL)

    func testReadInput() {
        XCTAssertNotNil(input)
        XCTAssertEqual(input!.lines().count, 200)
    }

    func testFind2Sum2020() {
        let numbers = input!.lines().map { Int($0)! }
        let sumsTo2020 = numbers
            .combinations(ofCount: 2)
            .filter { combo in combo.reduce(0, +) == 2020 }
            .only()!

        XCTAssertEqual(sumsTo2020, [1084, 936])
        let product = sumsTo2020.reduce(1, *)
        XCTAssertEqual(product, 1014624)
    }

    func testFind3Sum2020() {
        let numbers = input!.lines().map { Int($0)! }
        let sumsTo2020 = numbers
            .combinations(ofCount: 3)
            .filter { combo in combo.reduce(0, +) == 2020 }
            .only()!

        XCTAssertEqual(sumsTo2020, [704, 1223, 93])
        let product = sumsTo2020.reduce(1, *)
        XCTAssertEqual(product, 80072256)
    }
}
