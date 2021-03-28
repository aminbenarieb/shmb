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

protocol WebClient {
    func stocks(query: String) -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error>
    func image(url: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error>
}
