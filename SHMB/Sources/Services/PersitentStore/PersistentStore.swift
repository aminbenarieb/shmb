import Combine
import Foundation

protocol PersistentStoreStocksInfo {
    var id: String { get }
    var title: String { get }
    var subtitle: String { get }
    var isFavourite: Bool? { get }
    var price: Float? { get }
    var priceChange: Float? { get }
    var currency: String? { get }
    var imageURL: URL? { get }
}

struct PersistentStoreFetchStocksInfo {
    let page: Int?
    let isFavourite: Bool?
    let id: String?
    init(
        page: Int? = nil,
        isFavourite: Bool? = nil,
        id: String? = nil
    ) {
        self.page = page
        self.isFavourite = isFavourite
        self.id = id
    }
}

protocol PersistentStore {
    func watch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func unwatch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func favourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func unfavourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error>
    func fetch(fetchStocksInfo: PersistentStoreFetchStocksInfo)
        -> AnyPublisher<[PersistentStoreStocksInfo], Error>
}
