import os.log
import UIKit

class StocksViewController: UIViewController {
    enum Section: Int {
        case searchbar
        case stocks
    }

    enum Item: Hashable {
        case stocks(StocksInfo)
        case error(ErrorInfo)
        case empty(EmptyInfo)
        case loading(LoadingInfo)
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private var presenter: StocksPresenter!
    private let appStyle: AppStyle
    private let l10n: L10n
    private var dataSource: DataSource?

    private var collectionView: UICollectionView!

    // MARK: UIViewController life cycle

    init(serviceProvider: ServiceProvider) {
        self.appStyle = serviceProvider.appStyle
        self.l10n = serviceProvider.l10n
        super.init(nibName: nil, bundle: nil)
        self.presenter = .init(view: self, serviceProvider: serviceProvider)
        self.setupUI()
        self.setupDataSource()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.in(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.in(.viewWillAppear)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: Setup

    private func setupUI() {
        // View
        self.view.backgroundColor = self.appStyle.backgroundColor

        // Navigation bar
        self.title = self.l10n.localized(.screen_stocks_title_main)
        self.navigationController?.navigationBar.tintColor = self.appStyle.navigationTintColor
        self.navigationController?.navigationBar.barTintColor = self.appStyle.navigationBarTintColor
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar
            .titleTextAttributes = [.foregroundColor: self.appStyle.navigationTitleColor]

        // Collection View
        let layout =
            UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.indicatorStyle = self.appStyle.scrollViewIndicatorStyle
        self.collectionView.delegate = self
        self.collectionView.register(
            .init(nibName: "StocksCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: StocksCollectionViewCell.identifier
        )
        self.collectionView.register(
            .init(nibName: "StocksLoadingCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: StocksLoadingCollectionViewCell.identifier
        )
        self.collectionView.register(
            .init(nibName: "StocksEmptyCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: StocksEmptyCollectionViewCell.identifier
        )
        self.collectionView.register(
            .init(nibName: "StocksErrorCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: StocksErrorCollectionViewCell.identifier
        )
        self.collectionView.register(
            .init(nibName: "SearchBarCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchBarCollectionReusableView.identifier
        )
        self.collectionView.register(
            .init(nibName: "StocksSegmentCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: StocksSegmentCollectionReusableView.identifier
        )
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(
            equalTo: self.view.topAnchor,
            constant: self.appStyle.stocksTable.contentInset.top
        ).isActive = true
        self.collectionView.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor,
            constant: self.appStyle.stocksTable.contentInset.left
        ).isActive = true
        self.collectionView.trailingAnchor.constraint(
            equalTo: self.view.trailingAnchor,
            constant: -self.appStyle.stocksTable.contentInset.right
        ).isActive = true
        self.collectionView.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor,
            constant: -self.appStyle.stocksTable.contentInset.bottom
        ).isActive = true

        /* Refresh control
         let refreshControl = UIRefreshControl()
         refreshControl.addTarget(self, action: #selector(self.refreshAction), for: .valueChanged)
         self.collectionView.refreshControl = refreshControl
         self.collectionView.sendSubviewToBack(refreshControl)
         */

        // Keyboard hide
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.stopEditing)
        )
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view
            .addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupDataSource() {
        self.dataSource = DataSource(
            collectionView: self.collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                switch item {
                case let .stocks(stocksInfo):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StocksCollectionViewCell.identifier,
                        for: indexPath
                    ) as? StocksCollectionViewCell
                    cell?.configure(
                        index: indexPath.row,
                        stocksInfo: stocksInfo,
                        appStyle: self.appStyle
                    ) { cmd in
                        switch cmd {
                        case let .toggleFavourite(stocksInfo):
                            self.presenter.in(.stockToggledFavourite(stocksInfo))
                        }
                    }
                    return cell
                case let .empty(emptyInfo):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StocksEmptyCollectionViewCell.identifier,
                        for: indexPath
                    ) as? StocksEmptyCollectionViewCell
                    cell?.configure(
                        appStyle: self.appStyle,
                        l10n: self.l10n,
                        emptyInfo: emptyInfo
                    )
                    return cell
                case let .error(errorInfo):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StocksErrorCollectionViewCell.identifier,
                        for: indexPath
                    ) as? StocksErrorCollectionViewCell
                    cell?.configure(
                        appStyle: self.appStyle,
                        l10n: self.l10n,
                        errorInfo: errorInfo
                    ) { [weak self] cmd in
                        switch cmd {
                        case let .tryAgain(errorInfo):
                            self?.presenter.in(.repeatRequest(errorInfo))
                        }
                    }
                    return cell
                case let .loading(loadingInfo):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StocksLoadingCollectionViewCell.identifier,
                        for: indexPath
                    ) as? StocksLoadingCollectionViewCell
                    cell?.configure(
                        appStyle: self.appStyle,
                        l10n: self.l10n,
                        loadingInfo: loadingInfo
                    )
                    return cell
                }
            }
        )
        self.dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch indexPath.section {
            case 0:
                switch kind {
                case UICollectionView.elementKindSectionHeader:
                    guard
                        let headerView = collectionView.dequeueReusableSupplementaryView(
                            ofKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: SearchBarCollectionReusableView.identifier,
                            for: indexPath
                        ) as? SearchBarCollectionReusableView
                    else {
                        preconditionFailure("Failed to load SearchBarCollectionReusableView")
                    }
                    headerView.configure(l10n: self.l10n, appStyle: self.appStyle) { cmd in
                        switch cmd {
                        case .cancel:
                            self.presenter.in(.filter(nil))
                            self.view.endEditing(true)
                        case let .search(text):
                            self.presenter.in(.filter(text))
                            self.view.endEditing(true)
                        case .textBeginEditing: break
                        case let .textChange(text):
                            self.presenter.in(.filter(text))
                        case .textEndEditing: break
                        }
                    }
                    return headerView
                default:
                    break
                }
            case 1:
                switch kind {
                case UICollectionView.elementKindSectionHeader:
                    guard
                        let headerView = collectionView.dequeueReusableSupplementaryView(
                            ofKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: StocksSegmentCollectionReusableView.identifier,
                            for: indexPath
                        ) as? StocksSegmentCollectionReusableView
                    else {
                        preconditionFailure("Failed to load StocksSegmentCollectionReusableView")
                    }
                    headerView.configure(l10n: self.l10n, appStyle: self.appStyle) { cmd in
                        switch cmd {
                        case .all:
                            self.presenter.in(.toggleFavourite(false))
                        case .favourite:
                            self.presenter.in(.toggleFavourite(true))
                        }
                    }
                    return headerView
                default:
                    break
                }
            default:
                break
            }

            return UICollectionReusableView()
        }
    }

