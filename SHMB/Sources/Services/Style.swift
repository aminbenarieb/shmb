import os.log
import UIKit

struct LabelStyle {
    let font: UIFont
    let color: UIColor
}

struct ImageStyle {
    let cornerRadious: CGFloat
    let placeholderColor: UIColor
}

struct CellStyle {
    var height: CGFloat

    var cornerRadius: CGFloat

    var imageStyle: ImageStyle

    var favouriteButtonNormal: UIColor

    var favouriteButtonSelected: UIColor

    var titleLabel: LabelStyle

    var subtitleLabel: LabelStyle

    var priceLabel: LabelStyle

    var changeLabel: LabelStyle

    var evenBackgroundColor: UIColor

    var oddBackgroundColor: UIColor

    var contentInset: UIEdgeInsets
}

struct SearchBarStyle {
    var height: CGFloat
    var contentViewBackgrounColor = UIColor.white
    var tintColor: UIColor
    var backgroundColor: UIColor
    var barTintColor: UIColor
    var searchBarStyle: UISearchBar.Style
    var returnKeyType: UIReturnKeyType
    var showsCancelButton: Bool
    var showsBookmarkButton: Bool
}

struct SegmentControlStyle {
    var height: CGFloat
    var tintColor: UIColor
}

struct StocksTableStyle {
    let contentInset: UIEdgeInsets
}

protocol AppStyle {
    var stocksTable: StocksTableStyle { get }
    var backgroundColor: UIColor { get }
    var tintColor: UIColor { get }

    var navigationTintColor: UIColor { get }

    var navigationTitleColor: UIColor { get }

    var navigationBarTintColor: UIColor { get }

    var scrollViewIndicatorStyle: UIScrollView.IndicatorStyle { get }

    var searchBar: SearchBarStyle { get }

    var segmentControl: SegmentControlStyle { get }

    var cell: CellStyle { get }
}

struct AppWhiteStyle: AppStyle {
    var stocksTable =
        StocksTableStyle(contentInset: .init(top: 16, left: 16, bottom: 16, right: 16))
    var backgroundColor = UIColor.white
    var tintColor = UIColor(red: 20, green: 20, blue: 255, alpha: 1)
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
    var cell = CellStyle(
        height: 68,
        cornerRadius: 16,
        imageStyle: ImageStyle(cornerRadious: 12, placeholderColor: .lightGray),
        favouriteButtonNormal: UIColor(red: 0.729, green: 0.729, blue: 0.729, alpha: 1),
        favouriteButtonSelected: UIColor(red: 1, green: 0.791, blue: 0.108, alpha: 1),
        titleLabel: LabelStyle(
            font: AppWhiteStyle.font(name: "Montserrat-Bold", size: 18),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        ),
        subtitleLabel: LabelStyle(
            font: AppWhiteStyle.font(name: "Montserrat-SemiBold", size: 12),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        ),
        priceLabel: LabelStyle(
            font: AppWhiteStyle.font(name: "Montserrat-SemiBold", size: 18),
            color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        ),
        changeLabel: LabelStyle(
            font: AppWhiteStyle.font(name: "Montserrat-SemiBold", size: 12),
            color: UIColor(red: 0.14, green: 0.7, blue: 0.364, alpha: 1)
        ),
        evenBackgroundColor: UIColor.white,
        oddBackgroundColor: UIColor(red: 0.941, green: 0.955, blue: 0.97, alpha: 1),
        contentInset: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 12)
    )

    static func font(name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            os_log(.error, "Unable to find font with name `%s`.", name)
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
