import Foundation

enum ConfigurationPlistError: Error {
    case plistNotFound
    case plistIsNotValid
}

struct ConfigurationPlistImpl: Configuration {
    var finnhub: FinnhubConfiguration

    static func configuration(plistName: String) throws -> ConfigurationPlistImpl {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist") else {
            throw ConfigurationPlistError.plistNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        return try decoder.decode(ConfigurationPlistImpl.self, from: data)
    }
}

extension ConfigurationPlistImpl: Decodable {}
