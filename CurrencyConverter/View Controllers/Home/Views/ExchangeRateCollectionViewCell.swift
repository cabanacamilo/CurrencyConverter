//
//  ExchangeRateCollectionViewCell.swift
//  CurrencyConverter
//
//  Created by Camilo Cabana on 18/11/19.
//  Copyright © 2019 Camilo Cabana. All rights reserved.
//

import UIKit

class ExchangeRateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 0.3
        layer.cornerRadius = 8
        layer.borderColor = UIColor.label.cgColor
        backgroundColor = UIColor(white: 0.98, alpha: 1)
    }
    
}
