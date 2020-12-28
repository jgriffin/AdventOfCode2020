//
//  Indexing.swift
//
//
//  Created by Griff on 12/27/20.
//

import Foundation

public struct Index2D: Indexing, CustomStringConvertible {
    public var x, y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public var components: [Int] { [x, y] }

    public static var componentCount: Int { 2 }

    public static func fromComponents(_ components: [Int]) -> Index2D {
        assert(components.count == 2)
        return .init(components[0], components[1])
    }

    public static func indicesInRange(_ range: IndexingRange<Self>) -> [Self] {
        (range.min.y ... range.max.y).flatMap { y in
            (range.min.x ... range.max.x).map { x in
                Self(x, y)
            }
        }
    }

    public static let zero = Self.makeZero()
    public static let unitPlus = Self.makeUnitPlus()
    public static let unitMinus = Self.makeUnitMinus()
    public static let neighborOffsets = Self.makeNeighborOffsets()
}

public struct Index3D: Indexing, CustomStringConvertible {
    public var x, y, z: Int

    public init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var components: [Int] { [x, y, z] }

    public static var componentCount: Int { 3 }

    public static func fromComponents(_ components: [Int]) -> Index3D {
        assert(components.count == 3)
        return .init(components[0], components[1], components[2])
    }

    public static func indicesInRange(_ range: IndexingRange<Self>) -> [Self] {
        (range.min.z ... range.max.z).flatMap { z in
            (range.min.y ... range.max.y).flatMap { y in
                (range.min.x ... range.max.x).map { x in
                    Self(x, y, z)
                }
            }
        }
    }

    public static let zero = Self.makeZero()
    public static let unitPlus = Self.makeUnitPlus()
    public static let unitMinus = Self.makeUnitMinus()
    public static let neighborOffsets = Self.makeNeighborOffsets()
}

public struct Index4D: Indexing, CustomStringConvertible {
    public var x, y, z, zz: Int

    public init(_ x: Int, _ y: Int, _ z: Int, _ zz: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.zz = zz
    }

    public var components: [Int] { [x, y, z, zz] }

    public static var componentCount: Int { 4 }

    public static func fromComponents(_ components: [Int]) -> Index4D {
        assert(components.count == 4)
        return .init(components[0], components[1], components[2], components[3])
    }

    public static func indicesInRange(_ range: IndexingRange<Self>) -> [Self] {
        (range.min.zz ... range.max.zz).flatMap { zz in
            (range.min.z ... range.max.z).flatMap { z in
                (range.min.y ... range.max.y).flatMap { y in
                    (range.min.x ... range.max.x).map { x in
                        Self(x, y, z, zz)
                    }
                }
            }
        }
    }

    public static let zero = Self.makeZero()
    public static let unitPlus = Self.makeUnitPlus()
    public static let unitMinus = Self.makeUnitMinus()
    public static let neighborOffsets = Self.makeNeighborOffsets()
}
