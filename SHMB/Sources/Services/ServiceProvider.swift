import Foundation

protocol ServiceProvider {
    var webClient: WebClient { get }
    var l10n: L10n { get }
    var appStyle: AppStyle { get }
    var environment: Environment { get }
}

class ServiceProviderImpl: ServiceProvider {
    var webClient: WebClient
    var l10n: L10n
    var appStyle: AppStyle
    var environment: Environment

    init(webClient: WebClient, l10n: L10n, appStyle: AppStyle, environment: Environment) {
        self.webClient = webClient
        self.l10n = l10n
        self.appStyle = appStyle
        self.environment = environment
    }
}
