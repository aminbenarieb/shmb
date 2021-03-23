import Combine
import Foundation
import UIKit

struct WebClientResponse<T> {
    let value: T
    let response: URLResponse
}

protocol WebClient {
    func stocks() -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error>
    func image(url: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error>
}

struct WebClientConfiguration {
    var stocksURL: URL
}

class WebClientImpl: WebClient {
    private let configuration: WebClientConfiguration
    init(configuration: WebClientConfiguration) {
        self.configuration = configuration
    }

    func stocks() -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error> {
        self.run(URLRequest(url: self.configuration.stocksURL))
    }

    func image(url _: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error> {
        fatalError("Not implemented")
    }

    private func run<T: Decodable>(
        _ request: URLRequest,
        _ decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<WebClientResponse<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .print()
            .tryMap { result -> WebClientResponse<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return WebClientResponse(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class WebClientFakeImpl: WebClient {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func stocks() -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error> {
        let response = URLResponse()
        let value = self.mockedData()
        if let errorMessage = self.environment.webMockedError {
            return Fail(error: NSError(
                domain: "com.aminbenarieb.SHMB",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
                .eraseToAnyPublisher()
        }
        return Just(WebClientResponse(value: value, response: response))
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
                id: 0,
                imageURL: URL(string: "https://fake.mocked/YNDX.pdf"),
                title: "YNDX",
                isFavourite: false,
                subtitle: "Yandex, LLC",
                price: 4764.6,
                priceChange: .init(value: 55, percent: 0.0115),
                currency: "Р"
            ),
            StocksInfo(
                id: 2,
                imageURL: URL(string: "https://fake.mocked/AAPL.pdf"),
                title: "AAPL",
                isFavourite: true,
                subtitle: "Apple Inc.",
                price: 131.93,
                priceChange: .init(value: 0.12, percent: 0.0115),
                currency: "$"
            ),
            StocksInfo(
                id: 3,
                imageURL: URL(string: "https://fake.mocked/GOOGL.pdf"),
                title: "GOOGL",
                isFavourite: true,
                subtitle: "Alphabet Class A",
                price: 1825,
                priceChange: .init(value: 0.12, percent: 0.0115),
                currency: "$"
            ),
            StocksInfo(
                id: 4,
                imageURL: URL(string: "https://fake.mocked/AMZN.pdf"),
                title: "AMZN",
                isFavourite: true,
                subtitle: "Amazon.com",
                price: 3204,
                priceChange: .init(value: -0.12, percent: 0.0115),
                currency: "$"
            ),
            StocksInfo(
                id: 5,
                imageURL: URL(string: "https://fake.mocked/BAC.pdf"),
                title: "BAC",
                isFavourite: true,
                subtitle: "Bank of America Corp",
                price: 3204,
                priceChange: .init(value: 0.12, percent: 0.0115),
                currency: "$"
            ),
            StocksInfo(
                id: 6,
                imageURL: URL(string: "https://fake.mocked/MSFT.pdf"),
                title: "MSFT",
                isFavourite: true,
                subtitle: "Microsoft Corporation",
                price: 3204,
                priceChange: .init(value: 0.12, percent: 0.0115),
                currency: "$"
            ),
            StocksInfo(
                id: 7,
                imageURL: URL(string: "https://fake.mocked/TSLA.pdf"),
                title: "TSLA",
                isFavourite: true,
                subtitle: "Tesla Motors",
                price: 3204,
                priceChange: .init(value: 0.12, percent: 0.0115),
                currency: "$"
            ),
            StocksInfo(
                id: 8,
                imageURL: URL(string: "https://fake.mocked/MA.pdf"),
                title: "MA",
                isFavourite: true,
                subtitle: "Mastercard",
                price: 3204,
                priceChange: .init(value: 0.12, percent: 0.0115),
                currency: "$"
            ),
        ]
    }
}
