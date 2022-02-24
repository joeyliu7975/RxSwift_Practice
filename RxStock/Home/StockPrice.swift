//
//  StockPrice.swift
//  RxStock
//
//  Created by JiaSin Liu on 2022/2/24.
//

import Foundation
import RxSwift
import RxCocoa

struct StockPrice {
    public let symbol: String
    public let isFavorite: Bool
    
    private let price = BehaviorRelay<Double>(value: 0)
    var priceObservable: Observable<Double> {
        price.asObservable()
    }
    
    init(symbol: String, isFavorite: Bool) {
        self.symbol = symbol
        self.isFavorite = isFavorite
    }
}
