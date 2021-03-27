import Foundation

enum L10nKey: String {
    case screen_stocks_title_main = "screen.stocks.title.main"
    case screen_stocks_title_favourite = "screen.stocks.title.favourite"
    case screen_stocks_search_label = "screen.stocks.search.label"
    case screen_stocks_detail_button_d = "screen.stocks.detail.button_d"
    case screen_stocks_detail_button_w = "screen.stocks.detail.button_w"
    case screen_stocks_detail_button_m = "screen.stocks.detail.button_m"
    case screen_stocks_detail_button_6m = "screen.stocks.detail.button_6m"
    case screen_stocks_detail_button_1y = "screen.stocks.detail.button_1y"
    case screen_stocks_detail_button_all = "screen.stocks.detail.button_all"
    case screen_stocks_detail_button_buy = "screen.stocks.detail.button_buy"
    case emptySearch = "empty_search"
    case empty
    case error
    case tryAgain = "try_again"
    case loading
}

protocol L10n {
    func localized(_ key: L10nKey, _ args: CVarArg...) -> String
}
