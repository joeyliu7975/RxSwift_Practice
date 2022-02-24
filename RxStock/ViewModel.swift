//
//  ViewModel.swift
//  RxStock
//
//  Created by JiaSin Liu on 2022/2/24.
//

import Foundation
// Input
protocol ViewModelInput {
    func refresh()
    func search(keyword: String)
    func didClickIsFavoriteSwitch()
}
// Output
protocol ViewModelOutput {}

protocol ViewModelType {
    var inputs: ViewModelInput { get }
    var outputs: ViewModelOutput { get }
}

struct ViewModel: ViewModelType {
    var inputs: ViewModelInput { self }
    var outputs: ViewModelOutput { self }
}

extension ViewModel: ViewModelInput {
    func refresh() {}
    
    func search(keyword: String) {}
    
    func didClickIsFavoriteSwitch() {}
}

extension ViewModel: ViewModelOutput {}
