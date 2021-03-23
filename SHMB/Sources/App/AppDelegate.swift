import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let environment = Environment(keyValueStorage: ProcessInfo.processInfo.environment)
        let appStyle = AppWhiteStyle()
        let webClient: WebClient = environment.webMocked
            ? WebClientFakeImpl(environment: environment)
            : WebClientImpl(configuration: .init(stocksURL: URL(string: "https://google.com")!))
        let serviceProvider = ServiceProviderImpl(
            webClient: webClient,
            l10n: L10nImpl(),
            appStyle: appStyle,
            environment: environment
        )
        let stoksViewController = StocksViewController(
            serviceProvider: serviceProvider
        )

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = stoksViewController
        self.window?.makeKeyAndVisible()

        return true
    }
}
