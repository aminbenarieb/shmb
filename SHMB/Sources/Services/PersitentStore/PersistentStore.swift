import Combine
import Foundation

struct PersistentStoreStocksInfo: Codable {
    let id: String
    let favourite: Bool
}

protocol PersistentFavouritesStore {
    func add(id: String) -> AnyPublisher<Bool, Error>
    func remove(id: String) -> AnyPublisher<Bool, Error>
    func fetch(ids: [String]) -> AnyPublisher<[PersistentStoreStocksInfo], Error>
}
