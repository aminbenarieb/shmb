import Foundation

struct StocksInfo {
    let id: Int
    let imageURL: URL?
    let title: String
    let isFavourite: Bool
    let subtitle: String
    let price: Float
    let priceChange: PriceChangeInfo; struct PriceChangeInfo {
        let value: Float
        let percent: Float
    }

    let currency: String
}

extension StocksInfo: Hashable {}

extension StocksInfo.PriceChangeInfo: Hashable {}

extension StocksInfo: Codable {}

extension StocksInfo.PriceChangeInfo: Codable {}

extension StocksInfo {
    func copy(isFavourite: Bool) -> StocksInfo {
        return .init(
            id: self.id,
            imageURL: self.imageURL,
            title: self.title,
            isFavourite: isFavourite,
            subtitle: self.subtitle,
            price: self.price,
            priceChange: self.priceChange,
            currency: self.currency
        )
    }
}
