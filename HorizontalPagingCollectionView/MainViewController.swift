//
//  MainViewController.swift
//  HorizontalPagingCollectionView
//
//  Created by Artem Ekimov on 3/6/23.
//

import UIKit

class MainViewController: UIViewController {
    
    private struct Item {
        let color: UIColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(UICollectionViewCell.self)
        collection.showsHorizontalScrollIndicator = false
        collection.decelerationRate = .fast
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()

    private let height: CGFloat = 250
    private let scrollThreshold = 50.0
    private var beforeOffset: Double = 0
    private var afterOffset: Double = 0
    
    private var pageIndex = 0 {
        didSet {
            onPageDidChange?(oldValue, pageIndex)
        }
    }
    
    var onPageDidChange: ((Int, Int) -> Void)?
    
    private let items = [
        Item(color: UIColor.random),
        Item(color: UIColor.random),
        Item(color: UIColor.random),
        Item(color: UIColor.random),
        Item(color: UIColor.random)
    ]

    private func configureUI() {
        title = "Main"
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let item = items[indexPath.row]
        cell.backgroundColor = item.color
        cell.layer.cornerRadius = 12
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: height)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beforeOffset = scrollView.contentOffset.x
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        targetContentOffset.pointee = scrollView.contentOffset
        afterOffset = scrollView.contentOffset.x
        
        let diff = afterOffset - beforeOffset
        
        if diff >= scrollThreshold {
            pageIndex += 1
            if pageIndex >= items.count {
                pageIndex = items.count - 1
            }
        } else if diff <= -scrollThreshold {
            pageIndex -= 1
            if pageIndex < 0 {
                pageIndex = 0
                beforeOffset = 0
                afterOffset = 0
            }
        }
        
        collectionView.scrollToItem(
            at: IndexPath(item: pageIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }

}


extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }
    
    func register<T: UICollectionViewCell>(_ cell: T.Type) {
        register(T.self, forCellWithReuseIdentifier:  String(describing: T.self))
    }
}

extension UIColor {
    static var random: UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }
}
