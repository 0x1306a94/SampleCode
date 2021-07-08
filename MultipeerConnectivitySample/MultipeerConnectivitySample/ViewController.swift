//
//  ViewController.swift
//  MultipeerConnectivitySample
//
//  Created by king on 2021/7/8.
//

import UIKit

let serviceType = "checkticket"

class ViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func senderAction(_ sender: UIButton) {
		let vc = SenderViewController()
		navigationController?.pushViewController(vc, animated: true)
	}

	@IBAction func receiverAction(_ sender: UIButton) {
		let vc = ReceiverViewController()
		navigationController?.pushViewController(vc, animated: true)
	}
}
