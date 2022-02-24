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
        tableView.delegate = self
        tableView.dataSource = self
        
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
            .subscribe(onNext: { price in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func shouldDisplayPrice(price: StockPrice, onlyFavorite: Bool, search: String) -> Bool {
        guard !search.isEmpty else {
            return onlyFavorite == true ? price.isFavorite == onlyFavorite : true
        }
        
        return onlyFavorite == true ?
        (price.symbol.contains(search) && price.isFavorite == onlyFavorite) :
        price.symbol.contains(search)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        prices.value.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TableViewCell,
              let stockPrice = prices.value[safe: indexPath.row] else { return }
        cell.configure(price: stockPrice)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reusedIdentifier, for: indexPath) as? TableViewCell else {
            fatalError("Cannot find \(TableViewCell.reusedIdentifier)")
        }
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
