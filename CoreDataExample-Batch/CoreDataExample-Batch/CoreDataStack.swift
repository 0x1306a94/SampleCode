//
//  CoreDataStack.swift
//  CoreDataExample
//
//  Created by king on 2021/6/15.
//

import CoreData

final class CoreDataStack {
	static let shared = CoreDataStack()

	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "CoreDataExample")
//		let url = URL(fileURLWithPath: "/Users/king/Desktop/CoreDataExample/CoreDataExample.sqlite")
//		container.persistentStoreDescriptions.first?.url = url
		container.loadPersistentStores(completionHandler: { _, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		print(container.persistentStoreDescriptions.first?.url)
		return container
	}()

	init() {}
}

extension CoreDataStack {
	func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				print("Unresolved error \(nserror), \(nserror.userInfo)")

				context.rollback()
			}
		}
	}
}
