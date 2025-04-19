import Foundation
import Vapor

struct InternshipController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let internship = routes.grouped("internship")

        internship.group("admin") { group in
//            group.post(use: createHandler)
        }

        internship.webSocket("queue", onUpgrade: queue)
    }

    func queue(req: Request, ws: WebSocket) async {
        let queueManager = req.application.storage[InternshipQueueManagerKey.self]!
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


}
