import Combine
import Foundation
import class UIKit.UIImage

class WebClientFakeImpl: WebClient {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func stocks(query: String) -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error> {
        let value = self.mockedData().filter {
            $0.title.localizedCaseInsensitiveContains(query) || $0.id.localizedCaseInsensitiveContains(query)
        }
        if let errorMessage = self.environment.webMockedError {
            return Fail(error: NSError(
                domain: "com.aminbenarieb.SHMB",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
                .eraseToAnyPublisher()
        }
        return Just(WebClientResponse(value: value, response: nil))
            .setFailureType(to: Error.self)
            .delay(for: .seconds(self.environment.webMockedDelay ?? 0), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func image(url: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error> {
        let response = URLResponse()
        let value = UIImage(named: url.lastPathComponent)
        return Just(WebClientResponse(value: value, response: response))
            .setFailureType(to: Error.self)
            .delay(for: .seconds(self.environment.webMockedDelay ?? 0), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private func mockedData() -> [StocksInfo] {
        return [
            StocksInfo(
                id: "YNDX",
                image: UIImage(named: "YNDX"),
                title: "YNDX",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Yandex, LLC",
                price: 4764.6,
                priceChange: 55,
                currency: "RUB"
            ),
            StocksInfo(
                id: "AAPL",
                image: UIImage(named: "AAPL"),
                title: "AAPL",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Apple Inc.",
                price: 131.93,
                priceChange: 0.12,
                currency: "USD"
            ),
            StocksInfo(
                id: "GOOGL",
                image: UIImage(named: "GOOGL"),
                title: "GOOGL",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Alphabet Class A",
                price: 1825,
                priceChange: 0.0115,
                currency: "USD"
            ),
            StocksInfo(
                id: "4",
                image: UIImage(named: "AMZN"),
                title: "AMZN",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Amazon.com",
                price: 3204,
                priceChange: -0.12,
                currency: "USD"
            ),
            StocksInfo(
                id: "BAC",
                image: UIImage(named: "BAC"),
                title: "BAC",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Bank of America Corp",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
            StocksInfo(
                id: "MSFT",
                image: UIImage(named: "MSFT"),
                title: "MSFT",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Microsoft Corporation",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
            StocksInfo(
                id: "TSLA",
                image: UIImage(named: "TSLA"),
                title: "TSLA",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Tesla Motors",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
            StocksInfo(
                id: "MA",
                image: UIImage(named: "MA"),
                title: "MA",
                isFavourite: nil,
                isWatching: nil,
                subtitle: "Mastercard",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
        ]
    }
}
