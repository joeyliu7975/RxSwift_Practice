//
//  TableViewCell.swift
//  RxStock
//
//  Created by JiaSin Liu on 2022/2/23.
//

import UIKit

protocol Identifiable {
    static var reusedIdentifier: String { get }
}

extension Identifiable {
    static var reusedIdentifier: String {
        String(describing: Self.self)
    }
}

class TableViewCell: UITableViewCell, Identifiable {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(price: StockPrice) {
        let favorite = price.isFavorite ? "💘" : ""
        titleLabel.text = price.symbol + favorite
        priceLabel.text = "Price"
    }
    
}
