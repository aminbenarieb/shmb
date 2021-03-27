import UIKit

class StocksEmptyCollectionViewCell: UICollectionViewCell {
    @IBOutlet
    private var label: UILabel!

    static let identifier = "StocksEmptyCollectionViewCell"

    // MARK: Setup

    func configure(appStyle _: AppStyle, l10n: L10n, emptyInfo: EmptyInfo) {
        switch emptyInfo.searchQuery {
        case let .some(searchQuery):
            self.label.text = l10n.localized(.emptySearch, searchQuery)
        case .none:
            self.label.text = l10n.localized(.empty)
        }
        self.label.numberOfLines = 0
        self.label.textAlignment = .center
    }
}
