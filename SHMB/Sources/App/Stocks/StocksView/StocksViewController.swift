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
        self.presenter = .init(view: self)
        self.setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.in(.viewWillAppear)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if
            let flowLayout = self.collectionView
            .collectionViewLayout as? UICollectionViewFlowLayout
        {
            flowLayout.itemSize = CGSize(
                width: self.collectionView.bounds.width,
                height: CGFloat(self.appStyle.cell.height)
            )
        }
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
            StocksCollectionViewFlowLayout(appStyle: self.appStyle)
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
                        stocksInfo: stocksInfo,
                        appStyle: self.appStyle
                    )
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
                            self.presenter.in(.search(nil))
                            self.view.endEditing(true)
                        case let .search(text):
                            self.presenter.in(.search(text))
                            self.view.endEditing(true)
                        case .textBeginEditing: break
                        case let .textChange(text):
                            self.presenter.in(.search(text))
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
                            self.presenter.in(.favourite(false))
                        case .favourite:
                            self.presenter.in(.favourite(true))
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
        case let .content(stocksInfos):
            self.applySnapshot(stocksInfos: stocksInfos)
        case let .error(error):
            self.applySnapshot(stocksInfos: [])
        }
    }
}

// MARK: UICollectionViewLayout

class StocksCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private let appStyle: AppStyle

    init(appStyle: AppStyle) {
        self.appStyle = appStyle
        super.init()
        self.setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
//        self.minimumLineSpacing = CGFloat(self.configuration.minimumLineSpacing)
//        self.minimumInteritemSpacing = CGFloat(self.configuration.minimumInteritemSpacing)
//        self.sectionInset = UIEdgeInsets(top: 16, left: 50, bottom: 16, right: 50)
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
