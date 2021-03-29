import UIKit

struct LabelStyle {
    let font: UIFont
    let color: UIColor
}

struct PriceChangeLabelStyle {
    let font: UIFont
    let positiveColor: UIColor
    let negativeColor: UIColor
}

struct ImageStyle {
    let cornerRadious: CGFloat
    let placeholderColor: UIColor
}

struct ErrorCellStyle {
    var height: CGFloat
    var imageTintColor: UIColor
    var buttonTintColor: UIColor
    var label: LabelStyle
}

struct EmptyCellStyle {
    var height: CGFloat
    var label: LabelStyle
}

struct LoadingCellStyle {
    var height: CGFloat
    var label: LabelStyle
}

struct StocksCellStyle {
    var height: CGFloat

    var cornerRadius: CGFloat

    var imageStyle: ImageStyle

    var favouriteButtonNormal: UIColor

    var favouriteButtonSelected: UIColor

    var watchButtonNormal: UIColor

    var watchButtonHighlighted: UIColor

    var titleLabel: LabelStyle

    var subtitleLabel: LabelStyle

    var priceLabel: LabelStyle

    var changeLabel: PriceChangeLabelStyle

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

    var stocksCell: StocksCellStyle { get }

    var errorCell: ErrorCellStyle { get }

    var emptyCell: EmptyCellStyle { get }

    var loadingCell: LoadingCellStyle { get }
}
