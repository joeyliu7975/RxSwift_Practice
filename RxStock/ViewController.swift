//
//  ViewController.swift
//  RxStock
//
//  Created by JiaSin Liu on 2022/2/23.
//

import UIKit
import RxSwift
import RxCocoa

class StockPrice {
    public let symbol: String
    public var isFavorite: Bool = false
    
    private let price = BehaviorRelay<Double>(value: 0)
    var priceObservable: Observable<Double> {
        price.asObservable()
    }
    
    init(symbol: String, isFavorite: Bool) {
        self.symbol = symbol
        self.isFavorite = isFavorite
    }
    
    func update(_ price: Double) {
        self.price.accept(price)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet var favoriteSwitch: UISwitch!
    @IBOutlet var searchTerm: UITextField!
    @IBOutlet var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    // Inputs
    fileprivate let allSymbols = ["RZW", "UDP", "MTT", "RMB", "TWD", "ENS", "GB", "ASY"]
    fileprivate let allPrices = BehaviorRelay<[StockPrice]>(value: [])
    // Outputs
    fileprivate let prices = BehaviorRelay<[StockPrice]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: TableViewCell.reusedIdentifier, bundle: nil),
                           forCellReuseIdentifier: TableViewCell.reusedIdentifier)
        
        allPrices.accept(allSymbols.enumerated().map({ index, symbol in
            StockPrice(symbol: symbol, isFavorite: index % 2 == 0)
        }))
        bindUI()
    }
}

// MARK: Internal
extension ViewController {
    func bindUI() {
        let searchText = searchTerm
            .rx
            .text
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .map { $0 }
        
        searchText.subscribe()
            .disposed(by: disposeBag)
        
        Observable.combineLatest(allPrices.asObservable(),
                                 favoriteSwitch.rx.isOn,
                                 searchText,
        resultSelector: { currentPrices, onlyFavorites, search in
            return currentPrices.filter { price -> Bool in
                return self.shouldDisplayPrice(price: price, onlyFavorite: onlyFavorites, search: search ?? "")
            }
        })
            .bind(to: prices)
            .disposed(by: disposeBag)
        
        prices.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: TableViewCell.reusedIdentifier,
                                         cellType: TableViewCell.self)) { (_, price, cell) in
                cell.configure(price: price)
            }
            .disposed(by: disposeBag)
    }
    
    func shouldDisplayPrice(price: StockPrice, onlyFavorite: Bool, search: String) -> Bool {
        guard !search.isEmpty else {
            return onlyFavorite == true ? price.isFavorite == onlyFavorite : true
        }
        
        return onlyFavorite == true ?
        (price.symbol.lowercased().contains(search.lowercased()) && price.isFavorite == onlyFavorite) :
        price.symbol.lowercased().contains(search.lowercased())
    }
}
