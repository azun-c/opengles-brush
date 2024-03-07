//
//  ArrayExtensions.swift
//  i-Reporter
//
//  Created by KUROSAKI Ryota on 7/15/16.
//  Copyright © 2016 CIMTOPS CORPORATION. All rights reserved.
//

import Foundation

extension Array {

    mutating func removeIf(predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
        if let index = try self.firstIndex(where: predicate) {
            let element = self[index]
            self.remove(at: index)
            return element
        }
        return nil
    }

    func isDuplicated(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        if try filter(predicate).count >= 2 {
            return true
        } else {
            return false
        }
    }
    
    /// Returns the memory size/footprint (in bytes) of a given array.
    ///
    /// - Returns: Integer value representing the memory size the array.
    func size() -> Int {
        guard !isEmpty else { return 0 }
        return count * MemoryLayout.size(ofValue: self[0])
    }
}
