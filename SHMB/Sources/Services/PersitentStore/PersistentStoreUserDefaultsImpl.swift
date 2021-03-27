import Combine
import Foundation

enum PersistentStoreUserDefaultError: Error {
    case notFoundDefaults
}

class PersistentStoreUserDefaultsImpl: PersistentFavouritesStore {
    private let userDefaults: Atomic<UserDefaults>

    enum Keys: String {
        case stocks
    }

    init(userDefaults: UserDefaults) {
        userDefaults.register(defaults: [
            Keys.stocks.rawValue: [String: PersistentStoreStocksInfo](),
        ])
        self.userDefaults = Atomic(userDefaults)
    }

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
        guard
            let items = self.userDefaults.value
            .dictionary(forKey: Keys.stocks.rawValue) as? [String: PersistentStoreStocksInfo]
        else {
            return Fail(error: PersistentStoreUserDefaultError.notFoundDefaults)
                .eraseToAnyPublisher()
        }
        let filteredItems = items.filter { ids.contains($0.key) }
        let sortedItems = filteredItems.values.sorted { $0.id < $1.id }
        return Just(sortedItems)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func mutate(_ transform: @escaping (inout [String: PersistentStoreStocksInfo]) -> Void)
        -> AnyPublisher<Bool, Error>
    {
        do {
            // Start: Retrieve
            guard
                let data = self.userDefaults.value.object(forKey: Keys.stocks.rawValue) as? Data,
                var items = try NSKeyedUnarchiver
                .unarchiveTopLevelObjectWithData(data) as? [String: PersistentStoreStocksInfo]
            else {
                throw PersistentStoreUserDefaultError.notFoundDefaults
            }
            // End
            // Start: Transform
            transform(&items)
            // End
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
}
