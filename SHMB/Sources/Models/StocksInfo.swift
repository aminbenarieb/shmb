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

extension StocksInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: StocksInfo, rhs: StocksInfo) -> Bool {
        lhs.id == rhs.id
    }
}

extension StocksInfo.PriceChangeInfo: Hashable {}
