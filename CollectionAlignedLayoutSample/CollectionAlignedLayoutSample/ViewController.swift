//
//  ViewController.swift
//  CollectionAlignedLayoutSample
//
//  Created by king on 2024/7/8.
//

import UIKit

class CustomCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.orange
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let layout = CollectionViewAlignedLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = CGSize(width: 50, height: 80)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPrefetchingEnabled = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.register(CustomCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        view.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return view
    }()

    let dataSource: [[String]] = [
        ["仪表盘"],
        ["音乐", "音量"],
        ["变速", "时间凝固时间凝固时间凝固", "截屏"],
        ["变速", "时间凝固", "截屏截屏截屏截屏截屏截屏", "大变速", "时间凝固", "变速", "时间凝固", "变速", "时间凝固"],
        ["变速", "时间凝固", "截屏", "变速变速变速变速", "时间凝固", "截屏", "变速", "时间凝固", "截屏"],
        ["变速", "时间凝固", "截屏"],
        ["变速", "时间凝固", "截屏"],
        ["变速", "时间凝固", "截屏"],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 60),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
        ])

        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataSource[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.backgroundColor = UIColor.clear
        cell.titleLabel.text = self.dataSource[indexPath.section][indexPath.item]
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {}

extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 0)
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}
