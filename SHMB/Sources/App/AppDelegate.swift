import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do {
            let environment = Environment(keyValueStorage: ProcessInfo.processInfo.environment)
            let configuration = try ConfigurationPlistImpl.configuration(plistName: "Configuration")
            let appStyle = AppWhiteStyle()
            let webClient: WebClient = environment.webMocked
                ? WebClientFakeImpl(environment: environment)
                : Finnhub.WebClientImpl(configuration: configuration.finnhub)
            let serviceProvider = ServiceProviderSingletonImpl(
                webClient: webClient,
                l10n: L10nImpl(),
                appStyle: appStyle,
                environment: environment,
                persistentStore: PersistentStoreCoreDataImpl()
            )
            let stoksViewController = StocksViewController(
                serviceProvider: serviceProvider
            )

            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = stoksViewController
            self.window?.makeKeyAndVisible()
        }
        catch {
            fatalError(error.localizedDescription)
        }

        return true
    }
}
