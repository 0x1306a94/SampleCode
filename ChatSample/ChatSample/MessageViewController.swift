//
//  MessageViewController.swift
//  ChatSample
//
//  Created by king on 2022/10/28.
//

import UIKit

class MessageViewController: UIViewController {
    var contentInset: UIEdgeInsets {
        set {
#if USE_COLLECTION_VIEW
            self.collectionView.contentInset = newValue
#else
            self.tableView.contentInset = newValue
#endif
        }
        get {
#if USE_COLLECTION_VIEW
            self.collectionView.contentInset
#else
            self.tableView.contentInset
#endif
        }
    }

#if USE_COLLECTION_VIEW
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize.zero
        layout.scrollDirection = .vertical

        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        v.backgroundColor = .clear
        v.keyboardDismissMode = .onDrag
        v.register(MessageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        return v
    }()
#else
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        v.backgroundColor = .clear
        v.keyboardDismissMode = .onDrag
        v.register(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return v
    }()
#endif

    var messages: [MessageCellViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.view.backgroundColor = UIColor(named: "backgroundColor")

#if USE_COLLECTION_VIEW
        self.setupCollectionView()
#else
        self.setupTableView()
#endif

        self.messages = [Int](0 ..< 20).map { MessageCellViewModel(incomming: $0 & 1 == 0, size: CGSize(width: self.view.frame.width * CGFloat(Float.random(in: 0.4 ..< 0.6)), height: 200.0 * CGFloat(Float.random(in: 0.2 ..< 0.6)))) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
#if USE_COLLECTION_VIEW
        self.collectionView.reloadData()
#else
        self.tableView.reloadData()
#endif
    }

#if USE_COLLECTION_VIEW
    func setupCollectionView() {
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
#else
    func setupTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
#endif
}

extension MessageViewController {
    func scrollToBottom(animated: Bool) {
#if USE_COLLECTION_VIEW
        let offset = self.collectionView.contentSize.height - self.collectionView.bounds.height + self.collectionView.contentInset.bottom
        self.collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
#else
        let offset = self.tableView.contentSize.height - self.tableView.bounds.height + self.tableView.contentInset.bottom
        self.tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
#endif
    }
}

extension MessageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MessageCollectionViewCell else {
            fatalError()
        }

        cell.configuration(viewModel: self.messages[indexPath.item])
        return cell
    }
}

extension MessageViewController: UICollectionViewDelegate {}

extension MessageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width
        return CGSize(width: w, height: self.messages[indexPath.item].size.height)
    }
}

extension MessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? MessageTableViewCell else {
            fatalError()
        }

        cell.configuration(viewModel: self.messages[indexPath.item])
        return cell
    }
}

extension MessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.messages[indexPath.row].size.height + 20
    }
}
