import Combine
import CoreData
import os.log

@objc(PersistentStoreStocksInfoCoreDataImpl)
public class PersistentStoreStocksInfoCoreDataImpl: NSManagedObject {
    @nonobjc
    public class func fetchRequest()
        -> NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl>
    {
        return NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl>(entityName: "Stocks")
    }

    @NSManaged
    public var isFavouriteNumber: NSDecimalNumber?
    @NSManaged
    public var id: String
    @NSManaged
    public var imageURL: URL?
    @NSManaged
    public var priceNumber: NSDecimalNumber?
    @NSManaged
    public var priceChangeNumber: NSDecimalNumber?
    @NSManaged
    public var subtitle: String
    @NSManaged
    public var title: String
    @NSManaged
    public var currency: String?
}

extension PersistentStoreStocksInfoCoreDataImpl: Identifiable {}
extension PersistentStoreStocksInfoCoreDataImpl: PersistentStoreStocksInfo {
    var price: Float? {
        self.priceNumber?.floatValue
    }

    var priceChange: Float? {
        self.priceChangeNumber?.floatValue
    }

    var isFavourite: Bool? {
        self.isFavouriteNumber?.boolValue ?? false
    }
}

class PersistentStoreCoreDataImpl {
    private let persistentContainer: NSPersistentContainer

    init() {
        self.persistentContainer = NSPersistentContainer(name: "SHMB")
        self.persistentContainer.loadPersistentStores { _, _ in
            // TODO: Handle error
        }
    }

