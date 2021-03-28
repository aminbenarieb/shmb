import Combine
import Foundation
import os.log

class StocksPresenter {
    private let webClient: WebClient
    private let persistentStore: PersistentFavouritesStore

    private var data: [StocksInfo]
    private var page: Int
    private var state: StocksState {
        didSet {
            os_log(.debug, "State -> %s", String(describing: self.state))
            DispatchQueue.main.async {
                self.view?.show(self.state)
            }
        }
    }

    private var cancelableSet: Set<AnyCancellable>
    private var view: StocksView?

    enum In {
        case viewDidLoad
        case viewWillAppear
        case stockSelected(StocksInfo)
        case stockToggledFavourite(StocksInfo)
        case toggleFavourite(Bool)
        case refresh
        case nextPage
        case repeatRequest(ErrorInfo)
        case filter(String?)
    }

    init(view: StocksView?, serviceProvider: ServiceProvider) {
        self.webClient = serviceProvider.webClient
        self.persistentStore = serviceProvider.persistentStore
        self.view = view
        self.data = []
        self.page = 1
        self.state = .main(.all([]))
        self.cancelableSet = Set()
    }

    func `in`(_ in: In) {
        os_log(.debug, "In -> %s", String(describing: `in`))
        switch `in` {
        case .viewDidLoad:
            break
        case .viewWillAppear:
            self.update()
        case .stockSelected:
            // TODO: Show detail stocks screen
            os_log(.debug, ".stockSelected not implemented yet")
        case .refresh:
            // TODO: Refresh stocks
            os_log(.debug, ".refresh not implemented yet")
        case .repeatRequest:
            // TODO: Repeat failed request
            os_log(.debug, ".repeatRequest not implemented yet")
        case .nextPage:
            switch self.state {
            case .error,
                 .loading:
                return
            case .favourite,
                 .main:
                break
            }
            self.page += 1
            self.update()
        case let .stockToggledFavourite(stocksInfo):
            self.toggleFavourite(stocksInfo: stocksInfo, for: self.state)
            switch self.state {
            case .favourite,
                 .main:
                self.toggleFavourite(stocksInfo: stocksInfo, for: self.state)
            case .error,
                 .loading:
                break
            }
        case let .filter(text):
            self.search(query: text)
        case let .toggleFavourite(onlyFavourites):
            switch self.state {
            case let .main(content):
                guard onlyFavourites else { return }
                switch content {
                case .all:
                    self.state = .favourite(self.favourites())
                case let .empty(emptyInfo):
                    if emptyInfo.searchQuery?.isEmpty == false {
                        return
                    }
                    self
                        .state = .favourite(
                            self.favourites()
                        )
                case .searching:
                    break
                }
            case let .favourite(content):
                guard !onlyFavourites else { return }
                switch content {
                case .all:
                    self.state = .main(.all(self.data))
                case let .empty(emptyInfo):
                    if emptyInfo.searchQuery?.isEmpty == false {
                        return
                    }
                    self.state = .main(.all(self.data))
                case .searching:
                    break
                }
            case .error,
                 .loading:
                break
            }
        }
    }
}

extension StocksPresenter {
    private func favourites() -> StocksState.Content {
        let favourites = self.data.filter { $0.isFavourite == true }
        guard !favourites.isEmpty else {
            return .empty(EmptyInfo())
        }

        return .all(favourites)
    }

    private func toggleFavourite(stocksInfo: StocksInfo, for state: StocksState) {
        let newFavouriteValue = !stocksInfo.isFavourite
        let publisher = newFavouriteValue
            ? self.persistentStore.add(id: stocksInfo.id)
            : self.persistentStore.remove(id: stocksInfo.id)
        publisher
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.state = .error(ErrorInfo(localizedDescription: error.localizedDescription))
                case .finished:
                    self.data = self.data.map {
                        guard $0.id == stocksInfo.id else {
                            return $0
                        }
                        return stocksInfo.copy(isFavourite: newFavouriteValue)
                    }
                    switch state {
                    case .main:
                        self.state = .main(.all(self.data))
                    case .favourite:
                        self.state = .favourite(self.favourites())
                    case .error,
                         .loading:
                        return
                    }
                }
            } receiveValue: { success in
                let result = newFavouriteValue ? "added: \(success)" : "removed: \(success)"
                os_log(.debug, "%@", result)
            }
            .store(in: &self.cancelableSet)
    }

    private func update() {
        self.state = .loading(LoadingInfo())
        self.webClient.stocks(page: self.page)
            .flatMap { response -> AnyPublisher<[StocksInfo], Error> in
                let stocksInfos = response.value
                let idsToFetch = stocksInfos.map { $0.id }
                return self.persistentStore.fetch(ids: idsToFetch)
                    .map { persistentStoreStocksInfos -> [StocksInfo] in
                        stocksInfos.map { stocksInfo in
                            guard
                                let persistentStoreStocksInfo = persistentStoreStocksInfos
                                .first(where: { $0.id == stocksInfo.id })
                            else {
                                return stocksInfo
                            }
                            return stocksInfo.copy(isFavourite: persistentStoreStocksInfo.favourite)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.state = .error(ErrorInfo(localizedDescription: error.localizedDescription))
                case .finished:
                    self.state = .main(.all(self.data))
                }
            } receiveValue: { [weak self] stocksInfos in
                guard let self = self else { return }
                self.data = stocksInfos
            }
            .store(in: &self.cancelableSet)
    }

    private func search(query _: String?) {
        // TODO: Throttle searching
        /// Hightlights:  https://stackoverflow.com/questions/24330056/how-to-throttle-search-based-on-typing-speed-in-ios-uisearchbar
        // Search Query
//        guard !query.isEmpty else {
//            return .all(data)
//        }
//
//        guard !filteredData.isEmpty else {
//            return .empty(EmptyInfo(searchQuery: query))
//        }
//
//        return .searching(filteredData, text)
    }
}
