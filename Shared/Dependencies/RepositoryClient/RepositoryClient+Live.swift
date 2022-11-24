//  RepositoryClient+Live.swift
//  Anime Now!
//
//  Created by ErrorErrorError on 9/3/22.
//

import CoreData
import SwiftORM
import Foundation
import OrderedCollections

final class RepositoryClientLive: RepositoryClient, @unchecked Sendable {
    static let shared = RepositoryClientLive()
    private let pc: NSPersistentContainer

    private init() {
        let bundle = Bundle(for: RepositoryClientLive.self)

        guard let databaseURL = bundle.url(
            forResource: "AnimeNow",
            withExtension: "momd"
        ) else {
            fatalError("Failed to find data model")
        }

        let database = databaseURL.deletingPathExtension().lastPathComponent

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: databaseURL) else {
            fatalError("Failed to create model from file: \(databaseURL)")
        }

        pc = NSPersistentContainer(name: database, managedObjectModel: managedObjectModel)
        pc.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        pc.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }

            description.shouldMigrateStoreAutomatically = false
            description.shouldInferMappingModelAutomatically = true
        }
    }

    func insert<T: ManagedObjectConvertible>(
        _ item: T
    ) async throws {
        try await self.pc.schedule { ctx in
            let object: NSManagedObject?

            if let objectFound = try ctx.fetchOne(T.all.where(T.idKeyPath == item[keyPath: T.idKeyPath])) {
                object = objectFound
            } else {
                object = ctx.insert(entity: T.entityName)
            }

            try object?.update(item)
        }
    }

    func delete<T: ManagedObjectConvertible>(
        _ item: T
    ) async throws {
        try await self.pc.schedule { ctx in
            try ctx.delete(T.all.where(T.idKeyPath == item[keyPath: T.idKeyPath]))
        }
    }

    func fetch<T: ManagedObjectConvertible>(
        _ request: Request<T>
    ) async throws -> [T] {
        try await pc.schedule { ctx in
            try ctx.fetch(request).map { try $0.decode() }
        }
    }

    func observe<T: ManagedObjectConvertible>(
        _ request: Request<T>
    ) -> AsyncStream<[T]> {
        .init { continuation in
            Task.detached { [unowned self] in
                let values = try? await self.fetch(request)
                continuation.yield(values ?? [])

                let observe = NotificationCenter.default.observeNotifications(
                    from: NSManagedObjectContext.didSaveObjectsNotification
                )

                for await _ in observe {
                    let values = try? await self.fetch(request)
                    continuation.yield(values ?? [])
                }
            }
        }
    }
}
