//
//  ViewModel.swift
//  RxStock
//
//  Created by JiaSin Liu on 2022/2/24.
//

import Foundation
import RxSwift
import RxCocoa
// Input
protocol ViewModelInput {
    func refresh()
    func search(keyword: String)
    func didClickIsFavoriteSwitch()
}
// Output
protocol ViewModelOutput {
    var prices: Observable<[StockPrice]> { get }
}

protocol ViewModelType {
    var inputs: ViewModelInput { get }
    var outputs: ViewModelOutput { get }
}

struct ViewModel: ViewModelType {
    private let allPricesBehaviorRelay = BehaviorRelay<[StockPrice]>(value: [])
    fileprivate let pricesBehaviorRelay = BehaviorRelay<[StockPrice]>(value: [])
    
    var inputs: ViewModelInput { self }
    var outputs: ViewModelOutput { self }
}

extension ViewModel: ViewModelInput {
    func refresh() {}
    
    func search(keyword: String) {}
    
    func didClickIsFavoriteSwitch() {}
}

extension ViewModel: ViewModelOutput {
    var prices: Observable<[StockPrice]> {
        pricesBehaviorRelay.asObservable()
    }
}
