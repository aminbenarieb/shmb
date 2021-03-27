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

    private var stocksInfo: StocksInfo?
    private var out: Out?; typealias Out = (Cmd) -> Void; enum Cmd {
        case toggleFavourite(StocksInfo)
    }

    // MARK: View life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.stocksInfo = nil
        self.imageView.image = nil
        self.favouriteButton.setImage(nil, for: .normal)
        self.favouriteButton.tintColor = .clear
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
        index: Int,
        stocksInfo: StocksInfo,
        appStyle: AppStyle,
        out: Out?
    ) {
        self.stocksInfo = stocksInfo
        self.out = out

        // Image
        self.imageView.image = stocksInfo.image
        self.imageView.backgroundColor = appStyle.stocksCell.imageStyle.placeholderColor
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = appStyle.stocksCell.imageStyle.cornerRadious

        // Title
        self.titleLabel.text = stocksInfo.title
        self.titleLabel.font = appStyle.stocksCell.titleLabel.font
        self.titleLabel.textColor = appStyle.stocksCell.titleLabel.color

        // Favourite button
        self.favouriteButton.setImage(
            UIImage(systemName: stocksInfo.isFavourite ? "star.fill" : "star"),
            for: .normal
        )
        self.favouriteButton.tintColor = stocksInfo.isFavourite ? appStyle.stocksCell
            .favouriteButtonSelected : appStyle.stocksCell.favouriteButtonNormal

        // Subtitle
        self.subtitleLabel.text = stocksInfo.subtitle
        self.subtitleLabel.font = appStyle.stocksCell.subtitleLabel.font
        self.subtitleLabel.textColor = appStyle.stocksCell.subtitleLabel.color

        // Price
        let currencyFormatter = NumberFormatter()
        currencyFormatter.locale = Locale.current
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 2
        if let price = stocksInfo.price, let currency = stocksInfo.currency {
            currencyFormatter.currencyCode = currency
            if let formattedPrice = currencyFormatter.string(from: price as NSNumber) {
                self.priceLabel.text = String(format: "%@", formattedPrice)
            }
            else {
                self.priceLabel.text = String(format: "%@%.1lf", currency, price)
            }
            self.priceLabel.textColor = appStyle.stocksCell.priceLabel.color
            self.priceLabel.font = appStyle.stocksCell.priceLabel.font
        }
        else {
            self.priceLabel.text = nil
        }

        // Price change
        let percentFormatter = NumberFormatter()
        percentFormatter.locale = Locale.current
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 0
        if
            let priceChangePercent = stocksInfo.priceChangePercent,
            let priceChange = stocksInfo.priceChange,
            let currency = stocksInfo.currency
        {
            var priceChangeValues = [String]()
            if
                let formattedCurrency = currencyFormatter
                .string(from: priceChange as NSNumber)
            {
                priceChangeValues.append(String(
                    format: "%@",
                    formattedCurrency
                ))
            }
            else {
                priceChangeValues.append(String(
                    format: "%@%.1lf",
                    currency,
                    priceChange
                ))
            }
            if priceChangePercent != .nan {
                if
                    let formattedPercent = percentFormatter
                    .string(from: priceChangePercent as NSNumber)
                {
                    priceChangeValues.append(String(
                        format: "(%@)",
                        formattedPercent
                    ))
                }
                else {
                    priceChangeValues.append(String(
                        format: "(%.1lf%%)",
                        priceChangePercent
                    ))
                }
            }
            self.priceChangeLabel.text = priceChangeValues.joined(separator: " ")
            self.priceChangeLabel.textColor = priceChange < 0
                ? appStyle.stocksCell.changeLabel.negativeColor
                : appStyle.stocksCell.changeLabel.positiveColor
            self.priceChangeLabel.font = appStyle.stocksCell.changeLabel.font
        }
        else {
            self.priceChangeLabel.text = nil
        }

        // Content view
        self.contentView.backgroundColor = (index % 2 == 0) ? appStyle.stocksCell
            .evenBackgroundColor : appStyle.stocksCell.oddBackgroundColor
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = CGFloat(appStyle.stocksCell.cornerRadius)
        self.backgroundColor = .clear
    }

    // MARK: Setup

    private func setup() {}

    // MARK: Actions

    @IBAction
    private func favouriteAction(_: Any) {
        guard let stocksInfo = self.stocksInfo else { return }
        self.out?(.toggleFavourite(stocksInfo))
    }
}
