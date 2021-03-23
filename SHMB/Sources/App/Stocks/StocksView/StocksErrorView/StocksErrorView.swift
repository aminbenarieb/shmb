import UIKit

class StocksErrorView: UIView {
    @IBOutlet
    private var imageView: UIImageView!
    @IBOutlet
    private var label: UILabel!
    @IBOutlet
    private var button: UIButton!

    // MARK: Setup

    func configure(appStyle: AppStyle, l10n: L10n, error: Error) {
        self.imageView.tintColor = appStyle.tintColor
        self.label.text = l10n.localized(.error, error.localizedDescription)
        self.button.tintColor = appStyle.tintColor
    }
}
