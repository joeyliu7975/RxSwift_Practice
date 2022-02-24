//
//  Collection+Extension.swift
//  RxStock
//
//  Created by JiaSin Liu on 2022/2/24.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
