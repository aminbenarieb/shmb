import Combine
import Foundation
import class UIKit.UIImage

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

        func stocks(query: String) -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error> {
            return self.search(query: query)
                .flatMap { response -> AnyPublisher<[WebClientResponse<StocksInfo>], Error> in
                    let symbols = response.value.result
                    let sequence = symbols.prefix(self.maxSearchSymbols)
                        .map { self.stocksInfo(symbol: $0) }
                    return Publishers.MergeMany(sequence)
                        .collect()
                        .eraseToAnyPublisher()
                }
                .flatMap { responses -> AnyPublisher<WebClientResponse<[StocksInfo]>, Error> in
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

        private func stocksInfo(symbol: Symbol)
            -> AnyPublisher<WebClientResponse<StocksInfo>, Error>
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
                        return self.image(url: logoURL)
                            .map { imageResponse in
                                WebClientResponse(
                                    value: Profile(
                                        logo: profile.logo,
                                        currency: profile.currency,
                                        image: imageResponse.value
                                    ),
                                    responses: response.responses + imageResponse.responses
                                )
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
                    .replaceError(with: .init(
                        value: .init(logo: nil, currency: nil, image: nil),
                        response: nil
                    )),
                self.quotes(symbol: symbol.symbol)
                    .replaceError(with: .init(value: .init(c: nil, pc: nil), response: nil))
            )
            .map { result -> WebClientResponse<StocksInfo> in
                let profile = result.0.value
                let quote = result.1.value
                let stocksInfo = StocksInfo(
                    id: symbol.symbol,
                    image: profile.image,
                    title: symbol.symbol,
                    isFavourite: false,
                    isWatching: false,
                    subtitle: symbol.description,
                    price: quote.c,
                    priceChange: quote.change,
                    currency: profile.currency
                )
                let responeses = result.0.responses + result.1.responses
                return .init(value: stocksInfo, responses: responeses)
            }
            .flatMap {
                Just($0)
                    .setFailureType(to: Error.self)
            }
            .eraseToAnyPublisher()
        }

        func image(url: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error> {
            self.urlSession
                .dataTaskPublisher(for: url)
                .tryMap { result -> WebClientResponse<UIImage?> in
                    WebClientResponse(
                        value: UIImage(data: result.data),
                        response: result.response
                    )
                }
                .receive(on: DispatchQueue.main)
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
