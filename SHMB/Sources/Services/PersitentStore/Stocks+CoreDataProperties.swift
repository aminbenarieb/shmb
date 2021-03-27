import CoreData
import Foundation

extension Stocks {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Stocks> {
        return NSFetchRequest<Stocks>(entityName: "Stocks")
    }

    @NSManaged
    public var favourite: Bool
    @NSManaged
    public var id: String?
}
