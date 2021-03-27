import UIKit

class StocksLoadingCollectionViewCell: UICollectionViewCell {
    @IBOutlet
    private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet
    private var label: UILabel!

    static let identifier = "StocksLoadingCollectionViewCell"

    // MARK: Setup

    func configure(appStyle _: AppStyle, l10n: L10n, loadingInfo _: LoadingInfo) {
        self.label.text = l10n.localized(.loading)
        self.label.numberOfLines = 0
        self.label.textAlignment = .center
        self.activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
    }
}
