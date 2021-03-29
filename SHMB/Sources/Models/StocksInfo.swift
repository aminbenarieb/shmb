import Foundation
import UIKit

struct StocksInfo {
    let id: String
    let image: UIImage?
    let title: String
    let isFavourite: Bool?
    let isWatching: Bool
    let subtitle: String
    let price: Float?
    let priceChange: Float?
    var priceChangePercent: Float? {
        guard let priceChange = self.priceChange, let price = self.price else {
            return nil
        }
        return priceChange / price
    }

    let currency: String?
}

extension StocksInfo: Hashable {}

extension StocksInfo {
    func copy(isFavourite: Bool) -> StocksInfo {
        return .init(
            id: self.id,
            image: self.image,
            title: self.title,
            isFavourite: isFavourite,
            isWatching: self.isWatching,
            subtitle: self.subtitle,
            price: self.price,
            priceChange: self.priceChange,
            currency: self.currency
        )
    }
}

extension StocksInfo: PersistentStoreStocksInfo {}
