import Combine
import Foundation
/* TODO: Delete or refactor later
class PersistentStoreStocksInfoUserDefaultsImpl: NSObject, PersistentStoreStocksInfo, Codable, NSCoding {
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

class PersistentStoreUserDefaultsImpl: PersistentStore {
    private let userDefaults: Atomic<UserDefaults>

    enum Keys: String {
        case stocks
    }

    init(userDefaults: UserDefaults) {
        self.userDefaults = Atomic(userDefaults)
    }

    private func mutate(_ transform: @escaping (inout [String: PersistentStoreStocksInfoUserDefaultsImpl]) -> Void)
        -> AnyPublisher<Bool, Error>
    {
        do {
            var items = try self.retrieve()
            transform(&items)
            // Start: Save
            let encodedData = try NSKeyedArchiver.archivedData(
                withRootObject: items,
                requiringSecureCoding: false
            )
            self.userDefaults.mutate {
                $0.setValue(encodedData, forKey: Keys.stocks.rawValue)
            }
            let result = self.userDefaults.value.synchronize()
            // End
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    private func retrieve() throws -> [String: PersistentStoreStocksInfoUserDefaultsImpl] {
        var items = [String: PersistentStoreStocksInfoUserDefaultsImpl]()
        if
            let data = self.userDefaults.value.object(forKey: Keys.stocks.rawValue) as? Data,
            let cachedItems = try NSKeyedUnarchiver
            .unarchiveTopLevelObjectWithData(data) as? [String: PersistentStoreStocksInfoUserDefaultsImpl]
        {
            items = cachedItems
        }
        return items
    }
    
    // MARK: PersistentStore
    
    func add(id: String) -> AnyPublisher<Bool, Error> {
        self.mutate { items in
            items[id] = .init(id: id, favourite: true)
        }
    }

    func remove(id: String) -> AnyPublisher<Bool, Error> {
        self.mutate { items in
            items[id] = nil
        }
    }

    func fetch(ids: [String]) -> AnyPublisher<[PersistentStoreStocksInfo], Error> {
        do {
            let items = try self.retrieve()
            let filteredItems = items.filter { ids.contains($0.key) }
            let sortedItems = filteredItems.values.sorted { $0.id < $1.id }
            return Just(sortedItems)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
*/
