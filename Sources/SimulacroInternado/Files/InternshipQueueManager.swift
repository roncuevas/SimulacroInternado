import Foundation
import Vapor

final class InternshipQueueManager: @unchecked Sendable {
    private(set) var students: [StudentModel] = []
    private(set) var queue: [StudentModel] = []
    private(set) var spots: [QueueSpotModel] = []
    private var connections: [String: WebSocket] = [:]
    private let dataProvider: any InternshipDataSource

    init(dataProvider: any InternshipDataSource) async throws {
        self.dataProvider = dataProvider
        self.spots = try await dataProvider.fetchSpots()
        self.students = try await dataProvider.fetchStudents()

        self.spots.sort { $0.name > $1.name }
        self.students.sort { $0.average > $1.average }
        self.queue = students
    }

    func addToQueue(studentID: String, ws: WebSocket) {
        connections[studentID] = ws
    }

    func canJoin(studentID: String) -> Bool {
        return students.contains(where: { $0.id == studentID })
    }

    func canPick(studentID: String) -> Bool {
        return queue.contains(where: { $0.id == studentID })
    }

    func getGeneralPosition(studentID: String) -> Int {
        return (students.firstIndex(where: { $0.id == studentID }) ?? 9999) + 1
    }

    func register(studentID: String, average: Double) {
        if !queue.contains(where: { $0.id == studentID }) {
            let student = StudentModel(id: studentID, average: average)
            queue.append(student)
        }
    }

    func removeFromQueue(studentID: String) {
        queue.removeAll { $0.id == studentID }
    }

    func removeFromConnections(studentID: String) {
        connections.removeValue(forKey: studentID)
    }

    func selectSpot(for studentID: String, spotID: String) -> Bool {
        guard
            let spotIndex = spots.firstIndex(where: { $0.id == spotID && !$0.isTaken })
        else { return false }

        spots[spotIndex].isTaken = true
        removeFromQueue(studentID: studentID)
        updateAll()
        return true
    }

    func sendError(_ text: String, ws: WebSocket) {
        let response = QueueResponseModel(data: nil, error: text)
        encodeAndSend(response: response, ws: ws)
    }

    func getSpots(index: Int) -> [QueueSpotModel] {
        return spots.filter { !$0.isTaken }
    }

    func updateAll() {
        for (id, ws) in connections {
            if let index = queue.firstIndex(where: { $0.id == id }) {
                let data = QueueDataModel(globalPosition: getGeneralPosition(studentID: id),
                                          studentsCount: students.count,
                                          actualPosition: index + 1,
                                          remaining: index,
                                          spots: getSpots(index: index))
                let response = QueueResponseModel(data: data, error: nil)
                encodeAndSend(response: response, ws: ws)
            }
        }
    }

    func encodeAndSend(response: QueueResponseModel, ws: WebSocket) {
        if let encoded = try? JSONEncoder().encode(response),
            let json = String(data: encoded, encoding: .utf8) {
            ws.send(json)
        }
    }
}
