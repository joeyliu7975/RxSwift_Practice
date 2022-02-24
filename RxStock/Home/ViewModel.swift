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
    var isFavorites: Observable<Bool> { get }
}

protocol ViewModelType {
    var inputs: ViewModelInput { get }
    var outputs: ViewModelOutput { get }
}

struct ViewModel: ViewModelType {
    private let allSymbols: [String]
    private let allPricesBehaviorRelay = BehaviorRelay<[StockPrice]>(value: [])
    private let pricesBehaviorRelay = BehaviorRelay<[StockPrice]>(value: [])
    private let isFavoriteBehaviorRelay = BehaviorRelay<Bool>(value: false)
    private let searchTextBehaviorReplay = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    
    init(allSymbols: [String] = ["RZW", "UDP", "MTT", "RMB", "TWD", "ENS", "GB", "ASY"]) {
        self.allSymbols = allSymbols
        
        Observable.combineLatest(allPricesBehaviorRelay.asObservable(),
                                 isFavoriteBehaviorRelay.asObservable(),
                                 searchTextBehaviorReplay.asObservable(),
                resultSelector: { currentPrices, onlyFavorites, search in
                    return currentPrices.filter { price -> Bool in
                        return ViewModel.shouldDisplayPrice(price: price,
                                                            onlyFavorite: onlyFavorites,
                                                            search: search)
                    }
                })
                    .bind(to: pricesBehaviorRelay)
                    .disposed(by: disposeBag)
    }
    
    var inputs: ViewModelInput { self }
    var outputs: ViewModelOutput { self }
}

//MARK: Private function
private extension ViewModel {
    static func shouldDisplayPrice(price: StockPrice, onlyFavorite: Bool, search: String) -> Bool {
        guard !search.isEmpty else {
            return onlyFavorite == true ? price.isFavorite == onlyFavorite : true
        }
        
        return onlyFavorite == true ?
        (price.symbol.lowercased().contains(search.lowercased()) && price.isFavorite == onlyFavorite) :
        price.symbol.lowercased().contains(search.lowercased())
    }
}

extension ViewModel: ViewModelInput {
    func refresh() {
        allPricesBehaviorRelay.accept(allSymbols.enumerated().map({ index, symbol in
            StockPrice(symbol: symbol, isFavorite: index % 2 == 0)
        }))
    }
    
    func search(keyword: String) {
        searchTextBehaviorReplay.accept(keyword)
    }
    
    func didClickIsFavoriteSwitch() {
        isFavoriteBehaviorRelay.accept(!isFavoriteBehaviorRelay.value)
    }
}

extension ViewModel: ViewModelOutput {
    var prices: Observable<[StockPrice]> {
        pricesBehaviorRelay.asObservable()
    }
    
    var isFavorites: Observable<Bool> {
        isFavoriteBehaviorRelay.asObservable()
    }
}
