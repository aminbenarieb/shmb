import UIKit

class StocksCollectionViewCell: UICollectionViewCell {
    static let identifier = "StocksCollectionViewCell"

    @IBOutlet
    private var stackView: UIStackView!
    @IBOutlet
    private var imageView: UIImageView!
    @IBOutlet
    private var titleLabel: UILabel!
    @IBOutlet
    private var favouriteButton: UIButton!
    @IBOutlet
    private var subtitleLabel: UILabel!
    @IBOutlet
    private var priceLabel: UILabel!
    @IBOutlet
    private var priceChangeLabel: UILabel!

    // MARK: View life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.favouriteButton.setImage(nil, for: .normal)
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        self.priceLabel.text = nil
        self.priceChangeLabel.text = nil
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.75 : 1.0
        }
    }

    // MARK: Configure

    func configure(
        stocksInfo: StocksInfo,
        appStyle: AppStyle
    ) {
        // Image
        // TODO: Load image asyncly
        // self.imageView.image = stocksInfo.image
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = appStyle.cell.imageStyle.cornerRadious

        // Title
        self.titleLabel.text = stocksInfo.title
        self.titleLabel.font = appStyle.cell.titleLabel.font
        self.titleLabel.textColor = appStyle.cell.titleLabel.color

        // Favourite button
        self.favouriteButton.setImage(
            UIImage(systemName: stocksInfo.isFavourite ? "star.fill" : "star"),
            for: .normal
        )
        self.favouriteButton.tintColor = stocksInfo.isFavourite ? appStyle.cell
            .favouriteButtonSelected : appStyle.cell.favouriteButtonNormal

        // Subtitle
        self.subtitleLabel.text = stocksInfo.subtitle
        self.subtitleLabel.font = appStyle.cell.subtitleLabel.font
        self.subtitleLabel.textColor = appStyle.cell.subtitleLabel.color

        // Price
        let currencyFormatter = NumberFormatter()
        currencyFormatter.locale = Locale.current
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 2
        if let formattedPrice = currencyFormatter.string(from: stocksInfo.price as NSNumber) {
            self.priceLabel.text = String(format: "%@", formattedPrice)
        }
        else {
            self.priceLabel.text = String(format: "%@%.1lf", stocksInfo.currency, stocksInfo.price)
        }
        self.priceLabel.textColor = appStyle.cell.priceLabel.color
        self.priceLabel.font = appStyle.cell.priceLabel.font

        // Price change
        let percentFormatter = NumberFormatter()
        percentFormatter.locale = Locale.current
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 2
        if
            let formattedPercent = percentFormatter
            .string(from: stocksInfo.priceChange.percent as NSNumber),
            let formattedCurrency = currencyFormatter
            .string(from: stocksInfo.priceChange.value as NSNumber)
        {
            self.priceChangeLabel.text = String(
                format: "%@ (%@)",
                formattedCurrency,
                formattedPercent
            )
        }
        else {
            self.priceChangeLabel.text = String(
                format: "%@%.1lf (%.1lf%%)",
                stocksInfo.currency,
                stocksInfo.priceChange.value,
                stocksInfo.priceChange.percent
            )
        }
        self.priceChangeLabel.textColor = appStyle.cell.changeLabel.color
        self.priceChangeLabel.font = appStyle.cell.changeLabel.font

        // Content view
        self.contentView.backgroundColor = (stocksInfo.id % 2 == 0) ? appStyle.cell
            .evenBackgroundColor : appStyle.cell.oddBackgroundColor
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = CGFloat(appStyle.cell.cornerRadius)
        self.backgroundColor = .clear
    }

    // MARK: Setup

    private func setup() {}

    // MARK: Actions

    @IBAction
    private func favouriteAction(_: Any) {}
}
