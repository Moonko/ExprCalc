//
//  main.swift
//  SimpleChains
//
//  Created by Андрей Рычков on 10.03.15.
//  Copyright (c) 2015 Андрей Рычков. All rights reserved.
//

import Foundation

let path = 2

var a = [
    [0, 1, 1, 0, 0],
    [0, 0, 1, 0, 0],
    [1, 1, 0, 0, 0],
    [0, 1, 0, 0, 1],
    [0, 0, 0, 0, 0]
]

let n = 5

var verteces = [Int]()
var visited = Array(count: n, repeatedValue: false)

var k = 0

func dfs(u: Int) {
    visited[u] = true
    verteces.append(u)
    
    if k == path {
        println(verteces)
    } else {
        for var col = 0; col < n; ++col {
            if a[u][col] == 1 && visited[col] == false {
                k++
                dfs(col)
            }
        }
    }
    verteces.removeLast()
    visited[u] = false
    k == 0 ? k : --k
}

for var i = 0; i < n; ++i {
    dfs(i)
}
