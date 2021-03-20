import Foundation

class StocksPresenter {
    
    private var view: StocksView?
    enum In {
        case viewDidLoad
        case stockSelected(StocksInfo)
    }
    
    init(view: StocksView?) {
        self.view = view
    }
    
    func `in`(_ in: In) {
        switch `in` {
        case .viewDidLoad:
            self.view?.show(.content([StocksInfo(), StocksInfo(), StocksInfo()]))
        case .stockSelected:
            break
        }
    }
    
}
