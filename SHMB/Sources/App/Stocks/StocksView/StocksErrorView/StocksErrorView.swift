import UIKit

class StocksErrorView: UIView {
    private let error: Error
    private let appStyle: AppStyle
    private let l10n: L10n
    @IBOutlet
    private var imageView: UIImageView!
    @IBOutlet
    private var label: UILabel!
    @IBOutlet
    private var button: UIButton!

    // MARK: Lifecycle

    init(appStyle: AppStyle, l10n: L10n, error: Error) {
        self.error = error
        self.appStyle = appStyle
        self.l10n = l10n
        super.init(frame: .zero)
        self.setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    func setup() {
        self.imageView.tintColor = self.appStyle.tintColor
        self.label.text = self.l10n.localized(.error, self.error.localizedDescription)
        self.button.tintColor = self.appStyle.tintColor
    }
}
