import UIKit

class StocksLoadingView: UIView {
    @IBOutlet
    private var label: UILabel!

    // MARK: Setup

    func configure(appStyle _: AppStyle, l10n: L10n) {
        self.label.text = l10n.localized(.loading)
    }
}
