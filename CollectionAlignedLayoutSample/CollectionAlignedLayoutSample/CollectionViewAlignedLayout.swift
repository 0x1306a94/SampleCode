//
//  CollectionViewAlignedLayout.swift
//  CollectionAlignedLayoutSample
//
//  Created by king on 2024/7/8.
//

import UIKit

class CollectionViewAlignedLayout: UICollectionViewFlowLayout {
    func alignedLines(lines: [UICollectionViewLayoutAttributes], sectionInset: UIEdgeInsets) -> [UICollectionViewLayoutAttributes] {
        guard !lines.isEmpty else {
            return []
        }
        var minY = lines.first!.frame.minY
        for item in lines {
            minY = min(minY, item.frame.minY)
        }

        let minimumInteritemSpacing = self.minimumInteritemSpacing
        var result: [UICollectionViewLayoutAttributes] = []
        var minX = sectionInset.left
        for item in lines.sorted(by: { $0.frame.minX < $1.frame.minX }) {
            let copied = item.copy() as! UICollectionViewLayoutAttributes
            var frame = copied.frame
//            print("frame", frame.origin, minX, minY)
            frame.origin.x = minX
            frame.origin.y = minY
            copied.frame = frame
            result.append(copied)

            minX = frame.maxX + minimumInteritemSpacing
        }
        return result
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let sources = super.layoutAttributesForElements(in: rect) else {
            return []
        }

        var results: [UICollectionViewLayoutAttributes] = []

        var lineMaps: [CGFloat: [UICollectionViewLayoutAttributes]] = [:]
        for item in sources {
            if item.representedElementCategory == .cell {
                let midY = floor(item.frame.midY)
                lineMaps[midY, default: [UICollectionViewLayoutAttributes]()].append(item)
            } else {
                results.append(item)
            }
        }

        for (_, line) in lineMaps where !line.isEmpty {
            let section = line.first!.indexPath.section

            var sectionInset = self.sectionInset
            if let collectionView = self.collectionView, let delegate = collectionView.delegate, delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))) {
                sectionInset = (delegate as! UICollectionViewDelegateFlowLayout).collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? sectionInset
            }

            results.append(contentsOf: alignedLines(lines: line, sectionInset: sectionInset))
        }

        return results
    }
}
