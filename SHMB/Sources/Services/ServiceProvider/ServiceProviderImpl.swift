import Foundation

struct ServiceProviderSingletonImpl: ServiceProvider {
    let webClient: WebClient
    let l10n: L10n
    let appStyle: AppStyle
    let environment: Environment
    let persistentStore: PersistentFavouritesStore
}
