import UIKit

class StocksSegmentCollectionReusableView: UICollectionReusableView {
    static let identifier = "StocksSegmentCollectionReusableView"

    @IBOutlet
    private var segmentControl: UISegmentedControl!

    private var out: Out?; typealias Out = (Cmd) -> Void; enum Cmd {
        case all
        case favourite
    }

    // MARK: Configure

    func configure(l10n: L10n, appStyle: AppStyle, _ out: @escaping Out) {
        self.segmentControl.tintColor = appStyle.segmentControl.tintColor
        self.segmentControl.removeAllSegments()
        self.segmentControl.insertSegment(
            withTitle: l10n.localized(.screen_stocks_title_main),
            at: 0,
            animated: false
        )
        self.segmentControl.insertSegment(
            withTitle: l10n.localized(.screen_stocks_title_favourite),
            at: 1,
            animated: false
        )
        self.segmentControl.selectedSegmentIndex = 0
        self.out = out
    }

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: Actions

    @IBAction
    private func segmentControlAction(_: Any) {
        switch self.segmentControl.selectedSegmentIndex {
        case 0:
            self.out?(.all)
        case 1:
            self.out?(.favourite)
        default:
            break
        }
    }
}
