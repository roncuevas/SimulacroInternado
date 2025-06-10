import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .originBased,
        allowedMethods: [.GET, .POST, .OPTIONS],
        allowedHeaders: [.accept, .contentType]
    )))

     let dataProvider = JSONInternshipDataProvider(app: app)
//    let accountID: String = Environment.get("CLOUDFLARE_ACCOUNT_ID")!
//    let dataProvider = CloudflareD1DataProvider(
//        client: app.client,
//        baseURL: "https://api.cloudflare.com/client/v4/accounts/\(accountID)/d1",
//        databaseID: Environment.get("CLOUDFLARE_DATABASE_ID")!,
//        authToken: Environment.get("CLOUDFLARE_API_KEY")!
//    )

    let manager = try await InternshipQueueManager(dataProvider: dataProvider)
    app.storage[InternshipQueueManagerKey.self] = manager
    app.views.use(.leaf)

    // register routes
    try routes(app)
}
