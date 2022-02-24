//
//  ViewController.swift
//  RxStock
//
//  Created by JiaSin Liu on 2022/2/23.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet var favoriteSwitch: UISwitch!
    @IBOutlet var searchTerm: UITextField!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: TableViewCell.reusedIdentifier, bundle: nil),
                               forCellReuseIdentifier: TableViewCell.reusedIdentifier)
        }
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel: ViewModelType = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.refresh()
        bindUI()
    }
}

// MARK: Internal
extension ViewController {
    func bindUI() {
        viewModel
            .outputs
            .isFavorites
            .bind(to: favoriteSwitch.rx.isOn)
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .prices
            .bind(to: tableView.rx.items(cellIdentifier: TableViewCell.reusedIdentifier,
                                         cellType: TableViewCell.self)) { (_, price, cell) in
                cell.configure(price: price)
            }
            .disposed(by: disposeBag)
        
        searchTerm
            .rx
            .text
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .map { $0 }
            .subscribe(onNext: { [unowned self] text in
            self.viewModel.inputs.search(keyword: text ?? "")
        })
            .disposed(by: disposeBag)
        
        favoriteSwitch.rx.isOn.changed
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.inputs.didClickIsFavoriteSwitch()
            })
            .disposed(by: disposeBag)
    }
}
