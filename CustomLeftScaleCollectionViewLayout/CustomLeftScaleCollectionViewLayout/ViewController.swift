//
//  ViewController.swift
//  CustomCollectionViewLayout
//
//  Created by king on 2024/4/21.
//

import UIKit

class ViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let layout = CustomCollectionViewLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        view.contentInsetAdjustmentBehavior = .never
        view.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.clipsToBounds = false
        view.backgroundColor = .label
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.indexLabel.text = "\(indexPath.item)"
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let collectionViewLayout = collectionView.collectionViewLayout
//
//        let visibleRect = CGRect(origin: targetContentOffset.pointee, size: collectionView.bounds.size)
//        guard let layoutAttributesForVisibleCells = collectionViewLayout.layoutAttributesForElements(in: visibleRect) else {
//            return
//        }
//
//        let contentOffsetX: CGFloat = collectionView.contentOffset.x
//        var minX = CGFloat.greatestFiniteMagnitude
//        var target: UICollectionViewLayoutAttributes? = nil
//        for attributes in layoutAttributesForVisibleCells {
//            let xPosition = attributes.frame.minX - contentOffsetX
//            print(attributes.indexPath.item, xPosition)
//            if abs(xPosition) < minX {
//                minX = abs(xPosition)
//                target = attributes
//            }
//        }
//
//        guard let target = target else {
//            return
//        }
//
//        let targetContentOffsetX = target.frame.minX - collectionView.contentInset.left
//
//        targetContentOffset.pointee.x = targetContentOffsetX
//    }
}

class CustomCollectionViewCell: UICollectionViewCell {
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .red
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .orange
        self.contentView.addSubview(self.indexLabel)
        self.indexLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.indexLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.indexLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomCollectionViewLayout: UICollectionViewLayout {
    private let spacing: CGFloat = 10
    private let itemWidth: CGFloat = 100
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    private let maximumScale: CGFloat = 1.4
    private let minimumScale: CGFloat = 1.0
    private var contentWidth: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        return CGSize(width: contentWidth, height: collectionView.bounds.height)
    }
        
    override func prepare() {
        super.prepare()
            
        guard let collectionView = collectionView else { return }
            
        layoutAttributes.removeAll()
        
        let itemHeight = collectionView.frame.height
        let contentInset = collectionView.contentInset
            
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let contentOffsetX = collectionView.contentOffset.x
            
        let length = itemWidth + spacing
        
        let scaleIncrement = (self.maximumScale - self.minimumScale) / length
        
        var prev = CGRect(x: -spacing, y: 0, width: 0, height: 0)
        
        for item in 0 ..< itemCount {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
            var originFrame = CGRect(x: CGFloat(item) * itemWidth + CGFloat(item) * spacing, y: 0, width: itemWidth, height: itemHeight)
            
            let xPosition = originFrame.minX - contentOffsetX - contentInset.left
            var scale: CGFloat = 1.0

            if xPosition < 0 {
                scale = max(self.minimumScale, self.maximumScale + scaleIncrement * xPosition)
            } else if xPosition < length {
                scale = self.maximumScale - scaleIncrement * xPosition
            }
//            print(item, xPosition, scale)

            originFrame.size.width = itemWidth * scale
            originFrame.size.height = itemHeight * scale
            originFrame.origin.y = itemHeight - originFrame.height
            originFrame.origin.x = prev.maxX + spacing
            attributes.frame = originFrame
            prev = originFrame
            
            layoutAttributes.append(attributes)
        }
        
        contentWidth = prev.maxX
    }
        
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter { $0.frame.intersects(rect) }
    }
        
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        var visibleRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
        visibleRect = visibleRect.insetBy(dx: -itemWidth, dy: 0)
        guard let layoutAttributesForVisibleCells = layoutAttributesForElements(in: visibleRect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        let contentOffsetX: CGFloat = collectionView.contentOffset.x
        var minX = CGFloat.greatestFiniteMagnitude
        var target: UICollectionViewLayoutAttributes? = nil
        print("========")
        for attributes in layoutAttributesForVisibleCells {
            let xPosition = attributes.frame.minX - contentOffsetX
            print(attributes.indexPath.item, xPosition)
            if abs(xPosition) < minX {
                minX = abs(xPosition)
                target = attributes
            }
        }

        guard let target = target else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        let targetContentOffsetX = target.frame.minX - collectionView.contentInset.left
        return CGPoint(x: targetContentOffsetX, y: proposedContentOffset.y)
    }
}
