//
//  main.swift
//  Chains
//
//  Created by Андрей Рычков on 09.03.15.
//  Copyright (c) 2015 Андрей Рычков. All rights reserved.
//

import Foundation

var a = [
    [0, 1, 1, 0, 0],
    [0, 0, 1, 0, 0],
    [1, 1, 0, 0, 0],
    [0, 1, 0, 0, 1],
    [0, 0, 0, 0, 0]
]

let n = 5
let path = 3

for var j = 0; j < n; ++j {
    a[j][j] = 0
}

var b = a
var c = a

for var i = 0; i < path-1; ++i {
    
    for var row = 0; row < n; ++row {
        for var col = 0; col < n; ++col {
            for var inner = 0; inner < n; ++inner {
                if a[row][inner] + b[inner][col] == 2 {
                    c[row][col] = 1
                    break
                } else {
                    c[row][col] = 0
                }
            }
        }
    }
    
    for var j = 0; j < n; ++j {
        c[j][j] = 0
    }
    
    a = c
}

for var i = 0; i < n; ++i {
    println(c[i])
}

