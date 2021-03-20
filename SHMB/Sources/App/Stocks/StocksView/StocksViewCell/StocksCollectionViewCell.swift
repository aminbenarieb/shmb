//
//  StocksCollectionViewCell.swift
//  SHMB
//
//  Created by Amin Benarieb on 20.03.2021.
//

import UIKit

class StocksCollectionViewCell: UICollectionViewCell {

    struct StocksInfo {
        let image: UIImage?
        let title: String
        let isFavourite: Bool
        let subtitle: String
        let price: Float
        let priceChange: PriceChangeInfo; struct PriceChangeInfo {
            let value: Float
            let percoent: Float
        }
    }
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var favouriteButton: UIButton!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var priceChangeLabel: UILabel!
    
    // MARK: View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    // MARK: Configure
    
    func configure(stocksInfo: StocksInfo) {
        self.imageView.image = stocksInfo.image
        self.titleLabel.text = stocksInfo.title
        self.favouriteButton = nil
        self.subtitleLabel.text = stocksInfo.subtitle
        self.priceLabel.text = String(format: "%.1lf", stocksInfo.price)
        self.priceChangeLabel.text = String(format: "%.1lf (%.1lf%)", stocksInfo.priceChange.value, stocksInfo.priceChange.percoent)
    }

    // MARK: Setup
    
    private func setup() {
        
    }
    
    // MARK: Actions
    
    @IBAction private func favouriteAction(_ sender: Any) {
        
    }
    
}
