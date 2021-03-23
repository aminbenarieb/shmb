import Foundation
import os.log

class StocksPresenter {
    private var webClient: WebClient
    private var data: [StocksInfo]
    private var view: StocksView?
    private var state: StocksState {
        didSet {
            os_log(.debug, "State -> %s", String(describing: self.state))
            DispatchQueue.main.async {
                self.view?.show(self.state)
            }
        }
    }

    private var token: Any?

    enum In {
        case viewDidLoad
        case viewWillAppear
        case stockSelected(StocksInfo)
        case stockToggledFavourite(StocksInfo)
        case toggleFavourite(Bool)
        case refresh
        case filter(String?)
    }

    init(view: StocksView?, serviceProvider: ServiceProvider) {
        self.webClient = serviceProvider.webClient
        self.view = view
        self.data = []
        self.state = .main(.all([]))
    }

    func `in`(_ in: In) {
        switch `in` {
        case .viewDidLoad:
            break
        case .viewWillAppear:
            self.state = .loading
            self.token = self.webClient.stocks()
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case let .failure(error):
                        self.state = .error(error)
                    case .finished:
                        self.state = .main(.all(self.data))
                    }
                } receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.data = response.value
                }
        case .stockSelected:
            break
        case .refresh:
            break
        case let .stockToggledFavourite(stocksInfo):
//            TODO:
//            self.data = self.data.map {
//                guard $0.id == stocksInfo.id else {
//                    return $0
//                }
//                return stocksInfo.copy(isFavourite: !stocksInfo.isFavourite)
//            }
            break
        case let .filter(text):
            switch self.state {
            case .main:
                self.state = .main(self.filtered(text: text))
            case .favourite:
                self.state = .favourite(self.filtered(favourite: true, text: text))
            case .error,
                 .loading:
                break
            }
        case let .toggleFavourite(onlyFavourites):
            switch self.state {
            case let .main(content):
                guard onlyFavourites else { return }
                switch content {
                case .all:
                    self.state = .favourite(self.filtered(favourite: true))
                case let .empty(searchQuery):
                    self.state = .favourite(self.filtered(favourite: true, text: searchQuery))
                case let .searching(_, searchQuery):
                    self.state = .favourite(self.filtered(favourite: true, text: searchQuery))
                }
            case let .favourite(content):
                guard !onlyFavourites else { return }
                switch content {
                case .all:
                    self.state = .main(.all(self.data))
                case let .empty(searchQuery):
                    self.state = .main(self.filtered(text: searchQuery))
                case let .searching(_, searchQuery):
                    self.state = .main(self.filtered(text: searchQuery))
                }
            case .error,
                 .loading:
                break
            }
        }
    }
}

extension StocksPresenter {
    func filtered(favourite: Bool? = nil, text: String? = nil) -> StocksState.Content {
        // Favourite
        let data = favourite != nil
            ? self.data.filter { $0.isFavourite == favourite }
            : self.data
        // Search Query
        guard let text = text, !text.isEmpty else {
            return .all(data)
        }
        let filteredData = data.filter { $0.title.localizedCaseInsensitiveContains(text) }
        guard !filteredData.isEmpty else {
            return .empty(text)
        }

        return .searching(filteredData, text)
    }
}
