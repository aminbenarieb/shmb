import Combine
import Foundation
import class UIKit.UIImage

class WebClientFakeImpl: WebClient {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func stocks(query: String) -> AnyPublisher<WebClientResponse<[WebClientStocksInfo]>, Error> {
        let value = self.mockedData().filter {
            $0.title.localizedCaseInsensitiveContains(query) || $0.id
                .localizedCaseInsensitiveContains(query)
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

    private func mockedData() -> [WebClientStocksInfo] {
        return [
            WebClientStocksInfo(
                id: "YNDX",
                imageURL: URL(string: "https://fake.mocked/YNDX"),
                title: "YNDX",
                subtitle: "Yandex, LLC",
                price: 4764.6,
                priceChange: 55,
                currency: "RUB"
            ),
            WebClientStocksInfo(
                id: "AAPL",
                imageURL: URL(string: "https://fake.mocked/AAPL"),
                title: "AAPL",
                subtitle: "Apple Inc.",
                price: 131.93,
                priceChange: 0.12,
                currency: "USD"
            ),
            WebClientStocksInfo(
                id: "GOOGL",
                imageURL: URL(string: "https://fake.mocked/GOOGL"),
                title: "GOOGL",
                subtitle: "Alphabet Class A",
                price: 1825,
                priceChange: 0.0115,
                currency: "USD"
            ),
            WebClientStocksInfo(
                id: "4",
                imageURL: URL(string: "https://fake.mocked/AMZN"),
                title: "AMZN",
                subtitle: "Amazon.com",
                price: 3204,
                priceChange: -0.12,
                currency: "USD"
            ),
            WebClientStocksInfo(
                id: "BAC",
                imageURL: URL(string: "https://fake.mocked/BAC"),
                title: "BAC",
                subtitle: "Bank of America Corp",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
            WebClientStocksInfo(
                id: "MSFT",
                imageURL: URL(string: "https://fake.mocked/MSFT"),
                title: "MSFT",
                subtitle: "Microsoft Corporation",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
            WebClientStocksInfo(
                id: "TSLA",
                imageURL: URL(string: "https://fake.mocked/TSLA"),
                title: "TSLA",
                subtitle: "Tesla Motors",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
            WebClientStocksInfo(
                id: "MA",
                imageURL: URL(string: "https://fake.mocked/MA"),
                title: "MA",
                subtitle: "Mastercard",
                price: 3204,
                priceChange: 0.12,
                currency: "USD"
            ),
        ]
    }
}
