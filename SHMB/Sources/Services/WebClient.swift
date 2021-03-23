import Combine
import Foundation

struct WebClientResponse<T> {
    let value: T
    let response: URLResponse
}

protocol WebClient {
    func stocks() -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error>
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
        var value = [StocksInfo]()
        for i in 0..<10 {
            value.append(
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
        if let errorMessage = self.environment.webMockedError {
            return Fail(error: NSError(
                domain: "com.aminbenarieb.SHMB",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
                .eraseToAnyPublisher()
        }
        let publisher = Just(WebClientResponse(value: value, response: response))
            .setFailureType(to: Error.self)
        if let delay = self.environment.webMockedDelay {
            return publisher
                .delay(for: .seconds(delay), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return publisher.eraseToAnyPublisher()
    }
}
