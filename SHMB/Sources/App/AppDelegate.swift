import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let appStyle = AppWhiteStyle()
        let serviceProvider = ServiceProviderImpl(l10n: L10nImpl(), appStyle: appStyle)
        let stoksViewController = StocksViewController(
            serviceProvider: serviceProvider
        )

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = stoksViewController
        self.window?.makeKeyAndVisible()

        return true
    }
}
