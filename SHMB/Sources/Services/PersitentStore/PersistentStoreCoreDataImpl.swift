import Combine
import CoreData
import os.log

class PersistentStoreCoreDataImpl {
    private let persistentContainer: NSPersistentContainer

    init() {
        self.persistentContainer = NSPersistentContainer(name: "SHMB")
        self.persistentContainer.loadPersistentStores { _, _ in
            // TODO: Handle error
        }
    }

    private func _save(context: NSManagedObjectContext) throws {
        context.perform {
            guard context.hasChanges else {
                return
            }
            do {
                try context.save()
            }
            catch {
                context.rollback()
                // TODO: Handle this error throw error
            }
            context.reset()
        }
    }

    private func _fetch(id: String) throws -> [Stocks] {
        let context = self.persistentContainer.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Stocks> = Stocks.fetchRequest()
        fetchRequest.fetchBatchSize = 10
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "ANY id = %@", id)
        return try context.fetch(fetchRequest)
    }

    private func _insert(id: String) throws {
        let context = self.persistentContainer.newBackgroundContext()
        let stocks = Stocks(context: context)
        stocks.favourite = true
        stocks.id = id
        try self._save(context: context)
    }

    private func _delete(id: String) throws {
        let stocks = try self._fetch(id: id)
        guard !stocks.isEmpty else {
            os_log(.debug, "Attempted to delete unexisting stocks with id = %@", id)
            return
        }
        let context = self.persistentContainer.newBackgroundContext()
        for stocksItem in stocks {
            context.delete(stocksItem)
        }
        try self._save(context: context)
    }
}

extension PersistentStoreCoreDataImpl: PersistentFavouritesStore {
    func add(id _: String) -> AnyPublisher<Bool, Error> {
        fatalError("add(stocksInfo:) not implemented for \(String(describing: self))")
    }

    func remove(id _: String) -> AnyPublisher<Bool, Error> {
        fatalError("remove(stocksInfo:) not implemented for \(String(describing: self))")
    }

    func fetch(ids _: [String]) -> AnyPublisher<[PersistentStoreStocksInfo], Error> {
        fatalError("fetch(count:) not implemented for \(String(describing: self))")
    }
}