    // MARK: Actions

    @objc
    func refreshAction() {
        self.presenter.in(.refresh)
    }

    @objc
    func stopEditing() {
        self.view.endEditing(true)
    }

    func applySnapshot(items: [Item], animatingDifferences: Bool = true, appending: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.searchbar, .stocks])
        if appending, let stocksSnapshot = self.dataSource?.snapshot(for: .stocks) {
            snapshot.appendItems(stocksSnapshot.items)
        }

        snapshot.appendItems(items, toSection: .stocks)
        self.dataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: StocksView

extension StocksViewController: StocksView {
    func show(_ state: StocksState) {
        switch state {
        case .loading:
            self.applySnapshot(items: [.loading(LoadingInfo())], appending: true)
        case let .main(content):
            switch content {
            case let .all(stocksInfos):
                self.applySnapshot(items: stocksInfos.map { .stocks($0) })
            case let .searching(stocksInfos, _):
                self.applySnapshot(items: stocksInfos.map { .stocks($0) })
            case let .empty(emptyInfo):
                self.applySnapshot(items: [.empty(emptyInfo)])
            }
        case let .favourite(content):
            switch content {
            case let .all(stocksInfos):
                self.applySnapshot(items: stocksInfos.map { .stocks($0) })
            case let .searching(stocksInfos, _):
                self.applySnapshot(items: stocksInfos.map { .stocks($0) })
            case let .empty(emptyInfo):
                self.applySnapshot(items: [.empty(emptyInfo)])
            }
        case let .error(errorInfo):
            self.applySnapshot(items: [.error(errorInfo)])
        }
    }
}

// MARK: UICollectionViewDelegate

extension StocksViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case let .stocks(stocksInfos):
            self.presenter.in(.stockSelected(stocksInfos))
        case .empty,
             .error,
             .loading:
            break
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = CGFloat(100.0)
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - contentOffset <= threshold, maximumOffset - contentOffset != -5.0 {
            self.presenter.in(.nextPage)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension StocksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // TODO: Calculate cell depending on info
        switch self.dataSource?.itemIdentifier(for: indexPath) {
        case .stocks:
            return CGSize(
                width: self.collectionView.bounds.width,
                height: CGFloat(self.appStyle.stocksCell.height)
            )
        case .empty:
            return CGSize(
                width: self.collectionView.bounds.width,
                height: CGFloat(self.appStyle.emptyCell.height)
            )
        case .error:
            return CGSize(
                width: self.collectionView.bounds.width,
                height: CGFloat(self.appStyle.errorCell.height)
            )
        case .loading:
            return CGSize(
                width: self.collectionView.bounds.width,
                height: CGFloat(self.appStyle.loadingCell.height)
            )
        case .none:
            return .zero
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        switch section {
        case 0:
            return CGSize(
                width: collectionView.bounds.size.width,
                height: self.appStyle.searchBar.height
            )
        case 1:
            return CGSize(
                width: collectionView.bounds.size.width,
                height: self.appStyle.segmentControl.height
            )
        default:
            return .zero
        }
    }
}
