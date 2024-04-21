//
//  ViewController.swift
//  CustomCollectionViewLayout
//
//  Created by king on 2024/4/21.
//

import UIKit

class ViewController: UIViewController {
    lazy var layout: CustomCollectionViewLayout = {
        let layout = CustomCollectionViewLayout()
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = CustomCollectionViewLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        // 右边多增加一点,应该是宽度放大时增加的两倍
        let right = (self.layout.itemWidth * self.layout.maximumScale - self.layout.itemWidth) * 2.0
        view.contentInset = UIEdgeInsets(top: 0, left: self.layout.spacing, bottom: 0, right: right)
        view.contentInsetAdjustmentBehavior = .never
        view.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.clipsToBounds = false
        view.backgroundColor = .label
        return view
    }()
    
    var dataCount = 0
    /// 尽量多一点
    let amplification = 30
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: 120),
        ])
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.dataCount = 20
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        let item = CGFloat(self.dataCount * (self.amplification >> 1))
        let targetContentOffsetX = item * self.layout.itemWidth + item * self.layout.spacing - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPointMake(targetContentOffsetX, 0), animated: false)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataCount * self.amplification
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.indexLabel.text = "\(indexPath.item / self.dataCount) - \(indexPath.item % self.dataCount)"
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidCompleteStop(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidCompleteStop(scrollView)
    }
    
    func scrollViewDidCompleteStop(_ scrollView: UIScrollView) {
        guard self.dataCount > 0, let layout = self.collectionView.collectionViewLayout as? CustomCollectionViewLayout else {
            return
        }
        
        var visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
        visibleRect = visibleRect.insetBy(dx: -layout.itemWidth, dy: 0)
        guard let target = layout.findAdsorbLayoutAttribute(in: visibleRect) else {
            return
        }
        
        let realIndex = target.indexPath.item % self.dataCount
        let page = target.indexPath.item / self.dataCount
        let range = 4 ..< (self.amplification - 4)
        if range.contains(page) {
            return
        }
        
        print("reset")
        let item = CGFloat(self.dataCount * (self.amplification >> 1) + realIndex)
        let targetContentOffsetX = item * layout.itemWidth + item * layout.spacing - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPointMake(targetContentOffsetX, 0), animated: false)
    }
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
    public var spacing: CGFloat = 10
    public var itemWidth: CGFloat = 100
    
    public var maximumScale: CGFloat = 1.4
    public var minimumScale: CGFloat = 1.0
    
    private var contentWidth: CGFloat = 0
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        return CGSize(width: self.contentWidth, height: collectionView.bounds.height)
    }
        
    override func prepare() {
        super.prepare()
            
        guard let collectionView = collectionView else { return }
            
        self.layoutAttributes.removeAll()
        
        let itemHeight = collectionView.frame.height
        let contentInset = collectionView.contentInset
            
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let contentOffsetX = collectionView.contentOffset.x
            
        let length = self.itemWidth + self.spacing
        
        let scaleIncrement = (self.maximumScale - self.minimumScale) / length
        
        var prev = CGRect(x: -spacing, y: 0, width: 0, height: 0)
        
        for item in 0 ..< itemCount {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
            var originFrame = CGRect(x: CGFloat(item) * self.itemWidth + CGFloat(item) * self.spacing, y: 0, width: self.itemWidth, height: itemHeight)
            self.contentWidth = originFrame.maxX
            
            let xPosition = originFrame.minX - contentOffsetX - contentInset.left
            var scale: CGFloat = 1.0

            if xPosition < 0 {
                scale = max(self.minimumScale, self.maximumScale + scaleIncrement * xPosition)
            } else if xPosition < length {
                scale = self.maximumScale - scaleIncrement * xPosition
            }
//            print(item, xPosition, scale)

            originFrame.size.width = self.itemWidth * scale
            originFrame.size.height = itemHeight * scale
            originFrame.origin.y = itemHeight - originFrame.height
            originFrame.origin.x = prev.maxX + self.spacing
            attributes.frame = originFrame
            prev = originFrame
            
            self.layoutAttributes.append(attributes)
        }
    }
        
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributes.filter { $0.frame.intersects(rect) }
    }
        
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        var visibleRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
        visibleRect = visibleRect.insetBy(dx: -self.itemWidth, dy: 0)
        guard let target = self.findAdsorbLayoutAttribute(in: visibleRect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let item = CGFloat(target.indexPath.item)
        let targetContentOffsetX = item * self.itemWidth + item * self.spacing - collectionView.contentInset.left
        return CGPoint(x: targetContentOffsetX, y: proposedContentOffset.y)
    }
    
    func findAdsorbLayoutAttribute(in rect: CGRect) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        guard let layoutAttributesForVisibleCells = self.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        let contentOffsetX: CGFloat = collectionView.contentOffset.x
        var minX = CGFloat.greatestFiniteMagnitude
        var target: UICollectionViewLayoutAttributes? = nil
//        print("========")
        for attributes in layoutAttributesForVisibleCells {
            let xPosition = attributes.frame.minX - contentOffsetX
            if abs(xPosition) < minX {
                minX = abs(xPosition)
                target = attributes
            }
        }
        
        return target
    }
}
