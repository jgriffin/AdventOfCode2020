//
//  Memoize.swift
//
//
//  Created by Griff on 12/24/20.
//

import Foundation

public func memoize<X: Hashable, Y>(_ fn: @escaping ((X) -> Y, X) -> Y) -> (X) -> Y {
    var cache = [X: Y]()

    func wrapper(x: X) -> Y {
        if let y = cache[x] {
            return y
        }

        let y = fn(wrapper, x)
        cache[x] = y
        return y
    }

    return wrapper
}
