import Foundation

protocol WebClient {
    func stocks() -> [StocksInfo]
}

class WebClientImpl: WebClient {
    func stocks() -> [StocksInfo] { fatalError() }
}

class WebClientFakeImpl: WebClient {
    func stocks() -> [StocksInfo] {
        var stocks = [StocksInfo]()
        for i in 0..<10 {
            stocks.append(
                StocksInfo(
                    id: i,
                    imageURL: nil,
                    title: "Title \(i)",
                    isFavourite: i % 2 == 0,
                    subtitle: "Subtitle \(i)",
                    price: Float(i) * 10,
                    priceChange: .init(value: Float(i), percent: Float(i) / 100),
                    currency: "$"
                )
            )
        }
        return stocks
    }
}
