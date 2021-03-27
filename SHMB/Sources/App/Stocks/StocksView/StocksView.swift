import Foundation

enum StocksState {
    enum Content {
        case all([StocksInfo])
        case searching([StocksInfo], String)
        case empty(EmptyInfo)
    }

    case loading(LoadingInfo)
    case main(Content)
    case favourite(Content)
    case error(ErrorInfo)
}

protocol StocksView {
    func show(_ state: StocksState)
}
