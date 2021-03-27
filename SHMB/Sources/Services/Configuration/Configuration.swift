import Foundation

struct FinnhubConfiguration: Codable {
    var baseUrl: String
    var baseSocketUrl: String
    var apiKey: String
}

protocol Configuration {
    var finnhub: FinnhubConfiguration { get }
}
