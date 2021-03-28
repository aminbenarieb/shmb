import Combine
import Foundation
import os.log

class StocksPresenter {
    private let webClient: WebClient
    private let persistentStore: PersistentFavouritesStore

    struct Page<T> {
        let data: T
        let page: Int
    }

    private var watchListPage: Page<[StocksInfo]>
    private var searchListPage: Page<[StocksInfo]>
    private var state: StocksState {
        didSet {
            os_log(.debug, "State -> %s", String(describing: self.state))
            DispatchQueue.main.async {
                self.view?.show(self.state)
            }
        }
    }

    private var searchSubject: PassthroughSubject<String, Error>
    private var cancelableSet: Set<AnyCancellable>
    private var cancelableSearchSet: Set<AnyCancellable>
    private var cancelableSearch: AnyCancellable?
    private var cancelablePersistentStoreSet: Set<AnyCancellable>

    private var view: StocksView?

    enum StocksAction {
        case selected
        case toggleFavourite
    }

    enum In {
        case viewDidLoad
        case viewWillAppear
        case stocksAction(StocksInfo, StocksAction)
        case filterFavourites(Bool)
        case refresh
        case nextPage
        case repeatRequest(ErrorInfo)
        case filter(String?)
    }

    init(view: StocksView?, serviceProvider: ServiceProvider) {
        self.webClient = serviceProvider.webClient
        self.persistentStore = serviceProvider.persistentStore
        self.view = view
        self.searchListPage = .init(data: [], page: 0)
        self.watchListPage = .init(data: [], page: 0)
        self.state = .main(.data([]))
        self.searchSubject = PassthroughSubject()
        self.cancelableSet = Set()
        self.cancelableSearchSet = Set()
        self.cancelablePersistentStoreSet = Set()
        self.cancelableSearch = self.searchSubject
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] query in
                self?._search(query: query)
            })
    }

    func `in`(_ in: In) {
        os_log(.debug, "In -> %s", String(describing: `in`))
        switch `in` {
        case .viewDidLoad:
            break
        case .viewWillAppear:
            self.fetch()
        case let .stocksAction(stocksInfo, action):
            switch action {
            case .selected:
                // TODO: Show detail stocks screen
                os_log(.debug, ".stockSelected not implemented yet")
            case .toggleFavourite:
                self.toggleFavourite(stocksInfo: stocksInfo, for: self.state)
            }
        case .refresh:
            // TODO: Refresh stocks
            os_log(.debug, ".refresh not implemented yet")
        case .repeatRequest:
            // TODO: Repeat failed request
            os_log(.debug, ".repeatRequest not implemented yet")
        case .nextPage:
            switch self.state {
            case .searching:
                return
            case .main:
                self.fetch()
            }
        case let .filter(text):
            self.search(query: text)
        case let .filterFavourites(onlyFavourites):
            switch self.state {
            case let .main(content):
                switch content {
                case .data:
                    let newData = self.watchListPage.data
                        .filter { $0.isFavourite == onlyFavourites }
                    self.state = .main(newData.isEmpty ? .empty(EmptyInfo()) : .data(newData))
                case let .empty(emptyInfo):
                    if emptyInfo.searchQuery?.isEmpty == false {
                        return
                    }
                    let newData = self.watchListPage.data
                        .filter { $0.isFavourite == onlyFavourites }
                    self.state = .main(newData.isEmpty ? .empty(EmptyInfo()) : .data(newData))
                case .error,
                     .loading:
                    break
                }
            case .searching:
                break
            }
        }
    }
}

extension StocksPresenter {
    private func toggleFavourite(stocksInfo: StocksInfo, for _: StocksState) {
        let newFavouriteValue = !stocksInfo.isFavourite
        let publisher = newFavouriteValue
            ? self.persistentStore.add(id: stocksInfo.id)
            : self.persistentStore.remove(id: stocksInfo.id)
        publisher
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.state = self.state.mutated { _ in
                        .error(ErrorInfo(localizedDescription: error.localizedDescription))
                    }
                case .finished:
                    self.state = self.state.mutated { content in
                        switch content {
                        case let .data(stocks):
                            let newStocks = stocks.map { (oldStocksInfo) -> StocksInfo in
                                guard oldStocksInfo.id == stocksInfo.id else {
                                    return oldStocksInfo
                                }
                                return oldStocksInfo.copy(isFavourite: newFavouriteValue)
                            }
                            return .data(newStocks)
                        case .empty,
                             .error,
                             .loading:
                            return content
                        }
                    }
                }
            } receiveValue: { success in
                let result = newFavouriteValue ? "added: \(success)" : "removed: \(success)"
                os_log(.debug, "%@", result)
            }
            .store(in: &self.cancelableSet)
    }

    private func fetch() {
        // Fetch watch list
        self.state = .main(.loading(LoadingInfo(position: .bottom)))
        self.state = .main(.empty(EmptyInfo()))
    }

    private func search(query: String?) {
        self.cancelableSearchSet = Set()
        guard let query = query, !query.isEmpty else {
            self.state = .main(
                self.watchListPage.data.isEmpty
                    ? .empty(EmptyInfo())
                    : .data(self.watchListPage.data)
            )
            return
        }

        self.searchSubject.send(query)
    }

    private func _search(query: String) {
        self.state = .searching(.loading(LoadingInfo(position: .top)), query)
        self.webClient.stocks(query: query)
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
                    self.state = .searching(
                        .error(ErrorInfo(localizedDescription: error.localizedDescription)),
                        query
                    )
                case .finished:
                    self.state = .searching(
                        self.searchListPage.data
                            .isEmpty ? .empty(EmptyInfo(searchQuery: query)) :
                            .data(self.searchListPage.data),
                        query
                    )
                }
            } receiveValue: { [weak self] stocksInfos in
                guard let self = self else { return }
                self.searchListPage = .init(data: stocksInfos, page: 1)
            }
            .store(in: &self.cancelableSearchSet)
    }
}
