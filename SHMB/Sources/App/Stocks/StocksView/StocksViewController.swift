//
//  StocksViewController.swift
//  SHMB
//
//  Created by Amin Benarieb on 20.03.2021.
//

import UIKit

class StocksViewController: UIViewController {

    private var presenter: StocksPresenter!
    private let configuration: Configuration; struct Configuration {
        let cellHeight: Float = 120
    }
    private var stocksInfos: [StocksInfo]
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    // MARK: UIViewController life cycle
    
    init(configuration: Configuration) {
        self.configuration = configuration
        self.stocksInfos = []
        super.init(nibName: "StocksViewController", bundle: nil)
        self.presenter = .init(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.presenter.in(.viewDidLoad)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.collectionView.bounds.width, height: CGFloat(self.configuration.cellHeight))
        }
    }
    
    
    // MARK: Setup
    
    private func setup() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(.init(nibName: "StocksCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StocksCollectionViewCell")
    }

}

// MARK: StocksView

extension StocksViewController: StocksView {
    
    func show(_ state: StocksState) {
        switch state {
        case .loading:
            // TODO: Show loading
            break
        case let .content(stocksInfos):
            self.stocksInfos = stocksInfos
            self.collectionView.reloadData()
        case let .error(error):
            // TODO: Show error
            break
        }
    }
    
}

// MARK: UICollectionViewDataSource

extension StocksViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stocksInfos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StocksCollectionViewCell", for: indexPath) as! StocksCollectionViewCell
        cell.configure(stocksInfo: .init(image: UIImage(systemName: "lasso.sparkles"), title: "Title", isFavourite: indexPath.row % 2 == 0, subtitle: "Subtite", price: Float(indexPath.row), priceChange: .init(value: Float(indexPath.row)/10, percoent: Float(indexPath.row)/100)))
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension StocksViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Show next screen
    }
}
