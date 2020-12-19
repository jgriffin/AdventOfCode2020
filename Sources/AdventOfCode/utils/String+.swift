//
//  File.swift
//
//
//  Created by Griff on 12/19/20.
//

import Foundation

public extension String {
    func splitLines() -> [Substring] {
        split(separator: "\n")
    }
}
