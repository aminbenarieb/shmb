import Foundation

protocol ServiceProvider {
    var webClient: WebClient { get }
    var l10n: L10n { get }
    var appStyle: AppStyle { get }
}

class ServiceProviderImpl: ServiceProvider {
    var webClient: WebClient
    var l10n: L10n
    var appStyle: AppStyle

    init(webClient: WebClient, l10n: L10n, appStyle: AppStyle) {
        self.webClient = webClient
        self.l10n = l10n
        self.appStyle = appStyle
    }
}
