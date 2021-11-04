//
//  ModuloUtils.swift
//
//
//  Created by Griff on 1/2/21.
//

import Foundation

public enum ModuloUtils {
    public static func numberAtLeast(_ atLeast: Int,
                                     whereModulo mod: Int,
                                     equals d: Int) -> Int
    {
        guard mod != 0 else { return 0 }

        var n = atLeast - (atLeast % mod) + d
        if n < atLeast {
            n += mod
        }

        return n
    }
}
