import Foundation

enum Finnhub {
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
        var country: String
        var currency: String
        var exchange: String
        var finnhubIndustry: String
        var ipo: String
        var logo: String?
        var marketCapitalization: Double
        var name: String
        var shareOutstanding: Double
        var weburl: URL
    }

    struct Quote: Codable {
        var c: Double
        var pc: Double
    }
}
