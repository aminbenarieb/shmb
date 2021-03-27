import Foundation

protocol ServiceProvider {
    var webClient: WebClient { get }
    var l10n: L10n { get }
    var appStyle: AppStyle { get }
    var environment: Environment { get }
    var persistentStore: PersistentFavouritesStore { get }
}
