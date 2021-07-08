//
//  ReceiverViewController.swift
//  MultipeerConnectivitySample
//
//  Created by king on 2021/7/8.
//

import MultipeerConnectivity
import UIKit

class ReceiverViewController: UIViewController {
	var session: MCSession?
	var peer = MCPeerID(displayName: UIDevice.current.name)
	var advertiser: MCNearbyServiceAdvertiser?

	@IBOutlet var textView: UITextView!
	@IBOutlet var broadcastButton: UIButton!
	@IBOutlet var senderButton: UIButton!
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white
		title = "接收者"
		textView.text = ""
		setup()
	}

	@IBAction func senderAction(_ sender: UIButton) {
		guard let session = self.session, !session.connectedPeers.isEmpty else { return }
		let content = "\(UIDevice.current.name) Hello Wolrd"
		guard let data = content.data(using: .utf8) else { return }
		do {
			try session.send(data, toPeers: session.connectedPeers, with: .reliable)
		} catch {
			print("发送失败:", error)
		}
	}

	@IBAction func broadcastAction(_ sender: UIButton) {
		advertiser?.startAdvertisingPeer()
	}
}

extension ReceiverViewController {
	func setup() {
		senderButton.isEnabled = false

		session = MCSession(peer: peer)
		session?.delegate = self

		let discoveryInfo = [
			"MainPeerIDName" : peer.displayName,
		]
		advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: discoveryInfo, serviceType: serviceType)
		advertiser?.delegate = self
//		advertiser?.startAdvertisingPeer()
	}
}

extension ReceiverViewController: MCSessionDelegate {
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		DispatchQueue.main.async {
			switch state {
			case .notConnected: self.textView.text.append("未连接\n")
			case .connecting: self.textView.text.append("连接中...\n")
			case .connected: self.textView.text.append("已连接\n")
			@unknown default:
				self.textView.text.append("未知状态\n")
			}
			self.senderButton.isEnabled = state == .connected
			self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count, 0))
		}
	}

	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		guard let content = String(data: data, encoding: .utf8) else {
			return
		}

		DispatchQueue.main.async {
			self.textView.text.append("\(content)\n")
			self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count, 0))
		}
	}

	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension ReceiverViewController: MCNearbyServiceAdvertiserDelegate {
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		print(peerID)

		let alert = UIAlertController(title: nil, message: "接收到\(peerID.displayName)邀请", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "接受", style: .destructive, handler: { _ in
			invitationHandler(true, self.session)
		}))
		alert.addAction(UIAlertAction(title: "拒绝", style: .cancel, handler: { _ in
			invitationHandler(false, self.session)
		}))

		present(alert, animated: true, completion: nil)
	}

	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		advertiser.stopAdvertisingPeer()
	}
}
