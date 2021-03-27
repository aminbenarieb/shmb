import Foundation

class L10nImpl: L10n {
    func localized(_ key: L10nKey, _ args: CVarArg...) -> String {
        let format = BundleToken.bundle.localizedString(
            forKey: key.rawValue,
            value: nil,
            table: "l10n"
        )
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()
}
