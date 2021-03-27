import Combine
import Foundation

class PersistentStoreStocksInfo: NSObject, Codable, NSCoding {
    let id: String
    let favourite: Bool

    init(id: String, favourite: Bool) {
        self.id = id
        self.favourite = favourite
    }

    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.favourite = aDecoder.decodeBool(forKey: "favourite")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.favourite, forKey: "favourite")
    }
}

protocol PersistentFavouritesStore {
    func add(id: String) -> AnyPublisher<Bool, Error>
    func remove(id: String) -> AnyPublisher<Bool, Error>
    func fetch(ids: [String]) -> AnyPublisher<[PersistentStoreStocksInfo], Error>
}
