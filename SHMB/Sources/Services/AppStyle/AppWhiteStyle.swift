import Foundation
import os.log
import UIKit

struct AppWhiteStyle: AppStyle {
    var stocksTable =
        StocksTableStyle(contentInset: .init(top: 16, left: 16, bottom: 16, right: 16))
    var backgroundColor = UIColor.white
    var tintColor = UIColor(red: 20 / 255, green: 20 / 255, blue: 255 / 255, alpha: 1)
    var navigationTintColor = UIColor.white
    var navigationTitleColor = UIColor.white
    var navigationBarTintColor = UIColor.white
    var scrollViewIndicatorStyle = UIScrollView.IndicatorStyle.white

    var searchBar = SearchBarStyle(
        height: 64,
        tintColor: .black,
        backgroundColor: .clear,
        barTintColor: .clear,
        searchBarStyle: .minimal,
        returnKeyType: .search,
        showsCancelButton: false,
        showsBookmarkButton: false
    )
    var segmentControl = SegmentControlStyle(height: 32, tintColor: .black)
    var stocksCell = StocksCellStyle(
        height: 68,
        cornerRadius: 16,
        imageStyle: ImageStyle(cornerRadious: 12, placeholderColor: .lightGray),
        favouriteButtonNormal: UIColor(red: 0.729, green: 0.729, blue: 0.729, alpha: 1),
        favouriteButtonSelected: UIColor(red: 1, green: 0.791, blue: 0.108, alpha: 1),
        titleLabel: LabelStyle(
            font: UIFont.systemFont(ofSize: 18, weight: .bold),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        ),
        subtitleLabel: LabelStyle(
            font: UIFont.systemFont(ofSize: 12, weight: .bold),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        ),
        priceLabel: LabelStyle(
            font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        ),
        changeLabel: PriceChangeLabelStyle(
            font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            positiveColor: UIColor(red: 0.14, green: 0.7, blue: 0.364, alpha: 1),
            negativeColor: UIColor(red: 0.7, green: 0.14, blue: 0.14, alpha: 1)
        ),
        evenBackgroundColor: UIColor.white,
        oddBackgroundColor: UIColor(red: 0.941, green: 0.955, blue: 0.97, alpha: 1),
        contentInset: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 12)
    )
    var errorCell = ErrorCellStyle(
        height: 200,
        imageTintColor: UIColor.red,
        buttonTintColor: UIColor.blue,
        label: LabelStyle(
            font: UIFont.systemFont(ofSize: 18),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        )
    )

    var emptyCell = EmptyCellStyle(
        height: 110,
        label: LabelStyle(
            font: UIFont.systemFont(ofSize: 18),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        )
    )
    var loadingCell = LoadingCellStyle(
        height: 100,
        label: LabelStyle(
            font: UIFont.systemFont(ofSize: 18),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        )
    )

    static func font(name: String, size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            os_log(.error, "Unable to find font with name `%s`.", name)
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        return font
    }
}
