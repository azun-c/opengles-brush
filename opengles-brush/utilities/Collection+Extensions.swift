//
//  Collection+Extensions.swift
//  i-Reporter
//
//  Created by azun on 28/02/2024.
//  Copyright (c) 2024 CIMTOPS CORPORATION. All rights reserved.
//

import Foundation

extension Collection {
    public subscript(safe index: Self.Index) -> Self.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

extension NSMutableArray {
    public subscript(safe index: Int) -> Any? {
        (0..<count).contains(index) ? self[index] : nil
    }
}
