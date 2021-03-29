import Combine
import Foundation
import class UIKit.UIImage

enum Finnhub {}

extension Finnhub {
    struct FinhubError: Error, LocalizedError {
        let message: String
        public var errorDescription: String? {
            self.message
        }

        public var localizedDescription: String {
            self.message
        }
    }

    class WebClientImpl: WebClient {
        // TODO: Make more smart cache policy
        private var cachePolicy: NSURLRequest.CachePolicy {
            .reloadIgnoringLocalAndRemoteCacheData
        }

        // TODO: Make more smart timeout managment
        private var timeoutInterval: Double {
            .greatestFiniteMagnitude
        }

        private var maxSearchSymbols: Int {
            20
        }

        private let configuration: FinnhubConfiguration
        private let urlSession: URLSession
        init(configuration: FinnhubConfiguration) {
            self.configuration = configuration
            self.urlSession = URLSession.shared
        }

        func stocks(query: String)
            -> AnyPublisher<WebClientResponse<[WebClientStocksInfo]>, Error>
        {
            return self.search(query: query)
                .flatMap { response -> AnyPublisher<[WebClientResponse<WebClientStocksInfo>], Error> in
                    let symbols = response.value.result
                    let sequence = symbols.prefix(self.maxSearchSymbols)
                        .map { self.webClientStocksInfo(symbol: $0) }
                    return Publishers.MergeMany(sequence)
                        .collect()
                        .eraseToAnyPublisher()
                }
                .flatMap { responses -> AnyPublisher<WebClientResponse<[WebClientStocksInfo]>, Error> in
                    let values = responses.map { $0.value }
                    let responses = responses
                        .reduce([URLResponse]()) { (result, response) -> [URLResponse] in
                            result + response.responses
                        }
                    return Just(WebClientResponse(value: values, responses: responses))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }

        private func webClientStocksInfo(symbol: Symbol)
            -> AnyPublisher<WebClientResponse<WebClientStocksInfo>, Error>
        {
            return Publishers.Zip(
                self.profile(symbol: symbol.symbol)
                    .flatMap { response -> AnyPublisher<WebClientResponse<Profile>, Error> in
                        let profile = response.value
                        guard
                            let logo = profile.logo, logo.isValidURL,
                            let logoURL = URL(string: logo)
                        else {
                            return Just(response)
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        }
                        return Just(WebClientResponse(
                            value: Profile(
                                logo: profile.logo,
                                currency: profile.currency,
                                imageURL: logoURL
                            ),
                            responses: response.responses
                        ))
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
                    .replaceError(with: .init(
                        value: .init(logo: nil, currency: nil),
                        response: nil
                    )),
                self.quotes(symbol: symbol.symbol)
                    .replaceError(with: .init(value: .init(c: nil, pc: nil), response: nil))
            )
            .map { result -> WebClientResponse<WebClientStocksInfo> in
                let profile = result.0.value
                let quote = result.1.value
                let webClientStocksInfo = WebClientStocksInfo(
                    id: symbol.symbol,
                    title: symbol.symbol,
                    subtitle: symbol.description,
                    price: quote.c,
                    priceChange: quote.change,
                    currency: profile.currency
                )
                let responeses = result.0.responses + result.1.responses
                return .init(value: webClientStocksInfo, responses: responeses)
            }
            .flatMap {
                Just($0)
                    .setFailureType(to: Error.self)
            }
            .eraseToAnyPublisher()
        }

        private func search(query: String)
            -> AnyPublisher<WebClientResponse<SearchSymbols>, Error>
        {
            let path = "/api/v1/search"
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
                    .appending(path)
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
            let urlRequest = URLRequest(
                url: url,
                cachePolicy: self.cachePolicy,
                timeoutInterval: self.timeoutInterval
            )
            return self.run(urlRequest)
        }

        private func news(symbol: String) -> AnyPublisher<WebClientResponse<[News]>, Error> {
            let path = "/api/v1/company-news"
            var urlComponents = URLComponents(
                string: self.configuration.baseUrl
                    .appending(path)
            )
            urlComponents?.queryItems = [
                URLQueryItem(name: "token", value: self.configuration.apiKey),
                URLQueryItem(name: "symbol", value: symbol),
                // TODO: &from=2021-03-11&to=2021-03-25
            ]
            guard let url = urlComponents?.url else {
                return self.failure("Failed to build url for \(path)")
            }
            let urlRequest = URLRequest(
                url: url,
                cachePolicy: self.cachePolicy,
                timeoutInterval: self.timeoutInterval
            )
            return self.run(urlRequest)
        }

        private func profile(symbol: String) -> AnyPublisher<WebClientResponse<Profile>, Error> {
            let path = "/api/v1/stock/profile2"
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
            let urlRequest = URLRequest(
                url: url,
                cachePolicy: self.cachePolicy,
                timeoutInterval: self.timeoutInterval
            )
            return self.run(urlRequest)
        }

        private func quotes(symbol: String) -> AnyPublisher<WebClientResponse<Quote>, Error> {
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
            let urlRequest = URLRequest(
                url: url,
                cachePolicy: self.cachePolicy,
                timeoutInterval: self.timeoutInterval
            )
            return self.run(urlRequest)
        }

        private func run<T: Decodable>(
            _ request: URLRequest,
            _ decoder: JSONDecoder = JSONDecoder()
        ) -> AnyPublisher<WebClientResponse<T>, Error> {
            return self.urlSession
                .dataTaskPublisher(for: request)
                .tryMap { result -> WebClientResponse<T> in
                    if
                        let httpURLResponse = result.response as? HTTPURLResponse,
                        httpURLResponse.statusCode == 429
                    {
                        throw FinhubError(message: "Too many requests. Try again later")
                    }
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

extension Finnhub {
    struct SearchSymbols: Codable {
        var count: Int
        var result: [Symbol]
    }

    struct Symbol: Codable {
        var description: String
        var symbol: String
    }

    struct News: Codable {
        var datetime: Int
        var headline: String
        var source: String
        var summary: String
        var url: URL
    }

    struct Profile: Codable {
        var logo: String?
        var currency: String?
        var imageURL: URL?
        private enum CodingKeys: String, CodingKey {
            case logo
            case currency
        }
    }

    struct Quote: Codable {
        var c: Float?
        var pc: Float?
        var change: Float? {
            guard let c = self.c, let pc = self.pc else {
                return nil
            }
            return pc - c
        }
    }
}
