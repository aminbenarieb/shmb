import UIKit

class StocksErrorCollectionViewCell: UICollectionViewCell {
    @IBOutlet
    private var imageView: UIImageView!
    @IBOutlet
    private var label: UILabel!
    @IBOutlet
    private var button: UIButton!

    static let identifier = "StocksErrorCollectionViewCell"
    private var out: Out?; typealias Out = (Cmd) -> Void; enum Cmd {
        case tryAgain(ErrorInfo)
    }

    // MARK: Setup

    func configure(appStyle: AppStyle, l10n: L10n, errorInfo: ErrorInfo, out: Out? = nil) {
        self.imageView.tintColor = appStyle.errorCell.imageTintColor
        self.label.font = appStyle.errorCell.label.font
        self.label.textColor = appStyle.errorCell.label.color
        self.label.text = l10n.localized(.error, errorInfo.localizedDescription)
        self.label.numberOfLines = 0
        self.label.textAlignment = .center
        self.button.tintColor = appStyle.errorCell.buttonTintColor
        self.button.setTitle(l10n.localized(.tryAgain), for: .normal)
        self.button.addAction(UIAction(handler: { _ in
            out?(.tryAgain(errorInfo))
        }), for: .touchUpInside)
    }
}
