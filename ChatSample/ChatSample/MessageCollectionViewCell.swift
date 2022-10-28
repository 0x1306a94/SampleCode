//
//  MessageCollectionViewCell.swift
//  ChatSample
//
//  Created by king on 2022/10/28.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    lazy var testView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(testView)
    }
    
    func configuration(viewModel: MessageCellViewModel) {
        let origin: CGPoint
        if viewModel.incomming {
            origin = .zero
            self.testView.backgroundColor = .purple
        } else {
            origin = CGPoint(x: self.bounds.width - viewModel.size.width, y: 0)
            self.testView.backgroundColor = .yellow
        }
        let frame = CGRect(origin: origin, size: viewModel.size)
//        UIView.performWithoutAnimation {
            self.testView.frame = frame
//        }
    }
}
