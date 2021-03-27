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
        var logo: String?
        var currency: String?
    }

    struct Quote: Codable {
        var c: Double?
        var pc: Double?
        var change: Double? {
            guard let c = self.c, let pc = self.pc else {
                return nil
            }
            return pc / c
        }
    }
}
