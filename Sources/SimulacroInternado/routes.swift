import Vapor

func routes(_ app: Application) throws {
    let queueManager = app.storage[InternshipQueueManagerKey.self]!

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

    // WebSocket para unirse a la fila
    app.webSocket("queue") { req, ws in
        guard let boleta = req.query[String.self, at: "boleta"] else {
            ws.close(promise: nil)
            return
        }
        guard queueManager.canJoin(studentID: boleta) else {
            queueManager.sendError("No estas registrado", ws: ws)
            return
        }
        guard queueManager.canPick(studentID: boleta) else {
            queueManager.sendError("Ya seleccionaste plaza", ws: ws)
            return
        }
        queueManager.addToQueue(studentID: boleta, ws: ws)
        queueManager.updateAll()

        ws.onClose.whenComplete { _ in
            queueManager.removeFromConnections(studentID: boleta)
            queueManager.updateAll()
        }
    }

    // Endpoint para seleccionar una plaza
    app.post("select", ":spotID") { req async throws -> HTTPStatus in
        guard let spotIDString = req.parameters.get("spotID"),
              let spotID = UUID(uuidString: spotIDString)?.uuidString else {
            throw Abort(.badRequest)
        }

        struct SelectionRequest: Content {
            let boleta: String
        }

        let selection = try req.content.decode(SelectionRequest.self)

        if queueManager.selectSpot(for: selection.boleta, spotID: spotID) {
            return .ok
        } else {
            return .conflict
        }
    }
}
