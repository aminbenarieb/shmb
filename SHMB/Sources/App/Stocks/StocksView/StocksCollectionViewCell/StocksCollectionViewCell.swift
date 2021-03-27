import Combine
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

    private var set = Set<AnyCancellable>()
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
        // TODO: Load image asyncly
        if let url = stocksInfo.imageURL {
            WebClientFakeImpl(environment: Environment(keyValueStorage: [:])).image(url: url)
                .sink { _ in

                } receiveValue: { [weak self] r in
                    self?.imageView.image = r.value
                }
                .store(in: &self.set)
        }
        self.imageView.backgroundColor = appStyle.cell.imageStyle.placeholderColor
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
        if let price = stocksInfo.price, let currency = stocksInfo.currency {
            currencyFormatter.currencyCode = currency
            if let formattedPrice = currencyFormatter.string(from: price as NSNumber) {
                self.priceLabel.text = String(format: "%@", formattedPrice)
            }
            else {
                self.priceLabel.text = String(format: "%@%.1lf", currency, price)
            }
            self.priceLabel.textColor = appStyle.cell.priceLabel.color
            self.priceLabel.font = appStyle.cell.priceLabel.font
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
            let priceChange = stocksInfo.priceChange, let currency = stocksInfo.currency
        {
            if
                let formattedPercent = percentFormatter
                .string(from: priceChangePercent as NSNumber),
                let formattedCurrency = currencyFormatter
                .string(from: priceChange as NSNumber)
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
                    currency,
                    priceChange,
                    priceChangePercent
                )
            }
            self.priceChangeLabel.textColor = priceChange < 0
                ? appStyle.cell.changeLabel.negativeColor
                : appStyle.cell.changeLabel.positiveColor
            self.priceChangeLabel.font = appStyle.cell.changeLabel.font
        }
        else {
            self.priceChangeLabel.text = nil
        }

        // Content view
        self.contentView.backgroundColor = (index % 2 == 0) ? appStyle.cell
            .evenBackgroundColor : appStyle.cell.oddBackgroundColor
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = CGFloat(appStyle.cell.cornerRadius)
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
