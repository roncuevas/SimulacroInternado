import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let queueManager = try await InternshipQueueManager(app: app,
                                                        eventLoop: app.eventLoopGroup.next())
    app.storage[InternshipQueueManagerKey.self] = queueManager
    app.views.use(.leaf)

    // register routes
    try routes(app)
}
