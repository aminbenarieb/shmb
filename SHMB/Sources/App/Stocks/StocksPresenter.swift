import Foundation

class StocksPresenter {
    private var data: [StocksInfo]
    private var view: StocksView?
    enum In {
        case viewDidLoad
        case viewWillAppear
        case stockSelected(StocksInfo)
        case refresh
        case search(String?)
        case favourite(Bool)
    }

    init(view: StocksView?) {
        self.view = view
        self.data = []
        for i in 0..<10 {
            self.data.append(
                StocksInfo(
                    id: i,
                    imageURL: nil,
                    title: "Title \(i)",
                    isFavourite: true,
                    subtitle: "Subtitle \(i)",
                    price: Float(i) * 10,
                    priceChange: .init(value: Float(i), percent: Float(i) / 100),
                    currency: "$"
                )
            )
        }
    }

    func `in`(_ in: In) {
        switch `in` {
        case .viewDidLoad:
            break
        case .viewWillAppear:
            self.view?.show(.content(self.data))
        case .stockSelected:
            break
        case .refresh:
            break
        case let .favourite(favourite):
            guard favourite else {
                self.view?.show(.content(self.data))
                return
            }
            self.view?.show(.content(self.data.filter { $0.isFavourite }))
        case let .search(text):
            guard let text = text, !text.isEmpty else {
                self.view?.show(.content(self.data))
                return
            }
            self.view?
                .show(.content(
                    self.data
                        .filter { $0.title.localizedCaseInsensitiveContains(text) }
                ))
        }
    }
}
