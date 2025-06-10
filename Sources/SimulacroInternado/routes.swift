import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: InternshipController())
    let queueManager = app.storage[InternshipQueueManagerKey.self]!
    // Get current hostname and port with: app.http.server.shared.localAddress

    app.get("example") { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Mostrar la vista Leaf
    app.get { req async throws in
        return try await req.view.render("login")
    }

    // Endpoint para seleccionar una plaza
//    app.post("select", ":spotID") { req async throws -> HTTPStatus in
    app.post("select") { req async throws -> HTTPStatus in
//        guard let spotIDString = req.parameters.get("spotID"),
//              let spotID = UUID(uuidString: spotIDString)?.uuidString else {
//            throw Abort(.badRequest)÷
//        }

        struct SelectionRequest: Content {
            let boleta: String
            let spotID: String
        }

        let request = try req.content.decode(SelectionRequest.self)
        try queueManager.selectSpot(for: request.boleta, spotID: request.spotID)
        return .ok
    }
}
