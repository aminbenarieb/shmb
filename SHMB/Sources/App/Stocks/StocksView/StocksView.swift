import Foundation

enum StocksState {
    enum Content {
        case all([StocksInfo])
        case searching([StocksInfo], String)
        case empty(String?)
    }

    case loading
    case main(Content)
    case favourite(Content)
    case error(Error)
}

protocol StocksView {
    func show(_ state: StocksState)
}
