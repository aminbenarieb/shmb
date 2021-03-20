import Foundation

enum StocksState {
    case loading
    case content([StocksInfo])
    case error(Error)
}
protocol StocksView {
    func show(_ state: StocksState)
}
