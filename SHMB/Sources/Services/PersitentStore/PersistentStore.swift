import Combine
import Foundation

protocol PersistentStoreStocksInfo {
    var id: String { get }
    var title: String { get }
    var subtitle: String { get }
    var isFavourite: String { get }
    var isFavourite: Bool { get }
}
struct PersistentStoreFetchStocksInfo {
    let page: Int
    let isFavourite: Bool?
}

protocol PersistentStore {
    func watch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func unwatch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func favourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func unfavourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func fetch(fetchStocksInfo: PersistentStoreFetchStocksInfo) -> AnyPublisher<[PersistentStoreStocksInfo], Error>
}
