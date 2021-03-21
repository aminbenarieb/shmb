import Foundation

protocol ServiceProvider {
    var l10n: L10n { get }
    var appStyle: AppStyle { get }
}

class ServiceProviderImpl: ServiceProvider {
    var l10n: L10n
    var appStyle: AppStyle

    init(l10n: L10n, appStyle: AppStyle) {
        self.l10n = l10n
        self.appStyle = appStyle
    }
}
