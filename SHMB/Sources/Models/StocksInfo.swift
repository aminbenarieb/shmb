import Foundation

struct StocksInfo {
    let id: String
    let imageURL: URL?
    let title: String
    let isFavourite: Bool
    let subtitle: String
    let price: Double?
    let priceChange: Double?
    var priceChangePercent: Double? {
        guard let priceChange = self.priceChange, let price = self.price else {
            return nil
        }
        return priceChange / price
    }

    let currency: String?
}

extension StocksInfo: Hashable {}

extension StocksInfo: Codable {}

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
