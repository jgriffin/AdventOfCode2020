//
//  IntLoc.swift
//
//
//  Created by Griff on 12/19/20.
//

import Foundation

public struct IntLoc: Equatable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public extension IntLoc {
    static func + (_ lhs: IntLoc, _ rhs: IntLoc) -> IntLoc {
        .init(x: lhs.x + rhs.x,
              y: lhs.y + rhs.y)
    }

    static func += (_ lhs: inout IntLoc, _ rhs: IntLoc) {
        lhs = lhs + rhs
    }
}
