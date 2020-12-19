//
//  File.swift
//
//
//  Created by Griff on 12/19/20.
//

import AdventOfCode
import XCTest

// https://adventofcode.com/2020/day/3

final class Day3Tests: XCTestCase {
    let input = resourceURL(filename: "Day3Input.txt")
        .flatMap(stringFromURL)!

    let example = """
    ..##.......
    #...#...#..
    .#....#..#.
    ..#.#...#.#
    .#...##..#.
    ..#.##.....
    .#.#.#....#
    .#........#
    #.##...#...
    #...##....#
    .#..#...#.#
    """

    func testReadInput() {
        print(example.splitLines())
    }

    func testExampleToboganRun() {
        let treeCount = toboganRun(CharGrid(string: example),
                                   slope: .init(x: 3, y: 1))
        XCTAssertEqual(treeCount, 7)
    }

    func testInputToboganRun() {
        let treeCount = toboganRun(CharGrid(string: input),
                                   slope: .init(x: 3, y: 1))
        XCTAssertEqual(treeCount, 148)
    }

    let slopes: [IntLoc] = [
        .init(x: 1, y: 1), .init(x: 3, y: 1), .init(x: 5, y: 1), .init(x: 7, y: 1), .init(x: 1, y: 2),
    ]

    func testExampleSlopes() {
        let treeCounts = toboganRuns(CharGrid(string: example),
                                     slopes: slopes)

        XCTAssertEqual(treeCounts.reduce(1,*), 336)
    }

    func testInputSlopes() {
        let treeCounts = toboganRuns(CharGrid(string: input),
                                     slopes: slopes)

        XCTAssertEqual(treeCounts.reduce(1,*), 727_923_200)
    }

    typealias Course = CharGrid
    typealias Slope = (right: Int, down: Int)

    func toboganRuns(_ course: Course, slopes: [IntLoc]) -> [Int] {
        slopes.map { slope in toboganRun(course, slope: slope) }
    }

    func toboganRun(_ course: Course, slope: IntLoc) -> Int {
        var treeCount = 0

        var loc = IntLoc(x: 0, y: 0)
        while loc.y < course.rows {
            if course[loc.colWrapped(course.cols)] != "." {
                treeCount += 1
            }

            loc += slope
        }

        return treeCount
    }
}

extension IntLoc {
    func colWrapped(_ cols: Int) -> IntLoc {
        .init(x: x % cols, y: y)
    }
}
