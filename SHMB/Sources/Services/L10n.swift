import Foundation

enum L10nKey: String {
    case screen_stocks_title_main
    case screen_stocks_title_favourite
    case screen_stocks_search_label
    case screen_stocks_search_button_d
    case screen_stocks_search_button_w
    case screen_stocks_search_button_m
    case screen_stocks_search_button_6m
    case screen_stocks_search_button_1y
    case screen_stocks_search_button_all
    case screen_stocks_search_button_buy
}

protocol L10n {
    
    func localized(_ key: L10nKey) -> String?
    
}

class L10nImpl: L10n {
    
    func localized(_ key: L10nKey) -> String? {
        Bundle.main.localizedString(forKey: key.rawValue, value: nil, table: nil)
    }
    
}
