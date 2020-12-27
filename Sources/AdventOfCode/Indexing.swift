//
//  Indexing.swift
//
//
//  Created by Griff on 12/27/20.
//

import Foundation

public protocol Indexing: Hashable {
    static func indicesBetween(_: Self, _: Self) -> [Self]

    static var zero: Self { get }
    static var unitPlus: Self { get }
    static var unitMinus: Self { get }

    static var neighborOffsets: [Self] { get }

    static func + (_: Self, _: Self) -> Self
    static func min(_: Self, _: Self) -> Self
    static func max(_: Self, _: Self) -> Self
}

public extension Indexing {
    static func calculateNeighborOffsets() -> [Self] {
        indicesBetween(.unitMinus, .unitPlus)
            .filter { $0 != .zero }
    }
}

public struct Index2D: Indexing, CustomStringConvertible {
    public var x, y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public var description: String { "\(x),\(y)" }

    public static let zero = Self(0, 0)
    public static let unitPlus = Self(1, 1)
    public static let unitMinus = Self(-1, -1)

    public static let neighborOffsets = Self.calculateNeighborOffsets()

    public static func indicesBetween(_ i1: Self,
                                      _ i2: Self) -> [Self]
    {
        (i1.y ... i2.y).flatMap { y in
            (i1.x ... i2.x).map { x in
                Self(x, y)
            }
        }
    }

    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        .init(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    public static func min(_ lhs: Self, _ rhs: Self) -> Self {
        .init(Swift.min(lhs.x, rhs.x), Swift.min(lhs.y, rhs.y))
    }

    public static func max(_ lhs: Self, _ rhs: Self) -> Self {
        .init(Swift.max(lhs.x, rhs.x), Swift.max(lhs.y, rhs.y))
    }
}

public struct Index3D: Indexing, CustomStringConvertible {
    public var x, y, z: Int

    public init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var description: String { "\(x),\(y),\(z)" }

    public static let zero = Self(0, 0, 0)
    public static let unitPlus = Self(1, 1, 1)
    public static let unitMinus = Self(-1, -1, -1)

    public static let neighborOffsets = Self.calculateNeighborOffsets()

    public static func indicesBetween(_ i1: Self,
                                      _ i2: Self) -> [Self]
    {
        (i1.z ... i2.z).flatMap { z in
            (i1.y ... i2.y).flatMap { y in
                (i1.x ... i2.x).map { x in
                    Self(x, y, z)
                }
            }
        }
    }

    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        .init(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    public static func min(_ lhs: Self, _ rhs: Self) -> Self {
        .init(Swift.min(lhs.x, rhs.x), Swift.min(lhs.y, rhs.y), Swift.min(lhs.z, rhs.z))
    }

    public static func max(_ lhs: Self, _ rhs: Self) -> Self {
        .init(Swift.max(lhs.x, rhs.x), Swift.max(lhs.y, rhs.y), Swift.max(lhs.z, rhs.z))
    }
}

public struct Index4D: Indexing, CustomStringConvertible {
    public var x, y, z, zz: Int

    public init(_ x: Int, _ y: Int, _ z: Int, _ zz: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.zz = zz
    }

    public var description: String { "\(x),\(y),\(z),\(zz)" }

    public static let zero = Self(0, 0, 0, 0)
    public static let unitPlus = Self(1, 1, 1, 1)
    public static let unitMinus = Self(-1, -1, -1, -1)

    public static let neighborOffsets = Self.calculateNeighborOffsets()

    public static func indicesBetween(_ i1: Self,
                                      _ i2: Self) -> [Self]
    {
        (i1.zz ... i2.zz).flatMap { zz in
            (i1.z ... i2.z).flatMap { z in
                (i1.y ... i2.y).flatMap { y in
                    (i1.x ... i2.x).map { x in
                        Self(x, y, z, zz)
                    }
                }
            }
        }
    }

    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        .init(lhs.x + rhs.x,
              lhs.y + rhs.y,
              lhs.z + rhs.z,
              lhs.zz + rhs.zz)
    }

    public static func min(_ lhs: Self, _ rhs: Self) -> Self {
        .init(Swift.min(lhs.x, rhs.x),
              Swift.min(lhs.y, rhs.y),
              Swift.min(lhs.z, rhs.z),
              Swift.min(lhs.zz, rhs.zz))
    }

    public static func max(_ lhs: Self, _ rhs: Self) -> Self {
        .init(Swift.max(lhs.x, rhs.x),
              Swift.max(lhs.y, rhs.y),
              Swift.max(lhs.z, rhs.z),
              Swift.max(lhs.zz, rhs.zz))
    }
}
