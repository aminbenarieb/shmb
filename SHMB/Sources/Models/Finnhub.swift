import Foundation
import UIKit

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
        var image: UIImage?
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
