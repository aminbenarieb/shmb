import Foundation

enum StocksState {
    enum Content {
        case data([StocksInfo])
        case empty(EmptyInfo)
        case loading(LoadingInfo)
        case error(ErrorInfo)
    }

    case main(Content)
    case searching(Content, String)

    func mutated(_ transform: (Content) -> (Content)) -> StocksState {
        switch self {
        case let .main(content):
            return .main(transform(content))
        case let .searching(content, query):
            return .searching(transform(content), query)
        }
    }
}

protocol StocksView {
    func show(_ state: StocksState)
}
