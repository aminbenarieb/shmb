import os.log
import SnapKit
import UIKit

class StocksViewController: UIViewController {
    enum Section {
        case searchbar
        case stocks
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, StocksInfo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StocksInfo>

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
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appStyle.stocksTable.contentInset)
        }

        // Refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshAction), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
        self.collectionView.sendSubviewToBack(refreshControl)

        // Keyboard hide
        self.view
            .addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.stopEditing)
            ))
    }

    private func setupDataSource() {
        self.dataSource = DataSource(
            collectionView: self.collectionView,
            cellProvider: { (collectionView, indexPath, stocksInfo) -> UICollectionViewCell? in
                switch indexPath.section {
                case 1:
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
                default:
                    return nil
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

    func applySnapshot(stocksInfos: [StocksInfo], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.searchbar, .stocks])
        snapshot.appendItems(stocksInfos, toSection: .stocks)
        self.dataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: StocksView

extension StocksViewController: StocksView {
    func show(_ state: StocksState) {
        switch state {
        case .loading:
            self.applySnapshot(stocksInfos: [])
            do {
                let view: StocksLoadingView = try StocksLoadingView.fromNib()
                view.configure(appStyle: self.appStyle, l10n: self.l10n)
                self.collectionView.backgroundView = view
            }
            catch let viewError {
                assert(false, viewError.localizedDescription)
                os_log(.debug, "Error %@", viewError.localizedDescription)
            }
        case let .main(content):
            switch content {
            case let .all(stocksInfos):
                self.applySnapshot(stocksInfos: stocksInfos)
                self.collectionView.backgroundView = nil
            case let .searching(stocksInfos, _):
                self.applySnapshot(stocksInfos: stocksInfos)
                self.collectionView.backgroundView = nil
            case let .empty(searchQuery):
                self.applySnapshot(stocksInfos: [])
                do {
                    let view: StocksEmptyView = try StocksEmptyView.fromNib()
                    view.configure(
                        appStyle: self.appStyle,
                        l10n: self.l10n,
                        searchQuery: searchQuery
                    )
                    self.collectionView.backgroundView = view
                }
                catch let viewError {
                    assert(false, viewError.localizedDescription)
                    os_log(.debug, "Error %@", viewError.localizedDescription)
                }
            }
        case let .favourite(content):
            switch content {
            case let .all(stocksInfos):
                self.applySnapshot(stocksInfos: stocksInfos)
                self.collectionView.backgroundView = nil
            case let .searching(stocksInfos, _):
                self.applySnapshot(stocksInfos: stocksInfos)
                self.collectionView.backgroundView = nil
            case let .empty(searchQuery):
                self.applySnapshot(stocksInfos: [])
                do {
                    let view: StocksEmptyView = try StocksEmptyView.fromNib()
                    view.configure(
                        appStyle: self.appStyle,
                        l10n: self.l10n,
                        searchQuery: searchQuery
                    )
                    self.collectionView.backgroundView = view
                }
                catch let viewError {
                    assert(false, viewError.localizedDescription)
                    os_log(.debug, "Error %@", viewError.localizedDescription)
                }
            }
        case let .error(error):
            self.applySnapshot(stocksInfos: [])
            do {
                let view: StocksErrorView = try StocksErrorView.fromNib()
                view.configure(appStyle: self.appStyle, l10n: self.l10n, error: error)
                self.collectionView.backgroundView = view
            }
            catch let viewError {
                assert(false, viewError.localizedDescription)
                os_log(.debug, "Error %@", viewError.localizedDescription)
            }
        }
    }
}

// MARK: UICollectionViewDelegate

extension StocksViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let stocksInfo = self.dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        self.presenter.in(.stockSelected(stocksInfo))
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension StocksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        CGSize(
            width: self.collectionView.bounds.width,
            height: CGFloat(self.appStyle.cell.height)
        )
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
