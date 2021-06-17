//
//  ViewController.swift
//  CoreDataExample
//
//  Created by king on 2021/6/15.
//

import CoreData
import UIKit

class RandomString {
	let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	func getRandomStringOfLength(length: Int) -> String {
		var ranStr = ""
		for _ in 0 ..< length {
			let index = Int(arc4random_uniform(UInt32(characters.count)))
			let start = characters.index(characters.startIndex, offsetBy: index)
			let end = characters.index(characters.startIndex, offsetBy: index)
			ranStr.append(contentsOf: characters[start ... end])
		}
		return ranStr
	}

	private init() {}

	static let sharedInstance = RandomString()
}

class ViewController: UIViewController {
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		return table
	}()

	lazy var frc: NSFetchedResultsController<User> = {
		let req = User.fetchRequest()
		req.fetchBatchSize = 5
		req.sortDescriptors = [
			NSSortDescriptor(key: "rank", ascending: true),
		]

		let ctx = CoreDataStack.shared.persistentContainer.viewContext
		let fetch = NSFetchedResultsController(fetchRequest: req, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
		return fetch
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])

		tableView.dataSource = self

		frc.delegate = self

		try? frc.performFetch()
	}

	@IBAction func addAction(_ sender: UIBarButtonItem) {
		_batchInsert()
	}

	@IBAction func batchUpdateAction(_ sender: UIBarButtonItem) {
		_batchUpdate()
	}

	func _batchInsert() {
		let ctx = CoreDataStack.shared.persistentContainer.newBackgroundContext()

		var count: Int64 = 10
		let req = NSBatchInsertRequest(entityName: "User", managedObjectHandler: {
			guard count > 0, let user = $0 as? User else {
				return true
			}
			user.name = RandomString.sharedInstance.getRandomStringOfLength(length: 6)
			user.age = Int64(arc4random_uniform(20)) + 10
			user.rank = count
			count -= 1
			return false
		})

		req.resultType = .objectIDs

		ctx.perform {
			do {
				guard let res = try ctx.execute(req) as? NSBatchInsertResult else {
					return
				}

				guard let ids = res.result as? [NSManagedObjectID] else { return }
				print(ids)
				let mainCtx = CoreDataStack.shared.persistentContainer.viewContext

				mainCtx.perform {
					NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSInsertedObjectsKey: res.result!], into: [mainCtx])
				}

			} catch let err {
				print(err)
			}
		}
	}

	func _batchUpdate() {
		let ctx = CoreDataStack.shared.persistentContainer.newBackgroundContext()

		let req = NSBatchUpdateRequest(entityName: "User")
		req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
			NSPredicate(format: "%K = %d", #keyPath(User.age), 11),
			NSPredicate(format: "%K = %d", #keyPath(User.sync), true),
//			NSPredicate(format: "%K = %d", #keyPath(User.rank), 1),
		])
		req.propertiesToUpdate = [
			"sync": false,
		]

		req.resultType = .updatedObjectIDsResultType

		ctx.perform {
			do {
				guard let res = try ctx.execute(req) as? NSBatchUpdateResult else {
					return
				}

				guard let ids = res.result as? [NSManagedObjectID] else { return }
				print(ids)
				let mainCtx = CoreDataStack.shared.persistentContainer.viewContext
				mainCtx.perform {
					NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSUpdatedObjectsKey: res.result!], into: [mainCtx])
				}

			} catch let err {
				print(err)
			}
		}
	}
}

extension ViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		frc.sections?.count ?? 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		frc.sections?[section].numberOfObjects ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		if cell == nil {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		}
		let user = frc.object(at: indexPath)
		cell!.textLabel?.text = user.name
		cell!.detailTextLabel?.text = "\(user.rank) \(user.age) \(user.sync)"
		return cell!
	}
}

// MARK: - NSFetchedResultsControllerDelegate
/// 官方文档
/// https://developer.apple.com/documentation/coredata/nsfetchedresultscontrollerdelegate
extension ViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			print(newIndexPath)
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else { return }
			tableView.deleteRows(at: [indexPath], with: .automatic)
		case .update:
			print("update", indexPath, newIndexPath)
			if let indexPath = indexPath {
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
//			if newIndexPath == indexPath {
//				tableView.reloadRows(at: [indexPath!], with: .automatic)
//			} else if let indexPath = indexPath, let newIndexPath = newIndexPath {
//				tableView.deleteRows(at: [indexPath], with: .automatic)
//				tableView.insertRows(at: [newIndexPath], with: .automatic)
//			}
		case .move:
			guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
			print("move", indexPath, newIndexPath)
//			tableView.moveRow(at: indexPath, to: newIndexPath)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		@unknown default:
			fatalError()
		}
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}
