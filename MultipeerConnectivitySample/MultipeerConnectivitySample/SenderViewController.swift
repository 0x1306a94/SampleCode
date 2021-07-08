//
//  SenderViewController.swift
//  MultipeerConnectivitySample
//
//  Created by king on 2021/7/8.
//

import MultipeerConnectivity
import UIKit

class SenderViewController: UIViewController {
	var session: MCSession?
	var peer = MCPeerID(displayName: UIDevice.current.name)
	var browser: MCNearbyServiceBrowser?

	var peerID: MCPeerID?

	@IBOutlet var textView: UITextView!

	@IBOutlet var scanButton: UIButton!

	@IBOutlet var senderButton: UIButton!
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white

		title = "发送者"
		textView.text = ""
		setup()
	}

	@IBAction func senderAction(_ sender: UIButton) {
		guard let session = self.session, let peerID = self.peerID, session.connectedPeers.contains(peerID) else { return }
		let content = "\(UIDevice.current.name) Hello Wolrd"
		guard let data = content.data(using: .utf8) else { return }
		do {
			try session.send(data, toPeers: [peerID], with: .reliable)
		} catch {
			print("发送失败:", error)
		}
	}

	@IBAction func scanAction(_ sender: UIButton) {
//		let vc = MCBrowserViewController(browser: browser!, session: session!)
//		vc.maximumNumberOfPeers = 1
//		vc.delegate = self
//		present(vc, animated: true, completion: nil)

		browser?.startBrowsingForPeers()
	}
}

extension SenderViewController {
	func setup() {
		senderButton.isEnabled = false

		session = MCSession(peer: peer)
		session?.delegate = self

		browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
		browser?.delegate = self
//		browser?.startBrowsingForPeers()
	}
}

extension SenderViewController: MCSessionDelegate {
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		guard let selectPeerID = self.peerID, selectPeerID.displayName == peerID.displayName else {
			return
		}

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

extension SenderViewController: MCNearbyServiceBrowserDelegate {
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
		guard let MainPeerIDName = info?["MainPeerIDName"], MainPeerIDName == peerID.displayName else { return }

		self.peerID = peerID
		print(peerID, info!)
		browser.invitePeer(peerID, to: session!, withContext: nil, timeout: 10.0)
	}

	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		self.peerID = nil
	}

	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		print(error)
		browser.stopBrowsingForPeers()
	}
}

extension SenderViewController: MCBrowserViewControllerDelegate {
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		browserViewController.dismiss(animated: true, completion: nil)
	}

	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		browserViewController.dismiss(animated: true, completion: nil)
	}

	func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) -> Bool {
		print(peerID)
		return true
	}
}
