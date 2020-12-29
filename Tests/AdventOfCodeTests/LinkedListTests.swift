//
//  LinkedListTests.swift
//
//
//  Created by Griff on 12/28/20.
//

@testable import AdventOfCode
import XCTest

final class LinkedListTests: XCTestCase {
    func testEmptyList() {
        let emptyList = LinkedList<Int>(head: nil)
        XCTAssertEqual(emptyList.isEmpty, true)
        XCTAssertNil(emptyList.head)
        XCTAssertNil(emptyList.tail)
    }

    func testPushOneItem() {
        let list = LinkedList<Int>(head: nil)
        list.push(1)
        XCTAssertFalse(list.isEmpty)
        XCTAssertNotNil(list.first)
        XCTAssertNotNil(list.last)
    }

    func testPushTwoItem() {
        let list = LinkedList<Int>(head: nil)
        list.push(2)
        list.push(1)
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 2)
    }

    func testPopEmpty() {
        let list = LinkedList<Int>(head: nil)
        let result = list.pop()
        XCTAssertNil(result)
    }

    func testPushPopItem() {
        let list = LinkedList<Int>(head: nil)
        list.push(1)
        let result = list.pop()
        XCTAssertEqual(result, 1)
        XCTAssertTrue(list.isEmpty)
        XCTAssertNil(list.first)
        XCTAssertNil(list.last)
    }

    func testAppendEmpty() {
        let list = LinkedList<Int>(head: nil)
        list.append(1)
        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 1)
    }

    func testAppend() {
        let list = LinkedList<Int>(head: nil)
        list.push(1)
        list.append(2)
        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 2)
    }

    func testRemoveFirst() {
        let list = LinkedList<Int>(head: nil)
        list.push(1)

        let taken = list.removeFirst(1)
        XCTAssertEqual(taken.first?.value, 1)
        XCTAssertEqual(taken.last?.value, 1)
        XCTAssertNil(taken.last?.next)

        XCTAssertNil(list.first)
        XCTAssertNil(list.last)
    }

    func testRemoveFirstExtra() {
        let list = LinkedList<Int>(head: nil)
        list.push(1)

        let taken = list.removeFirst(2)
        XCTAssertEqual(taken.first?.value, 1)
        XCTAssertEqual(taken.last?.value, 1)
        XCTAssertNil(taken.last?.next)

        XCTAssertNil(list.first)
        XCTAssertNil(list.last)
    }

    func testRemoveFirstAfter() {
        let list = LinkedList<Int>(values: [1, 2, 3])

        let taken = list.removeFirst(1, after: list.first!)
        XCTAssertEqual(taken.first?.value, 2)
        XCTAssertEqual(taken.last?.value, 2)
        XCTAssertNil(taken.last?.next)

        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 3)
    }

    func testInsertValues() {
        let list = LinkedList<Int>.empty
        list.insert([3, 4])

        XCTAssertEqual(list.first?.value, 3)
        XCTAssertEqual(list.last?.value, 4)

        list.insert([1, 2])
        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 4)
    }

    func testInsertList() {
        let list = LinkedList<Int>.empty
        list.insert([3, 4])

        XCTAssertEqual(list.first?.value, 3)
        XCTAssertEqual(list.last?.value, 4)

        let list2 = LinkedList<Int>(values: [1, 2])
        list.insert(list2)
        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 4)
        XCTAssertNil(list.last?.next)
    }

    func testInsertListAfter() {
        let list = LinkedList<Int>(values: [1, 4])

        let list2 = LinkedList<Int>(values: [1, 2])
        list.insert(list2, after: list.first!)

        XCTAssertEqual(list.first?.value, 1)
        XCTAssertEqual(list.last?.value, 4)
        XCTAssertNil(list.last?.next)
    }

    func testNext() {
        let list = LinkedList<Int>(values: [1, 2, 3])
        XCTAssertEqual(list.first?.next(0)?.value, 1)
        XCTAssertEqual(list.first?.next(1)?.value, 2)
        XCTAssertEqual(list.first?.next(2)?.value, 3)
        XCTAssertEqual(list.first?.next(3)?.value, nil)
    }

    func testIterator() {
        let list = LinkedList<Int>(values: [1, 2, 3])
        let iterated = list.map(\.value)
        XCTAssertEqual(iterated, [1, 2, 3])
    }
}
