import Combine
import Foundation
import UIKit // for WebClientFakeImpl

struct WebClientResponse<T> {
    let value: T
    let response: URLResponse
}

protocol WebClient {
    func stocks() -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error>
    func image(url: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error>
}

extension Finnhub {
    class WebClientImpl: WebClient {
        private let configuration: FinnhubConfiguration
        init(configuration: FinnhubConfiguration) {
            self.configuration = configuration
        }

        func stocks() -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error> {
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
                    .appending("/api/v1/stock/symbol")
            )
            urlComponents?.queryItems = [
                URLQueryItem(name: "token", value: self.configuration.apiKey),
                URLQueryItem(name: "exchange", value: "US"),
            ]
            guard let url = urlComponents?.url else {
                return self.failure("Failed to build stocks url")
            }
            let urlRequest = URLRequest(url: url)
            return self.run(urlRequest)
        }

        func image(url _: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error> {
            fatalError("Not implemented")
        }

        private func search(query: String)
            -> AnyPublisher<WebClientResponse<[SearchSymbols]>, Error>
        {
            let path = "/api/v1/search"
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
            )
            urlComponents?.queryItems = [
                URLQueryItem(name: "token", value: self.configuration.apiKey),
                URLQueryItem(name: "q", value: query),
            ]
            guard let url = urlComponents?.url else {
                return self.failure("Failed to build stocks for \(path)")
            }
            let urlRequest = URLRequest(url: url)
            return self.run(urlRequest)
        }

        private func symbols() -> AnyPublisher<WebClientResponse<[Symbol]>, Error> {
            let path = "/api/v1/stock/symbol"
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
                    .appending(path)
            )
            urlComponents?.queryItems = [
                URLQueryItem(name: "token", value: self.configuration.apiKey),
                URLQueryItem(name: "exchange", value: "US"),
            ]
            guard let url = urlComponents?.url else {
                return self.failure("Failed to build url for \(path)")
            }
            let urlRequest = URLRequest(url: url)
            return self.run(urlRequest)
        }

        private func news(symbol: String) -> AnyPublisher<WebClientResponse<[News]>, Error> {
            let path = "/api/v1/company-news"
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
                    .appending("/api/v1/company-news")
            )
            urlComponents?.queryItems = [
                URLQueryItem(name: "token", value: self.configuration.apiKey),
                URLQueryItem(name: "symbol", value: symbol),
                // TODO: &from=2021-03-11&to=2021-03-25
            ]
            guard let url = urlComponents?.url else {
                return self.failure("Failed to build url for \(path)")
            }
            let urlRequest = URLRequest(url: url)
            return self.run(urlRequest)
        }

        private func profile(symbol: String) -> AnyPublisher<WebClientResponse<Profile>, Error> {
            let path = "/api/v1/profile2"
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
                    .appending(path)
            )
            urlComponents?.queryItems = [
                URLQueryItem(name: "token", value: self.configuration.apiKey),
                URLQueryItem(name: "symbol", value: symbol),
            ]
            guard let url = urlComponents?.url else {
                return self.failure("Failed to build url for \(path)")
            }
            let urlRequest = URLRequest(url: url)
            return self.run(urlRequest)
        }

        private func quotes(symbol: String) -> AnyPublisher<WebClientResponse<[Quote]>, Error> {
            let path = "/api/v1/quote"
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
                    .appending(path)
            )
            urlComponents?.queryItems = [
                URLQueryItem(name: "token", value: self.configuration.apiKey),
                URLQueryItem(name: "symbol", value: symbol),
            ]
            guard let url = urlComponents?.url else {
                return self.failure("Failed to build url for \(path)")
            }
            let urlRequest = URLRequest(url: url)
            return self.run(urlRequest)
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

        private func failure<T>(
            _ description: String
        ) -> AnyPublisher<WebClientResponse<T>, Error> {
            return Fail(error: NSError(
                domain: "com.aminbenarieb.SHMB",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: description]
            ))
                .eraseToAnyPublisher()
        }
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
