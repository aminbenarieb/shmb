import Combine
import Foundation
import class UIKit.UIImage

struct WebClientResponse<T> {
    let value: T
    let responses: [URLResponse]
    init(value: T, responses: [URLResponse]) {
        self.value = value
        self.responses = responses
    }

    init(value: T, response: URLResponse?) {
        self.init(
            value: value,
            responses: response.map { [$0] } ?? []
        )
    }
}

struct WebClientStocksInfo {
    var id: String
    var imageURL: URL?
    var title: String
    var subtitle: String
    var price: Float?
    var priceChange: Float?
    var priceChangePercent: Float? {
        guard let priceChange = self.priceChange, let price = self.price else {
            return nil
        }
        return priceChange / price
    }

    var currency: String?
}

protocol WebClient {
    func stocks(query: String) -> AnyPublisher<WebClientResponse<[WebClientStocksInfo]>, Error>
    func image(url: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error>
}
