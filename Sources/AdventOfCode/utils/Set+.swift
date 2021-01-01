//
//  File.swift
//
//
//  Created by Griff on 1/1/21.
//

import Foundation

public extension Set {
    mutating func toggle(_ e: Element) {
        if contains(e) {
            remove(e)
        } else {
            insert(e)
        }
    }

    mutating func toggle(_ es: [Element]) {
        es.forEach { toggle($0) }
    }
}