    private func save(context: NSManagedObjectContext) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { promise in
                context.perform {
                    guard context.hasChanges else {
                        os_log(.debug, "Attempted to save context without actual changes")
                        promise(.success(false))
                        return
                    }
                    do {
                        try context.save()
                        promise(.success(true))
                    }
                    catch {
                        context.rollback()
                        promise(.failure(error))
                    }
                    context.reset()
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension PersistentStoreCoreDataImpl: PersistentStore {
    func watch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<NSManagedObjectContext, Error> { promise in
                do {
                    let context = self.persistentContainer.newBackgroundContext()
                    let fetchRequest: NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl> =
                        PersistentStoreStocksInfoCoreDataImpl.fetchRequest()
                    fetchRequest.predicate = NSPredicate(
                        format: "ANY id = %@", stocksInfo.id
                    )
                    let fetchedStocksInfos = try context.fetch(fetchRequest)
                    guard fetchedStocksInfos.isEmpty else {
                        os_log(
                            .debug,
                            "Attempted to add already existing stocks with id = %@",
                            stocksInfo.id
                        )
                        promise(.success(context))
                        return
                    }
                    let stocks = PersistentStoreStocksInfoCoreDataImpl(context: context)
                    stocks.id = stocksInfo.id
                    stocks.title = stocksInfo.title
                    stocks.subtitle = stocksInfo.subtitle
                    stocks.currency = stocksInfo.currency
                    stocks.isFavouriteNumber = stocksInfo.isFavourite
                        .map { NSDecimalNumber(booleanLiteral: $0) }
                    stocks.priceNumber = stocksInfo.price
                        .map { NSDecimalNumber(floatLiteral: Double($0)) }
                    stocks.imageURL = stocksInfo.imageURL
                    promise(.success(context))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .flatMap { context -> AnyPublisher<Bool, Error> in
            self.save(context: context)
        }
        .eraseToAnyPublisher()
    }

    func unwatch(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<NSManagedObjectContext, Error> { promise in
                do {
                    let context = self.persistentContainer.newBackgroundContext()
                    let fetchRequest: NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl> =
                        PersistentStoreStocksInfoCoreDataImpl.fetchRequest()
                    fetchRequest.predicate = NSPredicate(
                        format: "ANY id = %@", stocksInfo.id
                    )
                    let fetchedStocksInfos = try context.fetch(fetchRequest)
                    guard let fetchedStocksInfo = fetchedStocksInfos.first else {
                        os_log(
                            .debug,
                            "Attempted to delete unexisting stocks with id = %@",
                            stocksInfo.id
                        )
                        promise(.success(context))
                        return
                    }
                    if fetchedStocksInfos.count > 1 {
                        os_log(.debug, "There are more than one stocks with id = %@", stocksInfo.id)
                    }
                    context.delete(fetchedStocksInfo)
                    promise(.success(context))
                }
                catch {
                    promise(.failure(error))
                }
            }
            .eraseToAnyPublisher()
        }
        .flatMap { context -> AnyPublisher<Bool, Error> in
            self.save(context: context)
        }
        .eraseToAnyPublisher()
    }

    func favourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<NSManagedObjectContext, Error> { promise in
                do {
                    let context = self.persistentContainer.newBackgroundContext()
                    let fetchRequest: NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl> =
                        PersistentStoreStocksInfoCoreDataImpl.fetchRequest()
                    fetchRequest.predicate = NSPredicate(
                        format: "ANY id = %@", stocksInfo.id
                    )
                    let fetchedStocksInfos = try context.fetch(fetchRequest)
                    guard let fetchedStocksInfo = fetchedStocksInfos.first else {
                        os_log(
                            .debug,
                            "Attempted to mark favourite unexisting stocks with id = %@",
                            stocksInfo.id
                        )
                        promise(.success(context))
                        return
                    }
                    if fetchedStocksInfos.count > 1 {
                        os_log(.debug, "There are more than one stocks with id = %@", stocksInfo.id)
                    }
                    fetchedStocksInfo.isFavouriteNumber = NSDecimalNumber(booleanLiteral: true)
                    promise(.success(context))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .flatMap { context -> AnyPublisher<Bool, Error> in
            self.save(context: context)
        }
        .eraseToAnyPublisher()
    }

    func unfavourite(stocksInfo: PersistentStoreStocksInfo) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<NSManagedObjectContext, Error> { promise in
                do {
                    let context = self.persistentContainer.newBackgroundContext()
                    let fetchRequest: NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl> =
                        PersistentStoreStocksInfoCoreDataImpl.fetchRequest()
                    fetchRequest.predicate = NSPredicate(
                        format: "ANY id = %@", stocksInfo.id
                    )
                    let fetchedStocksInfos = try context.fetch(fetchRequest)
                    guard let fetchedStocksInfo = fetchedStocksInfos.first else {
                        os_log(
                            .debug,
                            "Attempted to mark favourite unexisting stocks with id = %@",
                            stocksInfo.id
                        )
                        promise(.success(context))
                        return
                    }
                    if fetchedStocksInfos.count > 1 {
                        os_log(.debug, "There are more than one stocks with id = %@", stocksInfo.id)
                    }
                    fetchedStocksInfo.isFavouriteNumber = NSDecimalNumber(booleanLiteral: false)
                    promise(.success(context))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .flatMap { context -> AnyPublisher<Bool, Error> in
            self.save(context: context)
        }
        .eraseToAnyPublisher()
    }

    func fetch(fetchStocksInfo: PersistentStoreFetchStocksInfo)
        -> AnyPublisher<[PersistentStoreStocksInfo], Error>
    {
        Deferred {
            Future { promise in
                do {
                    let context = self.persistentContainer.newBackgroundContext()
                    let fetchRequest: NSFetchRequest<PersistentStoreStocksInfoCoreDataImpl> =
                        PersistentStoreStocksInfoCoreDataImpl.fetchRequest()
                    fetchRequest.fetchBatchSize = 10
                    fetchRequest
                        .sortDescriptors =
                        [NSSortDescriptor(
                            key: "id",
                            ascending: true
                        )] // TODO: Support sorting in API
                    if let isFavourite = fetchStocksInfo.isFavourite {
                        fetchRequest.predicate = NSPredicate(
                            format: "ANY favourite = %@",
                            NSNumber(value: isFavourite)
                        )
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
