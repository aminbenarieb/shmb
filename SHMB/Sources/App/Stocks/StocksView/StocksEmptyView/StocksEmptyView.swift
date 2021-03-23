import UIKit

class StocksEmptyView: UIView {
    @IBOutlet
    private var label: UILabel!

    // MARK: Setup

    func configure(appStyle _: AppStyle, l10n: L10n, searchQuery: String? = nil) {
        switch searchQuery {
        case let .some(searchQuery):
            self.label.text = l10n.localized(.empty_search, searchQuery)
        case .none:
            self.label.text = l10n.localized(.empty)
        }
    }
}
