import UIKit

class SearchBarCollectionReusableView: UICollectionReusableView {
    static let identifier = "SearchBarCollectionReusableView"

    @IBOutlet
    private var searchBar: UISearchBar!

    private var out: Out?; typealias Out = (Cmd) -> Void; enum Cmd {
        case search(String?)
        case cancel
        case textChange(String)
        case textBeginEditing(String?)
        case textEndEditing(String?)
    }

    // MARK: Configure

    func configure(l10n: L10n, appStyle: AppStyle, _ out: @escaping Out) {
        self.out = out
        self.backgroundColor = appStyle.searchBar.contentViewBackgrounColor
        self.searchBar.tintColor = appStyle.searchBar.tintColor
        self.searchBar.placeholder = l10n.localized(.screen_stocks_search_label)
        self.searchBar.backgroundColor = appStyle.searchBar.backgroundColor
        self.searchBar.barTintColor = appStyle.searchBar.barTintColor
        self.searchBar.searchBarStyle = appStyle.searchBar.searchBarStyle
        self.searchBar.returnKeyType = appStyle.searchBar.returnKeyType
        self.searchBar.showsCancelButton = appStyle.searchBar.showsCancelButton
        self.searchBar.showsBookmarkButton = appStyle.searchBar.showsBookmarkButton
    }

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
        self.searchBar.delegate = self
    }
}

extension SearchBarCollectionReusableView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.out?(.search(searchBar.text))
    }

    func searchBarCancelButtonClicked(_: UISearchBar) {
        self.out?(.cancel)
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        self.out?(.textChange(searchText))
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.out?(.textBeginEditing(searchBar.text))
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.out?(.textEndEditing(searchBar.text))
    }
}
