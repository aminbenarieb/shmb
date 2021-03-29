import Combine
import CoreData
import os.log

public class PersistentStoreStocksInfoCoreDataImpl: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl> {
        return NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl>(entityName: "Stocks")
    }

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var subtitle: String
    @NSManaged public var isFavourite: Bool
    @NSManaged public var image: Data?
    @NSManaged public var price: Float
    @NSManaged public var priceChange: Float

}

extension PersistentStoreStocksInfoCoreDataImpl : Identifiable {}
extension PersistentStoreStocksInfoCoreDataImpl : PersistentStoreStocksInfo {}

class PersistentStoreCoreDataImpl {
    private let persistentContainer: NSPersistentContainer

    init() {
        self.persistentContainer = NSPersistentContainer(name: "SHMB")
        self.persistentContainer.loadPersistentStores { _, _ in
            // TODO: Handle error
        }
    }

    private func save(context: NSManagedObjectContext) throws {
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

    /*
    
    private func insert(id: String) throws {
        let context = self.persistentContainer.newBackgroundContext()
        let stocks = PersistentStoreStocksInfoCoreDataImpl(context: context)
        stocks.favourite = true
        stocks.id = id
        try self.save(context: context)
    }

    private func delete(id: String) throws {
        let stocks = try self.fetch(id: id)
        guard !stocks.isEmpty else {
            os_log(.debug, "Attempted to delete unexisting stocks with id = %@", id)
            return
        }
        let context = self.persistentContainer.newBackgroundContext()
        for stocksItem in stocks {
            context.delete(stocksItem)
        }
        try self.save(context: context)
    }
 
     */

}

extension PersistentStoreCoreDataImpl: PersistentStore {
    func watch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        // assert not already added
        // add to watch list
        fatalError("Not implemented")
    }
    
    func unwatch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        // assert is exist
        // remove from watch list
        fatalError("Not implemented")
    }
    
    func favourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        // assert is exist
        // mark as favourite
        fatalError("Not implemented")
    }
    
    func unfavourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        // assert is exist
        // mark as unfavourite
        fatalError("Not implemented")
    }
    
    func fetch(fetchStocksInfo: PersistentStoreFetchStocksInfo) -> AnyPublisher<[PersistentStoreStocksInfo], Error> {
        Deferred {
            Future { promise in
                do {
                    let context = self.persistentContainer.newBackgroundContext()
                    let fetchRequest: NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl> = PersistentStoreStocksInfoCoreDataImpl.fetchRequest()
                    fetchRequest.fetchBatchSize = 10
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)] // TODO: Support sorting in API
                    if let isFavourite = fetchStocksInfo.isFavourite {
                        fetchRequest.predicate = NSPredicate(format: "ANY favourite = %@",  NSNumber(value: isFavourite))
                    }
                    let fetchResult = try context.fetch(fetchRequest)
                    promise(.success(fetchResult))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
}
